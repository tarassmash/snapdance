#!/usr/bin/env python3
"""
SnapDance → App Store Connect API.
Запускается в GitHub Actions (секреты ASC_ISSUER_ID, ASC_KEY_ID, ASC_KEY_P8).

  python asc.py setup                      # Bundle ID, приложение, категории, рейтинг, цена, покупки рубинов
  python asc.py screenshots shots/         # скриншоты версии (shots/<locale>/*.png) и скриншот для проверки покупок
  python asc.py submit --build 12          # описание, сборка, данные для проверки, отправка на App Review
  python asc.py status                     # что сейчас в App Store Connect
"""
import argparse, hashlib, json, os, sys, time
from pathlib import Path

import jwt, requests

API = "https://api.appstoreconnect.apple.com"
HERE = Path(__file__).parent
META = json.loads((HERE / "metadata.json").read_text())
EDITABLE = {"PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY", "WAITING_FOR_REVIEW", "READY_FOR_REVIEW"}


class ASCError(Exception):
    pass


def token():
    key = os.environ["ASC_KEY_P8"].strip().replace("\\n", "\n")
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"].strip(), "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"},
                      key, algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"].strip(), "typ": "JWT"})


_tok = {"v": None, "t": 0}


def call(method, path, body=None, params=None, ok404=False):
    if time.time() - _tok["t"] > 900:
        _tok["v"], _tok["t"] = token(), time.time()
    url = path if path.startswith("http") else API + path
    for attempt in range(4):
        r = requests.request(method, url, json=body, params=params, timeout=120,
                             headers={"Authorization": "Bearer " + _tok["v"], "Content-Type": "application/json"})
        if r.status_code in (429, 500, 502, 503, 504) and attempt < 3:
            time.sleep(5 * (attempt + 1)); continue
        break
    if ok404 and r.status_code == 404:
        return None
    if r.status_code >= 400:
        try:
            errs = r.json().get("errors", [])
            msg = "; ".join(f"{e.get('code')}: {e.get('detail') or e.get('title')}" for e in errs)
        except Exception:
            msg = r.text[:500]
        raise ASCError(f"{method} {path} → {r.status_code}: {msg}")
    return r.json() if r.content else {}


def get_all(path, params=None):
    out, url, p = [], path, dict(params or {}, limit=200)
    while url:
        d = call("GET", url, params=p)
        out += d.get("data", [])
        url, p = (d.get("links") or {}).get("next"), None
    return out


def rel(t, i):
    return {"data": {"type": t, "id": i}}


def step(name):
    print(f"\n=== {name}", flush=True)


def warn(e):
    print(f"  ⚠️  {e}", flush=True)


# ---------------------------------------------------------------- приложение

def bundle_id():
    bid = os.environ.get("IOS_BUNDLE_ID") or META["bundleId"]
    found = call("GET", "/v1/bundleIds", params={"filter[identifier]": bid})["data"]
    found = [b for b in found if b["attributes"]["identifier"] == bid]
    if found:
        print(f"  Bundle ID {bid}: есть")
        return found[0]
    d = call("POST", "/v1/bundleIds", {"data": {"type": "bundleIds", "attributes": {"identifier": bid, "name": "SnapDance", "platform": "IOS"}}})
    print(f"  Bundle ID {bid}: зарегистрирован")
    return d["data"]


def the_app():
    bid = os.environ.get("IOS_BUNDLE_ID") or META["bundleId"]
    apps = call("GET", "/v1/apps", params={"filter[bundleId]": bid})["data"]
    apps = [a for a in apps if a["attributes"]["bundleId"] == bid]
    if not apps:
        raise ASCError(f"Приложение с Bundle ID {bid} не найдено. Создайте его в App Store Connect → Приложения → «+» → Новое приложение "
                       f"(iOS, SnapDance, Bundle ID {bid}, SKU snapdance) — через API Apple создавать приложения не разрешает.")
    a = apps[0]
    print(f"  Приложение: {a['attributes']['name']} (id {a['id']}, основной язык {a['attributes'].get('primaryLocale')})")
    return a


def territories():
    return [t["id"] for t in get_all("/v1/territories")]


def app_info(app):
    infos = call("GET", f"/v1/apps/{app['id']}/appInfos")["data"]
    for i in infos:
        st = i["attributes"].get("appStoreState") or i["attributes"].get("state")
        if st not in ("READY_FOR_SALE", "READY_FOR_DISTRIBUTION", "REPLACED_WITH_NEW_INFO"):
            return i
    return infos[0]


def setup_app_info(app):
    step("Название, подзаголовок, политика конфиденциальности, категории")
    info = app_info(app)
    try:
        call("PATCH", f"/v1/appInfos/{info['id']}", {"data": {"type": "appInfos", "id": info["id"], "relationships": {
            "primaryCategory": rel("appCategories", META["primaryCategory"]),
            "secondaryCategory": rel("appCategories", META["secondaryCategory"])}}})
        print("  категории: Фото и видео / Развлечения")
    except ASCError as e:
        warn(e)
    have = {l["attributes"]["locale"]: l for l in call("GET", f"/v1/appInfos/{info['id']}/appInfoLocalizations")["data"]}
    for loc, m in META["locales"].items():
        attrs = {"name": META["appName"], "subtitle": m["subtitle"], "privacyPolicyUrl": META["privacyUrl"]}
        try:
            if loc in have:
                call("PATCH", f"/v1/appInfoLocalizations/{have[loc]['id']}", {"data": {"type": "appInfoLocalizations", "id": have[loc]["id"], "attributes": attrs}})
            else:
                call("POST", "/v1/appInfoLocalizations", {"data": {"type": "appInfoLocalizations", "attributes": dict(attrs, locale=loc),
                                                                    "relationships": {"appInfo": rel("appInfos", info["id"])}}})
            print(f"  {loc}: ок")
        except ASCError as e:
            warn(f"{loc}: {e}")

    step("Возрастной рейтинг")
    try:
        ard = call("GET", f"/v1/appInfos/{info['id']}/ageRatingDeclaration")["data"]
        bools = {"gambling", "unrestrictedWebAccess", "lootBox", "messagingAndChat", "userGeneratedContent", "advertising",
                 "ageAssurance", "healthOrWellnessTopics", "parentalControls", "seventeenPlus"}
        skip = {"kidsAgeBand", "developerAgeRatingInfoUrl", "ageRatingOverride", "ageRatingOverrideV2", "koreaAgeRatingOverride"}
        attrs = {}
        for k in ard["attributes"]:
            if k in skip:
                continue
            attrs[k] = False if k in bools else "NONE"
        try:
            call("PATCH", f"/v1/ageRatingDeclarations/{ard['id']}", {"data": {"type": "ageRatingDeclarations", "id": ard["id"], "attributes": attrs}})
            print("  всё «нет» (4+)")
        except ASCError as e:
            warn(e)
            for k, v in attrs.items():  # по одному, чтобы не потерять остальные
                try:
                    call("PATCH", f"/v1/ageRatingDeclarations/{ard['id']}", {"data": {"type": "ageRatingDeclarations", "id": ard["id"], "attributes": {k: v}}})
                except ASCError as e2:
                    warn(f"{k}: {e2}")
    except ASCError as e:
        warn(e)

    step("Права на контент")
    try:
        call("PATCH", f"/v1/apps/{app['id']}", {"data": {"type": "apps", "id": app["id"], "attributes": {"contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"}}})
        print("  ок")
    except ASCError as e:
        warn(e)


def setup_pricing(app, terr):
    step("Цена приложения: бесплатно, все страны")
    if call("GET", f"/v1/apps/{app['id']}/appPriceSchedule", ok404=True):
        print("  цена уже задана")
    else:
        try:
            pts = call("GET", f"/v1/apps/{app['id']}/appPricePoints", params={"filter[territory]": "USA", "limit": 200})["data"]
            free = next(p for p in pts if float(p["attributes"]["customerPrice"]) == 0)
            call("POST", "/v1/appPriceSchedules", {
                "data": {"type": "appPriceSchedules", "relationships": {
                    "app": rel("apps", app["id"]), "baseTerritory": rel("territories", "USA"),
                    "manualPrices": {"data": [{"type": "appPrices", "id": "${p0}"}]}}},
                "included": [{"type": "appPrices", "id": "${p0}", "attributes": {"startDate": None},
                              "relationships": {"appPricePoint": rel("appPricePoints", free["id"])}}]})
            print("  бесплатно")
        except (ASCError, StopIteration) as e:
            warn(e)
    try:
        if call("GET", f"/v1/apps/{app['id']}/appAvailabilityV2", ok404=True):
            print("  доступность уже задана")
        else:
            inc = [{"type": "territoryAvailabilities", "id": f"${{t{i}}}", "attributes": {"available": True},
                    "relationships": {"territory": rel("territories", t)}} for i, t in enumerate(terr)]
            call("POST", "/v2/appAvailabilities", {"data": {"type": "appAvailabilities", "attributes": {"availableInNewTerritories": True},
                                                            "relationships": {"app": rel("apps", app["id"]),
                                                                              "territoryAvailabilities": {"data": [{"type": x["type"], "id": x["id"]} for x in inc]}}},
                                                   "included": inc})
            print(f"  доступно в {len(terr)} странах")
    except ASCError as e:
        warn(e)


# ---------------------------------------------------------------- покупки рубинов

def iaps(app):
    return {i["attributes"]["productId"]: i for i in get_all(f"/v1/apps/{app['id']}/inAppPurchasesV2")}


def setup_iaps(app, terr):
    bid = os.environ.get("IOS_BUNDLE_ID") or META["bundleId"]
    have = iaps(app)
    for p in META["iap"]:
        pid = f"{bid}.rubies.{p['pack']}"
        step(f"Покупка {pid}: {p['rubies']} рубинов за {p['eur']} €")
        try:
            if pid in have:
                iap = have[pid]
                print(f"  есть (состояние {iap['attributes'].get('state')})")
            else:
                iap = call("POST", "/v2/inAppPurchases", {"data": {"type": "inAppPurchases", "attributes": {
                    "name": f"{p['rubies']} rubies", "productId": pid, "inAppPurchaseType": "CONSUMABLE",
                    "reviewNote": f"Adds {p['rubies']} rubies to the user's balance. Rubies are spent to generate dance videos.",
                    "familySharable": False}, "relationships": {"app": rel("apps", app["id"])}}})["data"]
                print("  создана")
        except ASCError as e:
            warn(e); continue
        iid = iap["id"]

        locs = {l["attributes"]["locale"]: l for l in call("GET", f"/v2/inAppPurchases/{iid}/inAppPurchaseLocalizations")["data"]}
        for loc, m in META["locales"].items():
            attrs = {"name": m["iapName"].format(n=p["rubies"]), "description": m["iapDesc"].format(n=p["rubies"])}
            try:
                if loc in locs:
                    call("PATCH", f"/v1/inAppPurchaseLocalizations/{locs[loc]['id']}", {"data": {"type": "inAppPurchaseLocalizations", "id": locs[loc]["id"], "attributes": attrs}})
                else:
                    call("POST", "/v1/inAppPurchaseLocalizations", {"data": {"type": "inAppPurchaseLocalizations", "attributes": dict(attrs, locale=loc),
                                                                             "relationships": {"inAppPurchaseV2": rel("inAppPurchases", iid)}}})
            except ASCError as e:
                warn(f"{loc}: {e}")
        print("  названия и описания: ок")

        try:
            if call("GET", f"/v2/inAppPurchases/{iid}/iapPriceSchedule", ok404=True):
                print("  цена уже задана")
            else:
                base = META["baseTerritory"]
                pts = get_all(f"/v2/inAppPurchases/{iid}/pricePoints", {"filter[territory]": base})
                pp = next((x for x in pts if abs(float(x["attributes"]["customerPrice"]) - float(p["eur"])) < 0.001), None)
                if not pp:
                    raise ASCError(f"нет цены {p['eur']} в {base}")
                call("POST", "/v1/inAppPurchasePriceSchedules", {
                    "data": {"type": "inAppPurchasePriceSchedules", "relationships": {
                        "inAppPurchase": rel("inAppPurchases", iid), "baseTerritory": rel("territories", base),
                        "manualPrices": {"data": [{"type": "inAppPurchasePrices", "id": "${p0}"}]}}},
                    "included": [{"type": "inAppPurchasePrices", "id": "${p0}", "attributes": {"startDate": None},
                                  "relationships": {"inAppPurchaseV2": rel("inAppPurchases", iid),
                                                    "inAppPurchasePricePoint": rel("inAppPurchasePricePoints", pp["id"])}}]})
                print(f"  цена {p['eur']} € (остальные страны — по курсу Apple)")
        except ASCError as e:
            warn(e)

        try:
            if call("GET", f"/v2/inAppPurchases/{iid}/inAppPurchaseAvailability", ok404=True):
                print("  доступность уже задана")
            else:
                call("POST", "/v1/inAppPurchaseAvailabilities", {"data": {"type": "inAppPurchaseAvailabilities",
                     "attributes": {"availableInNewTerritories": True},
                     "relationships": {"inAppPurchase": rel("inAppPurchases", iid),
                                       "availableTerritories": {"data": [{"type": "territories", "id": t} for t in terr]}}}})
                print("  доступна во всех странах")
        except ASCError as e:
            warn(e)


# ---------------------------------------------------------------- загрузка файлов

def upload(create_path, rel_name, rel_type, rel_id, file: Path, res_type):
    data = file.read_bytes()
    d = call("POST", create_path, {"data": {"type": res_type, "attributes": {"fileName": file.name, "fileSize": len(data)},
                                            "relationships": {rel_name: rel(rel_type, rel_id)}}})["data"]
    for op in d["attributes"]["uploadOperations"]:
        chunk = data[op["offset"]: op["offset"] + op["length"]]
        hdr = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        r = requests.request(op["method"], op["url"], data=chunk, headers=hdr, timeout=300)
        if r.status_code >= 300:
            raise ASCError(f"upload {file.name}: {r.status_code}")
    call("PATCH", f"{create_path}/{d['id']}", {"data": {"type": res_type, "id": d["id"],
                                                        "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
    return d["id"]


# ---------------------------------------------------------------- версия

def version(app):
    vs = call("GET", f"/v1/apps/{app['id']}/appStoreVersions", params={"filter[platform]": "IOS", "limit": 50})["data"]
    for v in vs:
        st = v["attributes"].get("appVersionState") or v["attributes"].get("appStoreState")
        if st in EDITABLE or st in ("PREPARE_FOR_SUBMISSION",):
            if v["attributes"]["versionString"] != META["version"] and st == "PREPARE_FOR_SUBMISSION":
                call("PATCH", f"/v1/appStoreVersions/{v['id']}", {"data": {"type": "appStoreVersions", "id": v["id"], "attributes": {"versionString": META["version"]}}})
            return v
    v = call("POST", "/v1/appStoreVersions", {"data": {"type": "appStoreVersions", "attributes": {"platform": "IOS", "versionString": META["version"]},
                                                       "relationships": {"app": rel("apps", app["id"])}}})["data"]
    print(f"  создана версия {META['version']}")
    return v


def version_locs(v):
    have = {l["attributes"]["locale"]: l for l in call("GET", f"/v1/appStoreVersions/{v['id']}/appStoreVersionLocalizations")["data"]}
    for loc, m in META["locales"].items():
        attrs = {"description": m["description"], "keywords": m["keywords"], "promotionalText": m["promotionalText"],
                 "supportUrl": META["supportUrl"], "marketingUrl": META["marketingUrl"]}
        try:
            if loc in have:
                call("PATCH", f"/v1/appStoreVersionLocalizations/{have[loc]['id']}", {"data": {"type": "appStoreVersionLocalizations", "id": have[loc]["id"], "attributes": attrs}})
            else:
                have[loc] = call("POST", "/v1/appStoreVersionLocalizations", {"data": {"type": "appStoreVersionLocalizations", "attributes": dict(attrs, locale=loc),
                                                                                       "relationships": {"appStoreVersion": rel("appStoreVersions", v["id"])}}})["data"]
            print(f"  {loc}: описание ок")
        except ASCError as e:
            warn(f"{loc}: {e}")
    return have


def cmd_screenshots(shots: Path):
    app = the_app()
    step("Скриншоты версии")
    v = version(app)
    locs = version_locs(v)
    for loc, l in locs.items():
        files = sorted((shots / loc).glob("*.png")) or sorted((shots / "en-US").glob("*.png"))
        if not files:
            warn(f"{loc}: нет скриншотов"); continue
        dtype = os.environ.get("SHOT_TYPE", "APP_IPHONE_67")
        sets = call("GET", f"/v1/appStoreVersionLocalizations/{l['id']}/appScreenshotSets")["data"]
        s = next((x for x in sets if x["attributes"]["screenshotDisplayType"] == dtype), None)
        if s:
            for old in call("GET", f"/v1/appScreenshotSets/{s['id']}/appScreenshots")["data"]:
                call("DELETE", f"/v1/appScreenshots/{old['id']}")
        else:
            s = call("POST", "/v1/appScreenshotSets", {"data": {"type": "appScreenshotSets", "attributes": {"screenshotDisplayType": dtype},
                                                                "relationships": {"appStoreVersionLocalization": rel("appStoreVersionLocalizations", l["id"])}}})["data"]
        for f in files:
            upload("/v1/appScreenshots", "appScreenshotSet", "appScreenshotSets", s["id"], f, "appScreenshots")
        print(f"  {loc}: {len(files)} шт. ({dtype})")

    step("Скриншот для проверки покупок")
    review_shot = shots / "iap-review.png"
    if not review_shot.exists():
        review_shot = next(iter(sorted((shots / "en-US").glob("*.png"))), None)
    for pid, iap in iaps(app).items():
        try:
            rs = call("GET", f"/v2/inAppPurchases/{iap['id']}/appStoreReviewScreenshot", ok404=True)
            if rs and rs.get("data"):
                print(f"  {pid}: уже есть"); continue
            upload("/v1/inAppPurchaseAppStoreReviewScreenshots", "inAppPurchaseV2", "inAppPurchases", iap["id"], review_shot, "inAppPurchaseAppStoreReviewScreenshots")
            print(f"  {pid}: загружен")
        except ASCError as e:
            warn(f"{pid}: {e}")


def wait_build(app, number):
    if not number:
        bs = call("GET", "/v1/builds", params={"filter[app]": app["id"], "sort": "-uploadedDate", "limit": 1})["data"]
        if not bs:
            raise ASCError("В App Store Connect ещё нет ни одной сборки — сначала запустите action=build")
        number = bs[0]["attributes"]["version"]
    step(f"Ждём обработку сборки {number}")
    for i in range(90):
        bs = call("GET", "/v1/builds", params={"filter[app]": app["id"], "filter[version]": str(number), "limit": 5})["data"]
        if bs:
            st = bs[0]["attributes"]["processingState"]
            print(f"  {st}", flush=True)
            if st == "VALID":
                b = bs[0]
                if b["attributes"].get("usesNonExemptEncryption") is None:
                    try:
                        call("PATCH", f"/v1/builds/{b['id']}", {"data": {"type": "builds", "id": b["id"], "attributes": {"usesNonExemptEncryption": False}}})
                    except ASCError as e:
                        warn(e)
                return b
            if st in ("FAILED", "INVALID"):
                raise ASCError(f"Сборка {number}: {st}")
        else:
            print("  ещё не появилась", flush=True)
        time.sleep(30)
    raise ASCError("Сборка не обработалась за 45 минут")


def cmd_submit(build_no, send=True):
    app = the_app()
    step("Версия")
    v = version(app)
    print(f"  {v['attributes']['versionString']} (id {v['id']})")
    try:
        call("PATCH", f"/v1/appStoreVersions/{v['id']}", {"data": {"type": "appStoreVersions", "id": v["id"], "attributes": {"copyright": META["copyright"], "releaseType": "AFTER_APPROVAL"}}})
    except ASCError as e:
        warn(e)
    version_locs(v)

    b = wait_build(app, build_no)
    step("Прикрепляем сборку")
    call("PATCH", f"/v1/appStoreVersions/{v['id']}/relationships/build", {"data": {"type": "builds", "id": b["id"]}})
    print("  ок")

    step("Данные для проверяющего")
    code = os.environ.get("APPLE_REVIEW_CODE", "")
    if not code:
        print("  пропущено: контакт и заметки заполняются в App Store Connect вручную (без секрета APPLE_REVIEW_CODE)")
    else:
        review_details(v, code)
    _after_review(app, v, send)


def review_details(v, code):
    # REVIEW_CONTACT = "Имя;Фамилия;+34 600 000 000;email@example.com"
    c = [x.strip() for x in os.environ.get("REVIEW_CONTACT", "").split(";")] + ["", "", "", ""]
    attrs = {"contactFirstName": c[0], "contactLastName": c[1], "contactPhone": c[2], "contactEmail": c[3] or "support@snapdance.us",
             "demoAccountRequired": False, "notes": META["reviewNotes"].replace("{code}", code)}
    rd = call("GET", f"/v1/appStoreVersions/{v['id']}/appStoreReviewDetail", ok404=True)
    if rd and rd.get("data"):
        call("PATCH", f"/v1/appStoreReviewDetails/{rd['data']['id']}", {"data": {"type": "appStoreReviewDetails", "id": rd["data"]["id"], "attributes": attrs}})
    else:
        call("POST", "/v1/appStoreReviewDetails", {"data": {"type": "appStoreReviewDetails", "attributes": attrs,
                                                            "relationships": {"appStoreVersion": rel("appStoreVersions", v["id"])}}})
    print("  ок")


def _after_review(app, v, send):
    step("Покупки — вместе с версией")
    for pid, iap in iaps(app).items():
        st = iap["attributes"].get("state")
        if st in ("READY_TO_SUBMIT", "DEVELOPER_ACTION_NEEDED", "REJECTED"):
            try:
                call("POST", "/v1/inAppPurchaseSubmissions", {"data": {"type": "inAppPurchaseSubmissions", "relationships": {"inAppPurchaseV2": rel("inAppPurchases", iap["id"])}}})
                print(f"  {pid}: отправлена")
            except ASCError as e:
                warn(f"{pid}: {e}")
        else:
            print(f"  {pid}: {st}")

    if not send:
        print("\nГотово к отправке (без --send ничего не отправлено)."); return
    step("Отправка на проверку App Review")
    subs = call("GET", "/v1/reviewSubmissions", params={"filter[app]": app["id"], "filter[platform]": "IOS"})["data"]
    sub = next((s for s in subs if s["attributes"]["state"] in ("READY_FOR_REVIEW",)), None)
    if not sub:
        sub = call("POST", "/v1/reviewSubmissions", {"data": {"type": "reviewSubmissions", "attributes": {"platform": "IOS"},
                                                              "relationships": {"app": rel("apps", app["id"])}}})["data"]
    items = call("GET", f"/v1/reviewSubmissions/{sub['id']}/items")["data"]
    if not items:
        call("POST", "/v1/reviewSubmissionItems", {"data": {"type": "reviewSubmissionItems", "relationships": {
            "reviewSubmission": rel("reviewSubmissions", sub["id"]), "appStoreVersion": rel("appStoreVersions", v["id"])}}})
    call("PATCH", f"/v1/reviewSubmissions/{sub['id']}", {"data": {"type": "reviewSubmissions", "id": sub["id"], "attributes": {"submitted": True}}})
    print("  ✅ Отправлено на проверку App Review")


def cmd_status():
    app = the_app()
    for v in call("GET", f"/v1/apps/{app['id']}/appStoreVersions", params={"limit": 5})["data"]:
        a = v["attributes"]
        print(f"  версия {a['versionString']}: {a.get('appVersionState') or a.get('appStoreState')}")
    for pid, i in iaps(app).items():
        print(f"  {pid}: {i['attributes'].get('state')}")
    for s in call("GET", "/v1/reviewSubmissions", params={"filter[app]": app["id"]})["data"]:
        print(f"  проверка {s['id']}: {s['attributes']['state']}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["setup", "screenshots", "submit", "status"])
    ap.add_argument("dir", nargs="?")
    ap.add_argument("--build")
    ap.add_argument("--send", action="store_true")
    a = ap.parse_args()
    try:
        if a.cmd == "setup":
            step("Bundle ID и приложение")
            bundle_id()
            app = the_app()
            terr = territories()
            setup_app_info(app)
            setup_pricing(app, terr)
            setup_iaps(app, terr)
        elif a.cmd == "screenshots":
            cmd_screenshots(Path(a.dir or "shots"))
        elif a.cmd == "submit":
            cmd_submit(a.build, send=a.send)
        else:
            cmd_status()
    except ASCError as e:
        print(f"\n❌ {e}", flush=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
