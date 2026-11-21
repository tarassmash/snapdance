import SwiftUI

// MARK: - Настройки приложения

enum SDConfig {
    /// Сервер SnapDance (тот же, что у сайта).
    static let api = URL(string: "https://snapdance.us")!

    /// Префикс покупок в App Store Connect: <bundle id>.rubies.<пакет> (start / pop / pro).
    static var productPrefix: String { (Bundle.main.bundleIdentifier ?? "us.snapdance.app") + ".rubies." }

    /// Страницы сайта на языке приложения: /privacy (es), /en/privacy, /ru/privacy.
    static var langPrefix: String { appLang == .es ? "" : "/" + serverLang }
    static var privacyURL: URL { URL(string: "https://snapdance.us\(langPrefix)/privacy")! }
    static var termsURL: URL { URL(string: "https://snapdance.us\(langPrefix)/terms")! }
    static var reportURL: URL { URL(string: "https://snapdance.us\(langPrefix)/report")! }
    static let trendsURL = URL(string: "https://www.tiktok.com/tag/dancechallenge")!

    /// Максимальная длина ролика-образца, секунды (длиннее — обрезаем сами).
    static let maxRefSeconds: Double = 15
    /// Единственный вариант генерации (как на сайте): Kling 2.6 + первый кадр Nano Banana Pro.
    static let model = "mc26"
    static let frame = "nbpro"

    static let bg = Color(red: 12 / 255, green: 11 / 255, blue: 16 / 255)
    static let panel = Color(red: 22 / 255, green: 21 / 255, blue: 28 / 255)
    static let panel2 = Color(red: 30 / 255, green: 29 / 255, blue: 38 / 255)
    static let line = Color.white.opacity(0.1)
    static let lime = Color(red: 198 / 255, green: 1, blue: 61 / 255)
    static let muted = Color.white.opacity(0.6)
}

// MARK: - Тексты на трёх языках (как на сайте: es / en / ru)

enum Lang: String { case es, en, ru, uk, de, fr, sv }

let appLang: Lang = {
    let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "en"
    if code == "uk" { return .uk }
    if code == "de" { return .de }
    if code == "fr" { return .fr }
    if code == "sv" { return .sv }
    if code == "ru" || code == "be" { return .ru }
    if code == "es" || code == "ca" || code == "gl" || code == "eu" { return .es }
    return .en
}()

/// Язык для сервера и сайта: там есть es / en / ru, украинцам — английский.
var serverLang: String { [Lang.es, .en, .ru].contains(appLang) ? appLang.rawValue : "en" }

/// Сколько видео: «1 видео», «2 vídeos», «1 video».
func videosText(_ n: Int) -> String {
    switch appLang {
    case .ru: return "\(n) видео"
    case .uk: return "\(n) відео"
    case .es: return n == 1 ? "1 vídeo" : "\(n) vídeos"
    case .en: return n == 1 ? "1 video" : "\(n) videos"
    case .de: return n == 1 ? "1 Video" : "\(n) Videos"
    case .fr: return n == 1 ? "1 vidéo" : "\(n) vidéos"
    case .sv: return n == 1 ? "1 video" : "\(n) videor"
    }
}

/// Места для танца (id совпадают с сервером) и очки.
let PLACES = ["photo", "street", "room", "gym", "party", "beach", "park", "kitchen", "office", "club", "rooftop"]
let PLACE_ICONS = ["photo": "photo", "street": "building.2", "room": "bed.double", "gym": "figure.dance", "party": "party.popper", "beach": "beach.umbrella", "park": "tree", "kitchen": "fork.knife", "office": "desktopcomputer", "club": "music.note.house", "rooftop": "sunset"]
let GLASSES = ["black", "aviator", "round", "mirror", "cateye", "heart", "clear"]

/// Короткий доступ к тексту: L("go") → «Сделать видео».
func L(_ key: String, _ args: [String: String] = [:]) -> String {
    var s = (STR[appLang]?[key]) ?? (STR[.en]?[key]) ?? key
    for (k, v) in args { s = s.replacingOccurrences(of: "{\(k)}", with: v) }
    return s
}

private let STR: [Lang: [String: String]] = [
    .ru: [
        "tagline": "Фото → танец из TikTok",
        "step1": "Фото человека", "step1s": "В полный рост, хорошо видно лицо",
        "slot.1": "В полный рост", "slot.1s": "обязательно", "slot.2": "Лицо крупно", "slot.3": "Другой ракурс", "opt": "по желанию",
        "step2": "Ролик с трендом", "step2s": "Любая длина: берём первые 15 сек. Один танцор в полный рост.",
        "ref.pick": "Выбрать видео", "ref.change": "Заменить", "ref.trends": "Найти тренды в TikTok", "ref.cut": "Ролик длинный — возьмём первые {s} сек.",
        "consent": "У меня есть согласие человека на фото, ему 18+. Я не нарушаю чужие права.",
        "go": "Сделать видео", "inc": "Kling 2.6 · звук из ролика · пометка ИИ",
        "err.photo": "Добавьте фото в полный рост.", "err.ref": "Добавьте ролик с трендовым танцем.", "err.consent": "Отметьте согласие и 18+.",
        "err.net": "Нет соединения с сервером. Проверьте интернет.", "err.video": "Не получилось прочитать видео. Попробуйте другое.",
        "busy.photo": "Загружаем фото {n}…", "busy.ref": "Загружаем ролик…", "busy.start": "Запускаем…",
        "work.title": "Создаём видео", "work.sub": "Обычно 3–6 минут. Можно свернуть приложение — видео сохранится в «Мои видео».",
        "done": "Готово!", "save": "Сохранить в Фото", "saved": "Сохранено в Фото ✅", "share": "Поделиться", "tiktok": "Опубликовать в TikTok",
        "tt.hint": "Подпись скопирована — выберите TikTok и вставьте её в описание.", "again": "Сделать ещё",
        "mine": "Мои видео", "mine.empty": "Здесь появятся ваши видео. Они хранятся 7 дней.", "del": "Удалить", "del.q": "Удалить это видео?",
        "st.working": "Создаётся…", "st.failed": "Не получилось — рубины вернулись", "st.done": "Готово",
        "wallet": "Рубины", "balance": "Баланс", "buy": "Купить рубины", "buy.need": "Нужно {n} 💎, у вас {m} 💎.",
        "buy.ok": "Начислено {n} 💎", "buy.pending": "Покупка ожидает подтверждения.", "buy.fail": "Покупка не прошла: {e}",
        "buy.load": "Загружаем цены App Store…", "buy.none": "Покупки пока недоступны. Попробуйте позже.",
        "code": "Ваш код", "code.hint": "По этому коду вход с любого устройства и на сайте snapdance.us. Сохраните его.",
        "code.copy": "Скопировать", "code.copied": "Код скопирован", "code.enter": "У меня уже есть код", "code.ph": "SD-XXXX-XXXX-XXXX", "code.login": "Войти",
        "code.bad": "Код не найден.", "logout": "Выйти", "logout.q": "Выйти? Без кода вы потеряете доступ к рубинам.",
        "privacy": "Конфиденциальность", "terms": "Условия", "report": "Пожаловаться на видео", "close": "Закрыть", "cancel": "Отмена", "ok": "OK",
        "videos7": "Видео хранится 7 дней",
        "pack.videos": "{v} до 15 сек", "hero.a": "Одно фото — ", "hero.b": "танец под тренд", "hero.c": "как снятый на телефон", "hero.p": "Загрузите фото, выберите танец и нажмите одну кнопку. Через несколько минут — вертикальное видео для TikTok.", "hero.cta": "Сделать свой танец",
        "step3": "Место и очки", "step3s": "Где танцевать и, если стесняетесь, — в очках", "place": "Где танцует", "gl.on": "Надеть очки", "gl.hint": "Очки будут на лице всё видео", "gl.pick": "Какие очки",
        "pl.photo": "Как на фото", "pl.street": "Улица", "pl.room": "Комната", "pl.gym": "Танцевальная студия", "pl.party": "Домашняя вечеринка", "pl.beach": "Пляж", "pl.park": "Парк", "pl.kitchen": "Кухня", "pl.office": "Офис", "pl.club": "Ночной клуб", "pl.rooftop": "Крыша на закате",
        "gl.black": "Чёрные солнцезащитные", "gl.aviator": "Авиаторы", "gl.round": "Круглые ретро", "gl.mirror": "Спортивные зеркальные", "gl.cateye": "«Кошачий глаз»", "gl.heart": "Сердечки", "gl.clear": "Прозрачные в чёрной оправе", "pack.start": "Старт", "pack.pop": "Тренд", "pack.pro": "Студия", "pack.hit": "ХИТ", "bal.videos": "Хватит на {v} по {s} сек", "bal.none": "Видео {s} сек = {p} 💎",
        "set.title": "Настройки", "set.share": "Поделиться приложением", "set.shareMsg": "Оживи фото — пусть станцует тренд из TikTok", "set.rate": "Оценить приложение", "set.write": "Написать разработчикам", "set.terms": "Условия использования", "set.eula": "Лицензионное соглашение (EULA)", "set.privacy": "Политика конфиденциальности",
        "ex.h2a": "Примеры: ", "ex.before.w": "до", "ex.and": " и ", "ex.after.w": "после", "ex.hint": "Было одно фото — стало видео. Нажмите на видео, чтобы включить звук.", "ex.before": "ДО", "ex.after": "ПОСЛЕ", "ex.user": "вы",
        "buy.xcode": "Тестовая покупка в Xcode прошла. Настоящие рубины начисляются только при покупке через TestFlight или App Store.", "secs": "{s} сек", "photo.lib": "Выбрать фото", "rubies": "рубинов",
    ],
    .uk: [
        "tagline": "Фото → танець із TikTok",
        "step1": "Фото людини", "step1s": "На повний зріст, добре видно обличчя",
        "slot.1": "На повний зріст", "slot.1s": "обов'язково", "slot.2": "Обличчя крупно", "slot.3": "Інший ракурс", "opt": "за бажанням",
        "step2": "Ролик із трендом", "step2s": "Будь-яка довжина: беремо перші 15 сек. Один танцюрист на повний зріст.",
        "ref.pick": "Вибрати відео", "ref.change": "Замінити", "ref.trends": "Знайти тренди в TikTok", "ref.cut": "Ролик довгий — візьмемо перші {s} сек.",
        "consent": "Я маю згоду людини на фото, їй 18+. Я не порушую чужих прав.",
        "go": "Зробити відео", "inc": "Kling 2.6 · звук із ролика · позначка ШІ",
        "err.photo": "Додайте фото на повний зріст.", "err.ref": "Додайте ролик із трендовим танцем.", "err.consent": "Позначте згоду та 18+.",
        "err.net": "Немає з'єднання із сервером. Перевірте інтернет.", "err.video": "Не вдалося прочитати відео. Спробуйте інше.",
        "busy.photo": "Завантажуємо фото {n}…", "busy.ref": "Завантажуємо ролик…", "busy.start": "Запускаємо…",
        "work.title": "Створюємо відео", "work.sub": "Зазвичай 3–6 хвилин. Можна згорнути застосунок — відео збережеться в «Мої відео».",
        "done": "Готово!", "save": "Зберегти у Фото", "saved": "Збережено у Фото ✅", "share": "Поділитися", "tiktok": "Опублікувати в TikTok",
        "tt.hint": "Підпис скопійовано — виберіть TikTok і вставте його в опис.", "again": "Зробити ще",
        "mine": "Мої відео", "mine.empty": "Тут з'являться ваші відео. Вони зберігаються 7 днів.", "del": "Видалити", "del.q": "Видалити це відео?",
        "st.working": "Створюється…", "st.failed": "Не вийшло — рубіни повернулися", "st.done": "Готово",
        "wallet": "Рубіни", "balance": "Баланс", "buy": "Купити рубіни", "buy.need": "Потрібно {n} 💎, у вас {m} 💎.",
        "buy.ok": "Нараховано {n} 💎", "buy.pending": "Покупка очікує підтвердження.", "buy.fail": "Покупка не пройшла: {e}",
        "buy.load": "Завантажуємо ціни App Store…", "buy.none": "Покупки поки недоступні. Спробуйте пізніше.",
        "code": "Ваш код", "code.hint": "За цим кодом вхід із будь-якого пристрою та на сайті snapdance.us. Збережіть його.",
        "code.copy": "Скопіювати", "code.copied": "Код скопійовано", "code.enter": "У мене вже є код", "code.ph": "SD-XXXX-XXXX-XXXX", "code.login": "Увійти",
        "code.bad": "Код не знайдено.", "logout": "Вийти", "logout.q": "Вийти? Без коду ви втратите доступ до рубінів.",
        "privacy": "Конфіденційність", "terms": "Умови", "report": "Поскаржитися на відео", "close": "Закрити", "cancel": "Скасувати", "ok": "OK",
        "videos7": "Відео зберігається 7 днів",
        "pack.videos": "{v} до 15 сек", "hero.a": "Одне фото — ", "hero.b": "танець під тренд", "hero.c": "наче знятий на телефон", "hero.p": "Завантажте фото, виберіть танець і натисніть одну кнопку. За кілька хвилин — вертикальне відео для TikTok.", "hero.cta": "Зробити свій танець",
        "step3": "Місце й окуляри", "step3s": "Де танцювати і, якщо соромитеся, — в окулярах", "place": "Де танцює", "gl.on": "Надіти окуляри", "gl.hint": "Окуляри будуть на обличчі все відео", "gl.pick": "Які окуляри",
        "pl.photo": "Як на фото", "pl.street": "Вулиця", "pl.room": "Кімната", "pl.gym": "Танцювальна студія", "pl.party": "Домашня вечірка", "pl.beach": "Пляж", "pl.park": "Парк", "pl.kitchen": "Кухня", "pl.office": "Офіс", "pl.club": "Нічний клуб", "pl.rooftop": "Дах на заході сонця",
        "gl.black": "Чорні сонцезахисні", "gl.aviator": "Авіатори", "gl.round": "Круглі ретро", "gl.mirror": "Спортивні дзеркальні", "gl.cateye": "«Котяче око»", "gl.heart": "Сердечка", "gl.clear": "Прозорі в чорній оправі", "pack.start": "Старт", "pack.pop": "Тренд", "pack.pro": "Студія", "pack.hit": "ХІТ", "bal.videos": "Вистачить на {v} по {s} сек", "bal.none": "Відео {s} сек = {p} 💎",
        "set.title": "Налаштування", "set.share": "Поділитися застосунком", "set.shareMsg": "Оживи фото — нехай станцює тренд із TikTok", "set.rate": "Оцінити застосунок", "set.write": "Написати розробникам", "set.terms": "Умови використання", "set.eula": "Ліцензійна угода (EULA)", "set.privacy": "Політика конфіденційності",
        "ex.h2a": "Приклади: ", "ex.before.w": "до", "ex.and": " і ", "ex.after.w": "після", "ex.hint": "Було одне фото — стало відео. Натисніть на відео, щоб увімкнути звук.", "ex.before": "ДО", "ex.after": "ПІСЛЯ", "ex.user": "ви",
        "buy.xcode": "Тестова покупка в Xcode пройшла. Справжні рубіни нараховуються лише при покупці через TestFlight або App Store.", "secs": "{s} сек", "photo.lib": "Вибрати фото", "rubies": "рубінів",
    ],
    .de: [
        "tagline": "Foto → TikTok-Tanz",
        "step1": "Foto der Person", "step1s": "Ganzkörper, Gesicht gut sichtbar",
        "slot.1": "Ganzkörper", "slot.1s": "erforderlich", "slot.2": "Gesicht nah", "slot.3": "Andere Perspektive", "opt": "optional",
        "step2": "Trend-Clip", "step2s": "Beliebige Länge: Wir nehmen die ersten 15 s. Eine tanzende Person im Ganzkörperbild.",
        "ref.pick": "Video wählen", "ref.change": "Ändern", "ref.trends": "Trends auf TikTok finden", "ref.cut": "Langer Clip: Wir nehmen die ersten {s} s.",
        "consent": "Ich habe die Zustimmung der Person auf dem Foto, sie ist 18+. Ich verletze keine Rechte anderer.",
        "go": "Video erstellen", "inc": "Kling 2.6 · Ton aus dem Clip · KI-Kennzeichnung",
        "err.photo": "Füge ein Ganzkörperfoto hinzu.", "err.ref": "Füge einen Clip mit dem Trend-Tanz hinzu.", "err.consent": "Bestätige die Zustimmung und 18+.",
        "err.net": "Keine Verbindung zum Server. Prüfe dein Internet.", "err.video": "Das Video konnte nicht gelesen werden. Versuche ein anderes.",
        "busy.photo": "Foto {n} wird hochgeladen…", "busy.ref": "Clip wird hochgeladen…", "busy.start": "Wird gestartet…",
        "work.title": "Dein Video entsteht", "work.sub": "Meist 3–6 Minuten. Du kannst die App schließen — das Video landet in „Meine Videos“.",
        "done": "Fertig!", "save": "In Fotos sichern", "saved": "In Fotos gesichert ✅", "share": "Teilen", "tiktok": "Auf TikTok posten",
        "tt.hint": "Beschreibung kopiert — wähle TikTok und füge sie ein.", "again": "Noch eins",
        "mine": "Meine Videos", "mine.empty": "Hier erscheinen deine Videos. Sie werden 7 Tage gespeichert.", "del": "Löschen", "del.q": "Dieses Video löschen?",
        "st.working": "Wird erstellt…", "st.failed": "Fehlgeschlagen — Rubine erstattet", "st.done": "Fertig",
        "wallet": "Rubine", "balance": "Guthaben", "buy": "Rubine kaufen", "buy.need": "Du brauchst {n} 💎, du hast {m} 💎.",
        "buy.ok": "+{n} 💎 gutgeschrieben", "buy.pending": "Der Kauf wartet auf Bestätigung.", "buy.fail": "Kauf fehlgeschlagen: {e}",
        "buy.load": "App-Store-Preise werden geladen…", "buy.none": "Käufe sind gerade nicht verfügbar. Versuche es später.",
        "code": "Dein Code", "code.hint": "Mit diesem Code meldest du dich auf jedem Gerät und auf snapdance.us an. Bewahre ihn gut auf.",
        "code.copy": "Kopieren", "code.copied": "Code kopiert", "code.enter": "Ich habe schon einen Code", "code.ph": "SD-XXXX-XXXX-XXXX", "code.login": "Anmelden",
        "code.bad": "Code nicht gefunden.", "logout": "Abmelden", "logout.q": "Abmelden? Ohne den Code verlierst du den Zugriff auf deine Rubine.",
        "privacy": "Datenschutz", "terms": "Bedingungen", "report": "Video melden", "close": "Schließen", "cancel": "Abbrechen", "ok": "OK",
        "videos7": "Das Video wird 7 Tage gespeichert",
        "pack.videos": "{v} bis 15 s", "hero.a": "Ein Foto — ", "hero.b": "ein Trend-Tanz", "hero.c": "wie mit dem Handy gefilmt", "hero.p": "Lade ein Foto hoch, wähle einen Tanz und tippe auf einen Button. In wenigen Minuten hast du ein Hochformat-Video für TikTok.", "hero.cta": "Meinen Tanz erstellen",
        "step3": "Ort und Brille", "step3s": "Wo getanzt wird und, wenn du schüchtern bist, mit Brille", "place": "Wo getanzt wird", "gl.on": "Brille tragen", "gl.hint": "Die Brille bleibt das ganze Video auf", "gl.pick": "Welche Brille",
        "pl.photo": "Wie auf dem Foto", "pl.street": "Straße", "pl.room": "Schlafzimmer", "pl.gym": "Tanzstudio", "pl.party": "Hausparty", "pl.beach": "Strand", "pl.park": "Park", "pl.kitchen": "Küche", "pl.office": "Büro", "pl.club": "Nachtclub", "pl.rooftop": "Dachterrasse bei Sonnenuntergang",
        "gl.black": "Schwarze Sonnenbrille", "gl.aviator": "Pilotenbrille", "gl.round": "Rund retro", "gl.mirror": "Sport verspiegelt", "gl.cateye": "Cat-Eye", "gl.heart": "Herzen", "gl.clear": "Klar, schwarzer Rahmen", "pack.start": "Starter", "pack.pop": "Trend", "pack.pro": "Studio", "pack.hit": "TOP", "bal.videos": "Reicht für {v} à {s} s", "bal.none": "Ein {s}-Sekunden-Video = {p} 💎",
        "set.title": "Einstellungen", "set.share": "App teilen", "set.shareMsg": "Lass dein Foto den TikTok-Trend tanzen", "set.rate": "App bewerten", "set.write": "Den Entwicklern schreiben", "set.terms": "Nutzungsbedingungen", "set.eula": "Lizenzvereinbarung (EULA)", "set.privacy": "Datenschutzerklärung",
        "ex.h2a": "Beispiele: ", "ex.before.w": "vorher", "ex.and": " und ", "ex.after.w": "nachher", "ex.hint": "Aus einem Foto wurde ein Video. Tippe auf ein Video, um den Ton einzuschalten.", "ex.before": "VORHER", "ex.after": "NACHHER", "ex.user": "du",
        "buy.xcode": "Xcode-Testkauf abgeschlossen. Echte Rubine gibt es nur bei Käufen über TestFlight oder den App Store.", "secs": "{s} s", "photo.lib": "Foto wählen", "rubies": "Rubine",
    ],
    .fr: [
        "tagline": "Photo → danse TikTok",
        "step1": "Photo de la personne", "step1s": "En pied, visage bien visible",
        "slot.1": "En pied", "slot.1s": "obligatoire", "slot.2": "Visage en gros plan", "slot.3": "Autre angle", "opt": "facultatif",
        "step2": "Vidéo tendance", "step2s": "Toute durée : on prend les 15 premières secondes. Un seul danseur en pied.",
        "ref.pick": "Choisir une vidéo", "ref.change": "Changer", "ref.trends": "Trouver des tendances sur TikTok", "ref.cut": "Vidéo longue : on prend les {s} premières s.",
        "consent": "J'ai l'accord de la personne sur la photo et elle a 18 ans ou plus. Je ne viole les droits de personne.",
        "go": "Créer la vidéo", "inc": "Kling 2.6 · son de la vidéo · mention IA",
        "err.photo": "Ajoute une photo en pied.", "err.ref": "Ajoute une vidéo avec la danse tendance.", "err.consent": "Coche l'accord et 18+.",
        "err.net": "Impossible de joindre le serveur. Vérifie ta connexion.", "err.video": "Impossible de lire la vidéo. Essaie-en une autre.",
        "busy.photo": "Envoi de la photo {n}…", "busy.ref": "Envoi de la vidéo…", "busy.start": "Lancement…",
        "work.title": "Création de ta vidéo", "work.sub": "En général 3 à 6 minutes. Tu peux fermer l'app : la vidéo sera dans « Mes vidéos ».",
        "done": "C'est prêt !", "save": "Enregistrer dans Photos", "saved": "Enregistrée dans Photos ✅", "share": "Partager", "tiktok": "Publier sur TikTok",
        "tt.hint": "Légende copiée : choisis TikTok et colle-la dans la description.", "again": "En créer une autre",
        "mine": "Mes vidéos", "mine.empty": "Tes vidéos apparaîtront ici. Elles sont conservées 7 jours.", "del": "Supprimer", "del.q": "Supprimer cette vidéo ?",
        "st.working": "Création…", "st.failed": "Échec — rubis remboursés", "st.done": "Prête",
        "wallet": "Rubis", "balance": "Solde", "buy": "Acheter des rubis", "buy.need": "Il te faut {n} 💎, tu as {m} 💎.",
        "buy.ok": "+{n} 💎 ajoutés", "buy.pending": "L'achat attend une validation.", "buy.fail": "Échec de l'achat : {e}",
        "buy.load": "Chargement des prix App Store…", "buy.none": "Les achats ne sont pas disponibles pour le moment. Réessaie plus tard.",
        "code": "Ton code", "code.hint": "Ce code te permet de te connecter sur n'importe quel appareil et sur snapdance.us. Garde-le bien.",
        "code.copy": "Copier", "code.copied": "Code copié", "code.enter": "J'ai déjà un code", "code.ph": "SD-XXXX-XXXX-XXXX", "code.login": "Se connecter",
        "code.bad": "Code introuvable.", "logout": "Se déconnecter", "logout.q": "Se déconnecter ? Sans le code, tu perdras l'accès à tes rubis.",
        "privacy": "Confidentialité", "terms": "Conditions", "report": "Signaler une vidéo", "close": "Fermer", "cancel": "Annuler", "ok": "OK",
        "videos7": "La vidéo est conservée 7 jours",
        "pack.videos": "{v} jusqu'à 15 s", "hero.a": "Une photo — ", "hero.b": "une danse tendance", "hero.c": "comme filmée au téléphone", "hero.p": "Envoie une photo, choisis une danse et appuie sur un bouton. En quelques minutes, tu as une vidéo verticale prête pour TikTok.", "hero.cta": "Créer ma danse",
        "step3": "Lieu et lunettes", "step3s": "Où danser et, si tu es timide, avec des lunettes", "place": "Où danser", "gl.on": "Porter des lunettes", "gl.hint": "Les lunettes restent pendant toute la vidéo", "gl.pick": "Quelles lunettes",
        "pl.photo": "Comme sur la photo", "pl.street": "Rue", "pl.room": "Chambre", "pl.gym": "Studio de danse", "pl.party": "Soirée à la maison", "pl.beach": "Plage", "pl.park": "Parc", "pl.kitchen": "Cuisine", "pl.office": "Bureau", "pl.club": "Boîte de nuit", "pl.rooftop": "Toit au coucher du soleil",
        "gl.black": "Lunettes de soleil noires", "gl.aviator": "Aviateur", "gl.round": "Rondes rétro", "gl.mirror": "Sport miroir", "gl.cateye": "Œil-de-chat", "gl.heart": "Cœurs", "gl.clear": "Transparentes, monture noire", "pack.start": "Starter", "pack.pop": "Tendance", "pack.pro": "Studio", "pack.hit": "TOP", "bal.videos": "Assez pour {v} de {s} s", "bal.none": "Une vidéo de {s} s = {p} 💎",
        "set.title": "Réglages", "set.share": "Partager l'app", "set.shareMsg": "Fais danser ta photo sur la tendance TikTok", "set.rate": "Noter l'app", "set.write": "Écrire aux développeurs", "set.terms": "Conditions d'utilisation", "set.eula": "Contrat de licence (EULA)", "set.privacy": "Politique de confidentialité",
        "ex.h2a": "Exemples : ", "ex.before.w": "avant", "ex.and": " et ", "ex.after.w": "après", "ex.hint": "Une photo est devenue une vidéo. Appuie sur une vidéo pour activer le son.", "ex.before": "AVANT", "ex.after": "APRÈS", "ex.user": "toi",
        "buy.xcode": "Achat test Xcode effectué. Les vrais rubis ne sont ajoutés que pour les achats via TestFlight ou l'App Store.", "secs": "{s} s", "photo.lib": "Choisir une photo", "rubies": "rubis",
    ],
    .sv: [
        "tagline": "Foto → TikTok-dans",
        "step1": "Foto på personen", "step1s": "Helfigur, ansiktet syns tydligt",
        "slot.1": "Helfigur", "slot.1s": "krävs", "slot.2": "Ansikte nära", "slot.3": "Annan vinkel", "opt": "valfritt",
        "step2": "Trendklipp", "step2s": "Valfri längd: vi använder de första 15 s. En dansare i helfigur.",
        "ref.pick": "Välj video", "ref.change": "Byt", "ref.trends": "Hitta trender på TikTok", "ref.cut": "Långt klipp: vi använder de första {s} s.",
        "consent": "Jag har samtycke från personen på fotot och hen är 18+. Jag kränker inte någons rättigheter.",
        "go": "Skapa video", "inc": "Kling 2.6 · ljud från klippet · AI-märkning",
        "err.photo": "Lägg till ett helfigursfoto.", "err.ref": "Lägg till ett klipp med trenddansen.", "err.consent": "Bekräfta samtycke och 18+.",
        "err.net": "Kan inte nå servern. Kontrollera din anslutning.", "err.video": "Kunde inte läsa videon. Prova en annan.",
        "busy.photo": "Laddar upp foto {n}…", "busy.ref": "Laddar upp klipp…", "busy.start": "Startar…",
        "work.title": "Din video skapas", "work.sub": "Oftast 3–6 minuter. Du kan stänga appen — videon hamnar i ”Mina videor”.",
        "done": "Klart!", "save": "Spara i Bilder", "saved": "Sparad i Bilder ✅", "share": "Dela", "tiktok": "Publicera på TikTok",
        "tt.hint": "Bildtext kopierad — välj TikTok och klistra in den i beskrivningen.", "again": "Skapa en till",
        "mine": "Mina videor", "mine.empty": "Dina videor visas här. De sparas i 7 dagar.", "del": "Radera", "del.q": "Radera den här videon?",
        "st.working": "Skapas…", "st.failed": "Misslyckades — rubiner återbetalda", "st.done": "Klar",
        "wallet": "Rubiner", "balance": "Saldo", "buy": "Köp rubiner", "buy.need": "Du behöver {n} 💎, du har {m} 💎.",
        "buy.ok": "+{n} 💎 tillagda", "buy.pending": "Köpet väntar på godkännande.", "buy.fail": "Köpet misslyckades: {e}",
        "buy.load": "Laddar App Store-priser…", "buy.none": "Köp är inte tillgängliga just nu. Försök senare.",
        "code": "Din kod", "code.hint": "Med den här koden loggar du in på alla enheter och på snapdance.us. Spara den.",
        "code.copy": "Kopiera", "code.copied": "Koden kopierad", "code.enter": "Jag har redan en kod", "code.ph": "SD-XXXX-XXXX-XXXX", "code.login": "Logga in",
        "code.bad": "Koden hittades inte.", "logout": "Logga ut", "logout.q": "Logga ut? Utan koden förlorar du åtkomsten till dina rubiner.",
        "privacy": "Integritet", "terms": "Villkor", "report": "Anmäl en video", "close": "Stäng", "cancel": "Avbryt", "ok": "OK",
        "videos7": "Videon sparas i 7 dagar",
        "pack.videos": "{v} upp till 15 s", "hero.a": "Ett foto — ", "hero.b": "en trenddans", "hero.c": "som filmad med mobilen", "hero.p": "Ladda upp ett foto, välj en dans och tryck på en knapp. Om några minuter har du en stående video klar för TikTok.", "hero.cta": "Skapa min dans",
        "step3": "Plats och glasögon", "step3s": "Var dansen sker och, om du är blyg, med glasögon", "place": "Var hen dansar", "gl.on": "Bär glasögon", "gl.hint": "Glasögonen sitter på hela videon", "gl.pick": "Vilka glasögon",
        "pl.photo": "Som på fotot", "pl.street": "Gata", "pl.room": "Sovrum", "pl.gym": "Dansstudio", "pl.party": "Hemmafest", "pl.beach": "Strand", "pl.park": "Park", "pl.kitchen": "Kök", "pl.office": "Kontor", "pl.club": "Nattklubb", "pl.rooftop": "Takterrass i solnedgång",
        "gl.black": "Svarta solglasögon", "gl.aviator": "Pilotglasögon", "gl.round": "Runda retro", "gl.mirror": "Sport, spegelglas", "gl.cateye": "Cat-eye", "gl.heart": "Hjärtan", "gl.clear": "Klara, svart båge", "pack.start": "Start", "pack.pop": "Trend", "pack.pro": "Studio", "pack.hit": "BÄST", "bal.videos": "Räcker till {v} à {s} s", "bal.none": "En video på {s} s = {p} 💎",
        "set.title": "Inställningar", "set.share": "Dela appen", "set.shareMsg": "Låt ditt foto dansa TikTok-trenden", "set.rate": "Betygsätt appen", "set.write": "Skriv till utvecklarna", "set.terms": "Användarvillkor", "set.eula": "Licensavtal (EULA)", "set.privacy": "Integritetspolicy",
        "ex.h2a": "Exempel: ", "ex.before.w": "före", "ex.and": " och ", "ex.after.w": "efter", "ex.hint": "Ett foto blev en video. Tryck på en video för att slå på ljudet.", "ex.before": "FÖRE", "ex.after": "EFTER", "ex.user": "du",
        "buy.xcode": "Xcode-testköp genomfört. Riktiga rubiner läggs bara till vid köp via TestFlight eller App Store.", "secs": "{s} s", "photo.lib": "Välj foto", "rubies": "rubiner",
    ],
    .es: [
        "tagline": "Foto → baile de TikTok",
        "step1": "Foto de la persona", "step1s": "De cuerpo entero, con la cara bien visible",
        "slot.1": "Cuerpo entero", "slot.1s": "obligatoria", "slot.2": "Cara de cerca", "slot.3": "Otro ángulo", "opt": "opcional",
        "step2": "Vídeo con el trend", "step2s": "Cualquier duración: usamos los primeros 15 s. Una persona de cuerpo entero.",
        "ref.pick": "Elegir vídeo", "ref.change": "Cambiar", "ref.trends": "Buscar trends en TikTok", "ref.cut": "El vídeo es largo: usaremos los primeros {s} s.",
        "consent": "Tengo el consentimiento de la persona de la foto y es mayor de 18 años. No infrinjo derechos de nadie.",
        "go": "Crear vídeo", "inc": "Kling 2.6 · sonido del vídeo · etiqueta IA",
        "err.photo": "Añade una foto de cuerpo entero.", "err.ref": "Añade un vídeo con el baile viral.", "err.consent": "Marca el permiso y 18+.",
        "err.net": "Sin conexión con el servidor. Revisa internet.", "err.video": "No pudimos leer el vídeo. Prueba con otro.",
        "busy.photo": "Subiendo foto {n}…", "busy.ref": "Subiendo vídeo…", "busy.start": "Empezando…",
        "work.title": "Creando tu vídeo", "work.sub": "Suele tardar 3–6 minutos. Puedes cerrar la app: el vídeo quedará en «Mis vídeos».",
        "done": "¡Listo!", "save": "Guardar en Fotos", "saved": "Guardado en Fotos ✅", "share": "Compartir", "tiktok": "Publicar en TikTok",
        "tt.hint": "Texto copiado: elige TikTok y pégalo en la descripción.", "again": "Crear otro",
        "mine": "Mis vídeos", "mine.empty": "Aquí aparecerán tus vídeos. Se guardan 7 días.", "del": "Eliminar", "del.q": "¿Eliminar este vídeo?",
        "st.working": "Creando…", "st.failed": "No salió: rubíes devueltos", "st.done": "Listo",
        "wallet": "Rubíes", "balance": "Saldo", "buy": "Comprar rubíes", "buy.need": "Hacen falta {n} 💎, tienes {m} 💎.",
        "buy.ok": "+{n} 💎 añadidos", "buy.pending": "La compra está pendiente de aprobación.", "buy.fail": "La compra no se completó: {e}",
        "buy.load": "Cargando precios de App Store…", "buy.none": "Las compras no están disponibles ahora. Inténtalo más tarde.",
        "code": "Tu código", "code.hint": "Con este código entras desde cualquier dispositivo y en snapdance.us. Guárdalo.",
        "code.copy": "Copiar", "code.copied": "Código copiado", "code.enter": "Ya tengo un código", "code.ph": "SD-XXXX-XXXX-XXXX", "code.login": "Entrar",
        "code.bad": "Código no encontrado.", "logout": "Salir", "logout.q": "¿Salir? Sin el código perderás el acceso a tus rubíes.",
        "privacy": "Privacidad", "terms": "Términos", "report": "Denunciar un vídeo", "close": "Cerrar", "cancel": "Cancelar", "ok": "OK",
        "videos7": "El vídeo se guarda 7 días",
        "pack.videos": "{v} de hasta 15 s", "hero.a": "Una foto — ", "hero.b": "un baile de tendencia", "hero.c": "como grabado con el móvil", "hero.p": "Sube una foto, elige un baile y pulsa un botón. En unos minutos tienes un vídeo vertical listo para TikTok.", "hero.cta": "Crear mi baile",
        "step3": "Lugar y gafas", "step3s": "Dónde bailar y, si te da vergüenza, con gafas", "place": "Dónde baila", "gl.on": "Ponerse gafas", "gl.hint": "Las gafas estarán puestas todo el vídeo", "gl.pick": "Qué gafas",
        "pl.photo": "Como en la foto", "pl.street": "Calle", "pl.room": "Habitación", "pl.gym": "Estudio de baile", "pl.party": "Fiesta en casa", "pl.beach": "Playa", "pl.park": "Parque", "pl.kitchen": "Cocina", "pl.office": "Oficina", "pl.club": "Discoteca", "pl.rooftop": "Azotea al atardecer",
        "gl.black": "Gafas de sol negras", "gl.aviator": "Aviador", "gl.round": "Redondas retro", "gl.mirror": "Deportivas espejadas", "gl.cateye": "Ojo de gato", "gl.heart": "Corazones", "gl.clear": "Transparentes montura negra", "pack.start": "Inicio", "pack.pop": "Tendencia", "pack.pro": "Estudio", "pack.hit": "TOP", "bal.videos": "Te alcanza para {v} de {s} s", "bal.none": "Vídeo de {s} s = {p} 💎",
        "set.title": "Ajustes", "set.share": "Compartir la app", "set.shareMsg": "Haz que tu foto baile el trend de TikTok", "set.rate": "Valorar la app", "set.write": "Escribir a los desarrolladores", "set.terms": "Términos de uso", "set.eula": "Acuerdo de licencia (EULA)", "set.privacy": "Política de privacidad",
        "ex.h2a": "Ejemplos: ", "ex.before.w": "antes", "ex.and": " y ", "ex.after.w": "después", "ex.hint": "Era una foto — ahora es un vídeo. Toca el vídeo para activar el sonido.", "ex.before": "ANTES", "ex.after": "DESPUÉS", "ex.user": "tu_perfil",
        "buy.xcode": "Compra de prueba en Xcode completada. Los rubíes reales solo se añaden al comprar desde TestFlight o App Store.", "secs": "{s} s", "photo.lib": "Elegir foto", "rubies": "rubíes",
    ],
    .en: [
        "tagline": "Photo → TikTok dance",
        "step1": "Photo of the person", "step1s": "Full body, face clearly visible",
        "slot.1": "Full body", "slot.1s": "required", "slot.2": "Face close-up", "slot.3": "Another angle", "opt": "optional",
        "step2": "Trend clip", "step2s": "Any length: we use the first 15 s. One dancer in full body.",
        "ref.pick": "Choose video", "ref.change": "Change", "ref.trends": "Find trends on TikTok", "ref.cut": "Long clip: we'll use the first {s} s.",
        "consent": "I have consent from the person in the photo and they are 18+. I'm not violating anyone's rights.",
        "go": "Make video", "inc": "Kling 2.6 · sound from the clip · AI label",
        "err.photo": "Add a full-body photo.", "err.ref": "Add a clip with the viral dance.", "err.consent": "Tick the permission and 18+ box.",
        "err.net": "Can't reach the server. Check your connection.", "err.video": "Couldn't read the video. Try another one.",
        "busy.photo": "Uploading photo {n}…", "busy.ref": "Uploading clip…", "busy.start": "Starting…",
        "work.title": "Making your video", "work.sub": "Usually 3–6 minutes. You can close the app — the video will be in “My videos”.",
        "done": "Done!", "save": "Save to Photos", "saved": "Saved to Photos ✅", "share": "Share", "tiktok": "Post to TikTok",
        "tt.hint": "Caption copied — pick TikTok and paste it into the description.", "again": "Make another",
        "mine": "My videos", "mine.empty": "Your videos will show up here. They're kept for 7 days.", "del": "Delete", "del.q": "Delete this video?",
        "st.working": "Making…", "st.failed": "Failed — rubies refunded", "st.done": "Done",
        "wallet": "Rubies", "balance": "Balance", "buy": "Buy rubies", "buy.need": "You need {n} 💎, you have {m} 💎.",
        "buy.ok": "+{n} 💎 added", "buy.pending": "The purchase is waiting for approval.", "buy.fail": "Purchase failed: {e}",
        "buy.load": "Loading App Store prices…", "buy.none": "Purchases aren't available right now. Try later.",
        "code": "Your code", "code.hint": "Use this code to sign in on any device and on snapdance.us. Keep it safe.",
        "code.copy": "Copy", "code.copied": "Code copied", "code.enter": "I already have a code", "code.ph": "SD-XXXX-XXXX-XXXX", "code.login": "Sign in",
        "code.bad": "Code not found.", "logout": "Sign out", "logout.q": "Sign out? Without the code you'll lose access to your rubies.",
        "privacy": "Privacy", "terms": "Terms", "report": "Report a video", "close": "Close", "cancel": "Cancel", "ok": "OK",
        "videos7": "The video is kept for 7 days",
        "pack.videos": "{v} up to 15 s", "hero.a": "One photo — ", "hero.b": "a trending dance", "hero.c": "that looks shot on a phone", "hero.p": "Upload a photo, pick a dance and tap one button. In a few minutes you get a vertical video ready for TikTok.", "hero.cta": "Make my dance",
        "step3": "Place and glasses", "step3s": "Where to dance and, if you're shy, wear glasses", "place": "Where they dance", "gl.on": "Wear glasses", "gl.hint": "The glasses stay on for the whole video", "gl.pick": "Which glasses",
        "pl.photo": "Like in the photo", "pl.street": "Street", "pl.room": "Bedroom", "pl.gym": "Dance studio", "pl.party": "House party", "pl.beach": "Beach", "pl.park": "Park", "pl.kitchen": "Kitchen", "pl.office": "Office", "pl.club": "Nightclub", "pl.rooftop": "Rooftop at sunset",
        "gl.black": "Black sunglasses", "gl.aviator": "Aviators", "gl.round": "Round retro", "gl.mirror": "Sport mirrored", "gl.cateye": "Cat-eye", "gl.heart": "Hearts", "gl.clear": "Clear, black frame", "pack.start": "Starter", "pack.pop": "Trend", "pack.pro": "Studio", "pack.hit": "BEST", "bal.videos": "Enough for {v} of {s} s", "bal.none": "A {s}-second video = {p} 💎",
        "set.title": "Settings", "set.share": "Share the app", "set.shareMsg": "Make your photo dance the TikTok trend", "set.rate": "Rate the app", "set.write": "Write to the developers", "set.terms": "Terms of Use", "set.eula": "License Agreement (EULA)", "set.privacy": "Privacy Policy",
        "ex.h2a": "Examples: ", "ex.before.w": "before", "ex.and": " and ", "ex.after.w": "after", "ex.hint": "One photo became a video. Tap a video to turn the sound on.", "ex.before": "BEFORE", "ex.after": "AFTER", "ex.user": "you",
        "buy.xcode": "Xcode test purchase completed. Real rubies are only added for purchases made via TestFlight or the App Store.", "secs": "{s} s", "photo.lib": "Choose photo", "rubies": "rubies",
    ],
]
