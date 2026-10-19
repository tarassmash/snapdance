// SnapDance: сервер собран в один файл.
var __defProp = Object.defineProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};

// src/tr.mjs
var T = [
  [/^Код не найден\. Купи(те пакет|те рубины)/, "C\xF3digo no encontrado. Compra rub\xEDes o introduce tu c\xF3digo.", "Code not found. Buy rubies or enter your code."],
  [/^Код не найден\.$/, "C\xF3digo no encontrado.", "Code not found."],
  [/^Нужно 💎 (\d+), на балансе 💎 (\d+)/, "Necesitas \u{1F48E} $1 y tienes \u{1F48E} $2. Recarga rub\xEDes.", "You need \u{1F48E} $1 and have \u{1F48E} $2. Top up rubies."],
  [/^Рубины закончились/, "Te has quedado sin rub\xEDes. Recarga el saldo.", "You're out of rubies. Top up your balance."],
  [/^Не удалось запустить генерацию/, "No se pudo iniciar la generaci\xF3n. Te hemos devuelto los rub\xEDes.", "Couldn't start the generation. Your rubies were refunded."],
  [/^Подтвердите, что у вас есть согласие/, "Confirma que tienes el consentimiento de la persona de la foto y que es mayor de 18 a\xF1os.", "Confirm you have consent from the person in the photo and that they are 18+."],
  [/^Загрузите фото человека/, "Sube una foto de la persona de cuerpo entero.", "Upload a full-body photo of the person."],
  [/^Фото не найдено/, "No encontramos la foto: s\xFAbela otra vez.", "Photo not found: please upload it again."],
  [/^Ролик не найден/, "No encontramos el v\xEDdeo: s\xFAbelo otra vez.", "Video not found: please upload it again."],
  [/^Нужно фото: JPG/, "Necesitamos una foto: JPG, PNG o WEBP.", "A photo is needed: JPG, PNG or WEBP."],
  [/^Нужен видеофайл/, "Necesitamos un v\xEDdeo: MP4, MOV o WEBM.", "A video file is needed: MP4, MOV or WEBM."],
  [/^Файл слишком большой \(максимум (\d+) МБ\)/, "El archivo es demasiado grande (m\xE1ximo $1 MB).", "The file is too large (max $1 MB)."],
  [/^Файл пустой или повреждён/, "El archivo est\xE1 vac\xEDo o da\xF1ado.", "The file is empty or damaged."],
  [/^Ролик (\d+) сек — нужно не больше 30/, "El v\xEDdeo dura $1 s: m\xE1ximo 30. Rec\xF3rtalo en la galer\xEDa del m\xF3vil.", "The clip is $1 s long: 30 max. Trim it in your phone's gallery."],
  [/^Ролик слишком короткий/, "El v\xEDdeo es demasiado corto: hacen falta al menos 2\u20133 segundos de baile.", "The clip is too short: at least 2\u20133 seconds of dancing needed."],
  [/^Не получилось прочитать ролик/, "No pudimos leer el v\xEDdeo. Prueba con un MP4 del m\xF3vil.", "Couldn't read the clip. Try an MP4 from your phone."],
  [/^Не получилось прочитать видео/, "No pudimos leer el v\xEDdeo.", "Couldn't read the video."],
  [/^Неверный файл/, "Archivo no v\xE1lido.", "Invalid file."],
  [/^Некорректный запрос/, "Solicitud no v\xE1lida.", "Invalid request."],
  [/^Некорректный платёж/, "Pago no v\xE1lido.", "Invalid payment."],
  [/^Слишком большой запрос/, "La solicitud es demasiado grande.", "The request is too large."],
  [/^Пакет не найден/, "Paquete no encontrado.", "Pack not found."],
  [/^Оплата ещё не подключена/, "Los pagos a\xFAn no est\xE1n activados.", "Payments aren't enabled yet."],
  [/^Платёж ещё не подтверждён/, "El pago a\xFAn no est\xE1 confirmado. Recarga la p\xE1gina en un minuto.", "The payment isn't confirmed yet. Reload the page in a minute."],
  [/^Оплата: /, "No se pudo abrir el pago. Int\xE9ntalo m\xE1s tarde o escr\xEDbenos.", "Couldn't open checkout. Try again later or contact us."],
  [/^Видео не найдено/, "V\xEDdeo no encontrado.", "Video not found."],
  [/^Дождитесь окончания генерации/, "Espera a que termine la generaci\xF3n.", "Wait until the generation finishes."],
  [/^Не получилось придумать подпись/, "No se pudo generar el texto.", "Couldn't write a caption."],
  [/^На сервере не задан FAL_KEY/, "El servicio est\xE1 en mantenimiento. Int\xE9ntalo m\xE1s tarde.", "The service is under maintenance. Try again later."],
  [/^Не найдено$/, "No encontrado.", "Not found."],
  [/^Внутренняя ошибка сервера/, "Error interno del servidor. Int\xE9ntalo de nuevo.", "Internal server error. Please try again."]
];
var langOf = (req) => {
  const l = String(req.headers["x-lang"] || "").toLowerCase();
  return l === "en" || l === "ru" ? l : "es";
};
function tr(msg, lang) {
  if (lang === "ru" || !msg) return msg;
  for (const [re, es, en] of T) {
    const m = msg.match(re);
    if (m) return (lang === "en" ? en : es).replace(/\$(\d)/g, (_, i) => m[i] ?? "");
  }
  return msg;
}

// src/server.mjs
import http from "node:http";
import fs6 from "node:fs";
import path6 from "node:path";
import crypto3 from "node:crypto";
import { fileURLToPath } from "node:url";

// src/db.mjs
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
var DATA_DIR = process.env.RAILWAY_VOLUME_MOUNT_PATH || process.env.DATA_DIR || path.resolve("data");
var PERSISTENT = Boolean(process.env.RAILWAY_VOLUME_MOUNT_PATH || process.env.DATA_DIR);
var FILE = path.join(DATA_DIR, "snapdance-db.json");
var DEFAULT_PACKS = [
  { id: "start", credits: 200, price: 14.99, name: { es: "Inicio", en: "Starter", ru: "\u0421\u0442\u0430\u0440\u0442" }, popular: false },
  { id: "pop", credits: 600, price: 39.99, name: { es: "Tendencia", en: "Trend", ru: "\u0422\u0440\u0435\u043D\u0434" }, popular: true },
  { id: "pro", credits: 1500, price: 89.99, name: { es: "Estudio", en: "Studio", ru: "\u0421\u0442\u0443\u0434\u0438\u044F" }, popular: false }
];
var empty = () => ({
  keys: {},
  // KEY -> { credits, email, created, source, note, spent }
  orders: [],
  // { id, key, email, pack, credits, amount, currency, created }
  jobs: [],
  // задачи генерации танца
  uploads: {},
  // file -> { key, created }
  settings: { packs: DEFAULT_PACKS, currency: "eur", marketing: { ga4: "", fbPixel: "", tiktokPixel: "", gscMeta: "", enableAIOpt: true } }
});
var db = empty();
try {
  fs.mkdirSync(DATA_DIR, { recursive: true });
  if (fs.existsSync(FILE)) db = { ...empty(), ...JSON.parse(fs.readFileSync(FILE, "utf8")) };
} catch (e) {
  console.error("\u041D\u0435 \u0443\u0434\u0430\u043B\u043E\u0441\u044C \u043F\u0440\u043E\u0447\u0438\u0442\u0430\u0442\u044C \u0431\u0430\u0437\u0443:", e.message);
}
var timer = null;
function save() {
  clearTimeout(timer);
  timer = setTimeout(flush, 200);
}
function flush() {
  try {
    const tmp = FILE + ".tmp";
    fs.writeFileSync(tmp, JSON.stringify(db));
    fs.renameSync(tmp, FILE);
  } catch (e) {
    console.error("\u041D\u0435 \u0443\u0434\u0430\u043B\u043E\u0441\u044C \u0441\u043E\u0445\u0440\u0430\u043D\u0438\u0442\u044C \u0431\u0430\u0437\u0443:", e.message);
  }
}
process.on("SIGTERM", () => {
  flush();
  process.exit(0);
});
var ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
function newKey() {
  let k;
  do {
    const b = crypto.randomBytes(12);
    const chars = [...b].map((x) => ALPHABET[x % ALPHABET.length]).join("");
    k = `SD-${chars.slice(0, 4)}-${chars.slice(4, 8)}-${chars.slice(8, 12)}`;
  } while (db.keys[k]);
  return k;
}
var normKey = (k) => String(k || "").trim().toUpperCase();
var newId = () => crypto.randomBytes(8).toString("hex");

// src/fal.mjs
var fal_exports = {};
__export(fal_exports, {
  COST_PER_IMAGE: () => COST_PER_IMAGE,
  MODEL: () => MODEL,
  RESOLUTION: () => RESOLUTION,
  UserError: () => UserError,
  falError: () => falError,
  falFetch: () => falFetch,
  falKey: () => falKey,
  probe: () => probe,
  submit: () => submit
});
var MODEL = process.env.FAL_MODEL || "fal-ai/nano-banana-pro/edit";
var RESOLUTION = process.env.FAL_RESOLUTION || "2K";
var COST_PER_IMAGE = parseFloat(process.env.FAL_COST_PER_IMAGE || "0.15");
var UserError = class extends Error {
  constructor(message, status = 400) {
    super(message);
    this.status = status;
  }
};
function falKey() {
  const k = (process.env.FAL_KEY || process.env.FAL_API_KEY || "").trim();
  if (!k) throw new UserError("\u041D\u0430 \u0441\u0435\u0440\u0432\u0435\u0440\u0435 \u043D\u0435 \u0437\u0430\u0434\u0430\u043D FAL_KEY. Railway \u2192 \u0441\u0435\u0440\u0432\u0438\u0441 \u2192 Variables.", 500);
  return k;
}
async function falFetch(url, opts = {}) {
  const res = await fetch(url, {
    ...opts,
    headers: { authorization: "Key " + falKey(), "content-type": "application/json", ...opts.headers || {} }
  });
  const text = await res.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    data = { raw: text };
  }
  return { ok: res.ok, status: res.status, data };
}
function falError(status, data) {
  let d = data?.detail ?? data?.error ?? data?.message ?? data?.raw ?? "";
  if (Array.isArray(d)) d = d.map((x) => x.msg || JSON.stringify(x)).join("; ");
  else if (typeof d === "object") d = JSON.stringify(d);
  d = String(d);
  if (status === 402 || /balance|credit|locked|billing/i.test(d)) return { msg: "\u0421\u0435\u0440\u0432\u0438\u0441 \u0432\u0440\u0435\u043C\u0435\u043D\u043D\u043E \u043D\u0435\u0434\u043E\u0441\u0442\u0443\u043F\u0435\u043D. \u041F\u043E\u043F\u0440\u043E\u0431\u0443\u0439\u0442\u0435 \u043F\u043E\u0437\u0436\u0435.", admin: "\u041D\u0430 \u0430\u043A\u043A\u0430\u0443\u043D\u0442\u0435 fal.ai \u0437\u0430\u043A\u043E\u043D\u0447\u0438\u043B\u0441\u044F \u0431\u0430\u043B\u0430\u043D\u0441." };
  if (status === 401 || status === 403) return { msg: "\u0421\u0435\u0440\u0432\u0438\u0441 \u0432\u0440\u0435\u043C\u0435\u043D\u043D\u043E \u043D\u0435\u0434\u043E\u0441\u0442\u0443\u043F\u0435\u043D. \u041F\u043E\u043F\u0440\u043E\u0431\u0443\u0439\u0442\u0435 \u043F\u043E\u0437\u0436\u0435.", admin: `fal.ai \u043D\u0435 \u043F\u0440\u0438\u043D\u044F\u043B \u043A\u043B\u044E\u0447 (${status}).` };
  if (/nsfw|safety|content policy|flagged/i.test(d)) return { msg: "\u0417\u0430\u043F\u0440\u043E\u0441 \u043D\u0435 \u043F\u0440\u043E\u0448\u0451\u043B \u043F\u0440\u043E\u0432\u0435\u0440\u043A\u0443 \u0431\u0435\u0437\u043E\u043F\u0430\u0441\u043D\u043E\u0441\u0442\u0438. \u0418\u0437\u043C\u0435\u043D\u0438\u0442\u0435 \u043E\u043F\u0438\u0441\u0430\u043D\u0438\u0435 \u0438\u043B\u0438 \u0442\u0435\u043A\u0441\u0442.", admin: d.slice(0, 200) };
  return { msg: "\u041D\u0435 \u0443\u0434\u0430\u043B\u043E\u0441\u044C \u0437\u0430\u043F\u0443\u0441\u0442\u0438\u0442\u044C \u0433\u0435\u043D\u0435\u0440\u0430\u0446\u0438\u044E. \u041A\u0440\u0435\u0434\u0438\u0442\u044B \u0432\u043E\u0437\u0432\u0440\u0430\u0449\u0435\u043D\u044B, \u043F\u043E\u043F\u0440\u043E\u0431\u0443\u0439\u0442\u0435 \u0435\u0449\u0451 \u0440\u0430\u0437.", admin: `(${status}) ${d.slice(0, 300)}` };
}
async function submit(input) {
  const url = `https://queue.fal.run/${MODEL}`;
  const full = { ...input, aspect_ratio: input.aspect_ratio, resolution: RESOLUTION };
  let r = await falFetch(url, { method: "POST", body: JSON.stringify(full) });
  if (r.status === 422) {
    const { aspect_ratio, resolution, ...base } = full;
    r = await falFetch(url, { method: "POST", body: JSON.stringify(base) });
  }
  return r;
}
async function probe() {
  const key = (process.env.FAL_KEY || process.env.FAL_API_KEY || "").trim();
  if (!key) return { ok: false, text: "FAL_KEY \u043D\u0435 \u0437\u0430\u0434\u0430\u043D" };
  try {
    const app = MODEL.split("/").slice(0, 2).join("/");
    const r = await fetch(`https://queue.fal.run/${app}/requests/00000000-0000-0000-0000-000000000000/status`, { headers: { authorization: "Key " + key } });
    const t = await r.text();
    if (/balance|locked|billing/i.test(t)) return { ok: false, text: "\u041A\u043B\u044E\u0447 \u0432\u0435\u0440\u043D\u044B\u0439, \u043D\u043E \u0437\u0430\u043A\u043E\u043D\u0447\u0438\u043B\u0441\u044F \u0431\u0430\u043B\u0430\u043D\u0441 fal.ai" };
    if (r.status === 401 || r.status === 403) return { ok: false, text: "fal.ai \u043D\u0435 \u043F\u0440\u0438\u043D\u044F\u043B \u043A\u043B\u044E\u0447" };
    return { ok: true, text: "\u041A\u043B\u044E\u0447 \u043F\u0440\u0438\u043D\u044F\u0442" };
  } catch (e) {
    return { ok: false, text: "\u041D\u0435\u0442 \u0441\u0432\u044F\u0437\u0438 \u0441 fal.ai: " + e.message };
  }
}

// src/stripe.mjs
import crypto2 from "node:crypto";
var SK = () => (process.env.STRIPE_SECRET_KEY || "").trim();
var stripeEnabled = () => /^(sk|rk)_/.test(SK());
var stripeMode = () => /_live_/.test(SK()) ? "live" : /_test_/.test(SK()) ? "test" : "";
var webhookEnabled = () => Boolean((process.env.STRIPE_WEBHOOK_SECRET || "").trim());
var STRIPE_API = process.env.STRIPE_API_BASE || "https://api.stripe.com";
function form(obj, prefix = "", out = []) {
  for (const [k, v] of Object.entries(obj)) {
    if (v === void 0 || v === null) continue;
    const key = prefix ? `${prefix}[${k}]` : k;
    if (typeof v === "object") form(v, key, out);
    else out.push(encodeURIComponent(key) + "=" + encodeURIComponent(String(v)));
  }
  return out.join("&");
}
async function stripe(method, path7, body2) {
  const res = await fetch(STRIPE_API + path7, {
    method,
    headers: { authorization: "Bearer " + SK(), "content-type": "application/x-www-form-urlencoded" },
    body: body2 ? form(body2) : void 0
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = String(data?.error?.message || `\u043E\u0448\u0438\u0431\u043A\u0430 ${res.status}`);
    console.error("Stripe:", res.status, msg);
    throw new UserError(explain(msg, res.status), 502);
  }
  return data;
}
function explain(msg, status) {
  if (status === 401 || /invalid api key|no api key|expired api key/i.test(msg)) return "\u041E\u043F\u043B\u0430\u0442\u0430: Stripe \u043D\u0435 \u043F\u0440\u0438\u043D\u044F\u043B \u043A\u043B\u044E\u0447. \u041F\u0440\u043E\u0432\u0435\u0440\u044C\u0442\u0435 STRIPE_SECRET_KEY \u0432 Railway \u2192 Variables (\u043A\u043B\u044E\u0447 sk_live_\u2026 \u0438\u043B\u0438 sk_test_\u2026 \u0446\u0435\u043B\u0438\u043A\u043E\u043C, \u0431\u0435\u0437 \u043F\u0440\u043E\u0431\u0435\u043B\u043E\u0432).";
  if (/url/i.test(msg) && /valid|invalid/i.test(msg)) return "\u041E\u043F\u043B\u0430\u0442\u0430: Stripe \u043D\u0435 \u043F\u0440\u0438\u043D\u044F\u043B \u0430\u0434\u0440\u0435\u0441 \u0441\u0430\u0439\u0442\u0430. \u041F\u0440\u043E\u0432\u0435\u0440\u044C\u0442\u0435 PUBLIC_URL \u0432 Railway \u2192 Variables: https://\u0432\u0430\u0448-\u0430\u0434\u0440\u0435\u0441, \u0431\u0435\u0437 / \u0432 \u043A\u043E\u043D\u0446\u0435.";
  if (/live charges|activate|activation|account.*(not|cannot)|charges_enabled/i.test(msg)) return "\u041E\u043F\u043B\u0430\u0442\u0430: \u0430\u043A\u043A\u0430\u0443\u043D\u0442 Stripe \u0435\u0449\u0451 \u043D\u0435 \u0430\u043A\u0442\u0438\u0432\u0438\u0440\u043E\u0432\u0430\u043D \u0434\u043B\u044F \u043F\u0440\u0438\u0451\u043C\u0430 \u043F\u043B\u0430\u0442\u0435\u0436\u0435\u0439. \u0417\u0430\u0432\u0435\u0440\u0448\u0438\u0442\u0435 \u0430\u043A\u0442\u0438\u0432\u0430\u0446\u0438\u044E \u0432 Stripe (\u0434\u0430\u043D\u043D\u044B\u0435 \u0431\u0438\u0437\u043D\u0435\u0441\u0430 \u0438 \u0431\u0430\u043D\u043A\u043E\u0432\u0441\u043A\u0438\u0439 \u0441\u0447\u0451\u0442) \u0438\u043B\u0438 \u0432\u0440\u0435\u043C\u0435\u043D\u043D\u043E \u0438\u0441\u043F\u043E\u043B\u044C\u0437\u0443\u0439\u0442\u0435 \u0442\u0435\u0441\u0442\u043E\u0432\u044B\u0439 \u043A\u043B\u044E\u0447 sk_test_\u2026.";
  if (/permission|restricted/i.test(msg)) return "\u041E\u043F\u043B\u0430\u0442\u0430: \u0443 \u043A\u043B\u044E\u0447\u0430 Stripe \u043D\u0435 \u0445\u0432\u0430\u0442\u0430\u0435\u0442 \u043F\u0440\u0430\u0432. \u0418\u0441\u043F\u043E\u043B\u044C\u0437\u0443\u0439\u0442\u0435 Secret key (sk_\u2026) \u0438\u043B\u0438 \u0434\u0430\u0439\u0442\u0435 \u043A\u043B\u044E\u0447\u0443 \u043F\u0440\u0430\u0432\u0430 \u043D\u0430 Checkout Sessions.";
  if (/currency/i.test(msg)) return "\u041E\u043F\u043B\u0430\u0442\u0430: Stripe \u043D\u0435 \u043F\u0440\u0438\u043D\u0438\u043C\u0430\u0435\u0442 \u044D\u0442\u0443 \u0432\u0430\u043B\u044E\u0442\u0443 \u0434\u043B\u044F \u0432\u0430\u0448\u0435\u0433\u043E \u0430\u043A\u043A\u0430\u0443\u043D\u0442\u0430. \u041F\u043E\u043C\u0435\u043D\u044F\u0439\u0442\u0435 \u0432\u0430\u043B\u044E\u0442\u0443 \u043F\u0430\u043A\u0435\u0442\u043E\u0432 \u0432 \u0430\u0434\u043C\u0438\u043D\u043A\u0435.";
  if (/amount/i.test(msg)) return "\u041E\u043F\u043B\u0430\u0442\u0430: Stripe \u043D\u0435 \u043F\u0440\u0438\u043D\u044F\u043B \u0441\u0443\u043C\u043C\u0443 \u043F\u0430\u043A\u0435\u0442\u0430 (\u0441\u043B\u0438\u0448\u043A\u043E\u043C \u043C\u0430\u043B\u0435\u043D\u044C\u043A\u0430\u044F?). \u041F\u0440\u043E\u0432\u0435\u0440\u044C\u0442\u0435 \u0446\u0435\u043D\u044B \u043F\u0430\u043A\u0435\u0442\u043E\u0432 \u0432 \u0430\u0434\u043C\u0438\u043D\u043A\u0435.";
  return "\u041E\u043F\u043B\u0430\u0442\u0430: Stripe \u043E\u0442\u0432\u0435\u0442\u0438\u043B \u043E\u0448\u0438\u0431\u043A\u043E\u0439 \u2014 " + msg.slice(0, 200);
}
async function check() {
  if (!stripeEnabled()) return { ok: false, text: "\u043D\u0435 \u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0451\u043D (STRIPE_SECRET_KEY)" };
  try {
    await stripe("GET", "/v1/checkout/sessions?limit=1");
    return { ok: true, text: `\u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0451\u043D (${stripeMode() === "live" ? "\u0431\u043E\u0435\u0432\u043E\u0439 \u0440\u0435\u0436\u0438\u043C" : "\u0442\u0435\u0441\u0442\u043E\u0432\u044B\u0439 \u0440\u0435\u0436\u0438\u043C"})` };
  } catch (e) {
    return { ok: false, text: e.message };
  }
}
function createCheckout({ pack, currency: currency2, key, origin: origin2, lang, brand }) {
  return stripe("POST", "/v1/checkout/sessions", {
    mode: "payment",
    locale: ["es", "en", "ru"].includes(lang) ? lang : "es",
    success_url: `${origin2}/?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${origin2}/?canceled=1`,
    allow_promotion_codes: "true",
    line_items: {
      0: {
        quantity: 1,
        price_data: {
          currency: currency2,
          unit_amount: Math.round(pack.price * 100),
          product_data: {
            name: `${brand} \u2014 ${pack.name?.[lang] || pack.name?.es || pack.name?.en || pack.name?.ru || pack.id}`,
            description: { en: `${pack.credits} rubies for AI dance videos`, ru: `${pack.credits} \u0440\u0443\u0431\u0438\u043D\u043E\u0432 \u043D\u0430 \u0442\u0430\u043D\u0446\u0435\u0432\u0430\u043B\u044C\u043D\u044B\u0435 \u0432\u0438\u0434\u0435\u043E`, es: `${pack.credits} rub\xEDes para v\xEDdeos de baile con IA` }[lang] || `${pack.credits} rub\xEDes para v\xEDdeos de baile con IA`
          }
        }
      }
    },
    metadata: { pack: pack.id, credits: pack.credits, key: key || "" }
  });
}
var retrieveSession = (id) => stripe("GET", `/v1/checkout/sessions/${encodeURIComponent(id)}`);
function verifyWebhook(raw, header) {
  const secret = (process.env.STRIPE_WEBHOOK_SECRET || "").trim();
  if (!secret || !header) return null;
  const parts = Object.fromEntries(header.split(",").map((p) => p.split("=")));
  const t = parts.t;
  const sigs = header.split(",").filter((p) => p.startsWith("v1=")).map((p) => p.slice(3));
  if (!t || !sigs.length) return null;
  if (Math.abs(Date.now() / 1e3 - Number(t)) > 600) return null;
  const expected = crypto2.createHmac("sha256", secret).update(`${t}.${raw}`).digest("hex");
  const ok = sigs.some((s) => s.length === expected.length && crypto2.timingSafeEqual(Buffer.from(s), Buffer.from(expected)));
  if (!ok) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

// src/engine.mjs
import fs2 from "node:fs";
import path2 from "node:path";
var MEDIA_DIR = path2.join(DATA_DIR, "media");
fs2.mkdirSync(MEDIA_DIR, { recursive: true });
var TIMEOUT = 25 * 60 * 1e3;
async function submit2(endpoint, input, optional = []) {
  const url = `https://queue.fal.run/${endpoint}`;
  let r = await falFetch(url, { method: "POST", body: JSON.stringify(input) });
  if (r.status === 422 && optional.length) {
    const slim = { ...input };
    for (const k of optional) delete slim[k];
    r = await falFetch(url, { method: "POST", body: JSON.stringify(slim) });
  }
  if (r.ok && r.data.request_id) return { ok: true, job: { endpoint, statusUrl: r.data.status_url, responseUrl: r.data.response_url, started: Date.now() } };
  return { ok: false, error: falError(r.status, r.data), status: r.status, data: r.data };
}
async function check2(job) {
  if (!job) return { state: "failed", error: "\u043D\u0435\u0442 \u0437\u0430\u0434\u0430\u0447\u0438" };
  const st = await falFetch(job.statusUrl);
  if (!st.ok) return st.status >= 400 && st.status < 500 ? { state: "failed", error: falError(st.status, st.data).admin } : { state: "working" };
  if (st.data.status !== "COMPLETED") return Date.now() - job.started > TIMEOUT ? { state: "failed", error: "\u0441\u043B\u0438\u0448\u043A\u043E\u043C \u0434\u043E\u043B\u0433\u043E" } : { state: "working", queue: st.data.queue_position ?? null };
  const out = await falFetch(job.responseUrl);
  if (!out.ok) return { state: "failed", error: falError(out.status, out.data).admin };
  if (out.data?.error) return { state: "failed", error: String(out.data.error).slice(0, 300) };
  return { state: "done", data: out.data };
}
var urlOf = (x) => typeof x === "string" ? x : x?.url;
var imagesOf = (d) => (d?.images || (d?.image ? [d.image] : [])).map(urlOf).filter(Boolean);
var videoOf = (d) => urlOf(d?.video);
var EXT = { "video/webm": "webm", "image/png": "png", "image/webp": "webp", "image/jpeg": "jpg", "audio/mpeg": "mp3", "audio/mp3": "mp3", "audio/wav": "wav", "audio/x-wav": "wav", "video/mp4": "mp4", "video/quicktime": "mov" };
var extFor = (type, fallback) => EXT[String(type || "").split(";")[0].trim()] || fallback;
function removeMedia(prefix) {
  for (const f of fs2.readdirSync(MEDIA_DIR)) if (f.startsWith(prefix)) fs2.rmSync(path2.join(MEDIA_DIR, f), { force: true });
}
async function saveRemote(url, name, fallbackExt) {
  const r = await fetch(url);
  if (!r.ok) throw new Error("\u043D\u0435 \u0443\u0434\u0430\u043B\u043E\u0441\u044C \u0441\u043A\u0430\u0447\u0430\u0442\u044C \u0444\u0430\u0439\u043B");
  const ext = extFor(r.headers.get("content-type"), fallbackExt);
  removeMedia(name + ".");
  const file = `${name}.${ext}`;
  fs2.writeFileSync(path2.join(MEDIA_DIR, file), Buffer.from(await r.arrayBuffer()));
  return `/media/${file}`;
}
var TYPE = { webm: "video/webm", m4v: "video/mp4", jpg: "image/jpeg", png: "image/png", webp: "image/webp", mp3: "audio/mpeg", wav: "audio/wav", mp4: "video/mp4", mov: "video/quicktime" };
var fileOf = (mediaPath) => path2.join(MEDIA_DIR, String(mediaPath).replace(/^\/media\//, "").replace(/\?.*$/, ""));
function cleanOrigin(u) {
  let v = String(u || "").trim().replace(/^["']|["']$/g, "");
  if (!v) return "";
  if (!/^https?:\/\//i.test(v)) v = "https://" + v;
  try {
    return new URL(v).origin;
  } catch {
    return "";
  }
}
var ORIGIN = cleanOrigin(process.env.PUBLIC_URL);
function noteOrigin(o) {
  if (!process.env.PUBLIC_URL && o && !/localhost|127\.0\.0\.1/.test(o)) ORIGIN = o.replace(/\/$/, "");
}
var publicUrl = (mediaPath) => ORIGIN && mediaPath ? ORIGIN + String(mediaPath).replace(/\?.*$/, "") : "";
var ref = (mediaPath) => publicUrl(mediaPath) || toDataUrl(mediaPath);
function toDataUrl(mediaPath) {
  const f = fileOf(mediaPath);
  const ext = path2.extname(f).slice(1);
  return `data:${TYPE[ext] || "application/octet-stream"};base64,${fs2.readFileSync(f).toString("base64")}`;
}
var mediaExists = (mediaPath) => !!mediaPath && fs2.existsSync(fileOf(mediaPath));
function serveMedia(req, res, name) {
  if (!/^[\w-]+\.(jpg|png|webp|mp3|wav|mp4|mov|webm|m4v)$/.test(name)) return false;
  const file = path2.join(MEDIA_DIR, name);
  if (!fs2.existsSync(file)) return false;
  const size = fs2.statSync(file).size;
  const type = TYPE[path2.extname(name).slice(1)];
  const base = { "content-type": type, "accept-ranges": "bytes", "cache-control": "public, max-age=604800", "x-content-type-options": "nosniff" };
  const range = /^bytes=(\d*)-(\d*)$/.exec(req.headers.range || "");
  if (range) {
    let start = range[1] === "" ? size - Number(range[2]) : Number(range[1]);
    let end = range[1] !== "" && range[2] !== "" ? Number(range[2]) : size - 1;
    if (isNaN(start) || start < 0 || start >= size || end < start) {
      res.writeHead(416, { "content-range": `bytes */${size}` });
      res.end();
      return true;
    }
    end = Math.min(end, size - 1);
    res.writeHead(206, { ...base, "content-range": `bytes ${start}-${end}/${size}`, "content-length": end - start + 1 });
    fs2.createReadStream(file, { start, end }).pipe(res);
    return true;
  }
  res.writeHead(200, { ...base, "content-length": size });
  if (req.method === "HEAD") {
    res.end();
    return true;
  }
  fs2.createReadStream(file).pipe(res);
  return true;
}
function diskUsage() {
  let bytes = 0, files = 0;
  for (const f of fs2.readdirSync(MEDIA_DIR)) {
    bytes += fs2.statSync(path2.join(MEDIA_DIR, f)).size;
    files++;
  }
  return { bytes, files };
}
async function saveUpload(req, name, ext, limit) {
  const file = `${name}.${ext}`, full = path2.join(MEDIA_DIR, file);
  let size = 0;
  const out = fs2.createWriteStream(full);
  try {
    for await (const c of req) {
      size += c.length;
      if (size > limit) throw new UserError(`\u0424\u0430\u0439\u043B \u0441\u043B\u0438\u0448\u043A\u043E\u043C \u0431\u043E\u043B\u044C\u0448\u043E\u0439 (\u043C\u0430\u043A\u0441\u0438\u043C\u0443\u043C ${Math.round(limit / 1e6)} \u041C\u0411).`, 413);
      if (!out.write(c)) await new Promise((r) => out.once("drain", r));
    }
    await new Promise((ok, no) => out.end((e) => e ? no(e) : ok()));
  } catch (e) {
    out.destroy();
    fs2.rmSync(full, { force: true });
    throw e;
  }
  if (size < 1e3) {
    fs2.rmSync(full, { force: true });
    throw new UserError("\u0424\u0430\u0439\u043B \u043F\u0443\u0441\u0442\u043E\u0439 \u0438\u043B\u0438 \u043F\u043E\u0432\u0440\u0435\u0436\u0434\u0451\u043D.");
  }
  return { path: `/media/${file}`, size };
}

// src/catalog.mjs
var TREND_MODELS = [
  { id: "mc26", tier: 1, name: "Kling 2.6", ep: "fal-ai/kling-video/v2.6/standard/motion-control", usd: 0.07, elements: false },
  { id: "mc3s", tier: 2, name: "Kling 3 Standard", ep: "fal-ai/kling-video/v3/standard/motion-control", usd: 0.126, elements: true },
  { id: "mc3p", tier: 3, name: "Kling 3 Pro", ep: "fal-ai/kling-video/v3/pro/motion-control", usd: 0.168, elements: true }
];
var STYLE_MODELS = [
  {
    id: "hailuo512",
    tier: 1,
    name: "Hailuo 02 \xB7 512p",
    note: "\u041C\u044F\u0433\u043A\u0430\u044F \xAB\u0442\u0435\u043B\u0435\u0444\u043E\u043D\u043D\u0430\u044F\xBB \u043A\u0430\u0440\u0442\u0438\u043D\u043A\u0430",
    usd: 0.017,
    durs: [6, 10],
    audio: false,
    ep: "fal-ai/minimax/hailuo-02/standard/image-to-video",
    input: (img, p, d) => ({ prompt: p, image_url: img, duration: String(d), resolution: "512P", prompt_optimizer: false })
  },
  {
    id: "hailuo768",
    tier: 1,
    name: "Hailuo 02 \xB7 768p",
    note: "\u0427\u0451\u0442\u0447\u0435, \u0445\u043E\u0440\u043E\u0448\u0438\u0435 \u0434\u0432\u0438\u0436\u0435\u043D\u0438\u044F",
    usd: 0.045,
    durs: [6, 10],
    audio: false,
    ep: "fal-ai/minimax/hailuo-02/standard/image-to-video",
    input: (img, p, d) => ({ prompt: p, image_url: img, duration: String(d), resolution: "768P", prompt_optimizer: false })
  },
  {
    id: "kling25",
    tier: 2,
    name: "Kling 2.5 Turbo Pro",
    note: "\u041F\u043B\u0430\u0432\u043D\u044B\u0435 \u0434\u0432\u0438\u0436\u0435\u043D\u0438\u044F, \u0434\u0435\u0440\u0436\u0438\u0442 \u043B\u0438\u0446\u043E",
    usd: 0.07,
    durs: [5, 10],
    audio: false,
    ep: "fal-ai/kling-video/v2.5-turbo/pro/image-to-video",
    input: (img, p, d) => ({ prompt: p, image_url: img, duration: String(d), negative_prompt: "blur, distorted face, extra limbs, deformed hands" })
  },
  {
    id: "veo31fast",
    tier: 2,
    name: "Veo 3.1 Fast",
    note: "\u0421\u043E \u0437\u0432\u0443\u043A\u043E\u043C, \u043E\u0447\u0435\u043D\u044C \u0440\u0435\u0430\u043B\u0438\u0441\u0442\u0438\u0447\u043D\u043E",
    usd: 0.15,
    durs: [4, 6, 8],
    audio: true,
    ep: "fal-ai/veo3.1/fast/image-to-video",
    input: (img, p, d) => ({ prompt: p, image_url: img, aspect_ratio: "9:16", duration: `${d}s`, resolution: "720p", generate_audio: true })
  },
  {
    id: "kling3",
    tier: 3,
    name: "Kling 3 Pro",
    note: "\u0422\u043E\u043F \u043F\u043E \u0434\u0432\u0438\u0436\u0435\u043D\u0438\u044F\u043C \u0438 \u043B\u0438\u0446\u0443, \u0441\u043E \u0437\u0432\u0443\u043A\u043E\u043C",
    usd: 0.168,
    durs: [5, 8, 10, 15],
    audio: true,
    elements: true,
    ep: "fal-ai/kling-video/v3/pro/image-to-video",
    input: (img, p, d, face, refs) => ({ prompt: `@Element1 is the person in the image. ${p}`, start_image_url: img, duration: String(d), generate_audio: true, elements: [{ frontal_image_url: face, reference_image_urls: refs }] })
  },
  {
    id: "veo31",
    tier: 3,
    name: "Veo 3.1",
    note: "\u041C\u0430\u043A\u0441\u0438\u043C\u0430\u043B\u044C\u043D\u0430\u044F \u043A\u0430\u0440\u0442\u0438\u043D\u043A\u0430 \u0438 \u0437\u0432\u0443\u043A",
    usd: 0.4,
    durs: [4, 6, 8],
    audio: true,
    ep: "fal-ai/veo3.1/image-to-video",
    input: (img, p, d) => ({ prompt: p, image_url: img, aspect_ratio: "9:16", duration: `${d}s`, resolution: "720p", generate_audio: true })
  }
];
var FRAME_MODELS = [
  { id: "nbpro", name: "Nano Banana Pro", ep: "fal-ai/nano-banana-pro/edit", usd: 0.15 },
  { id: "nb", name: "Nano Banana", ep: "fal-ai/nano-banana/edit", usd: 0.039 },
  { id: "none", name: "\u0411\u0435\u0437 \u043A\u0430\u0434\u0440\u0430", ep: "", usd: 0 }
];
var FACE_EP = process.env.FAL_FACESWAP_MODEL || "half-moon-ai/ai-face-swap/faceswapvideo";
var UPSCALE_EP = "fal-ai/topaz/upscale/video";
var FX = { eur: 1.05, usd: 1, gbp: 1.25 };
var DEFAULT_ECON = {
  markup: 3,
  // во сколько раз клиент платит больше себестоимости fal.ai
  feePct: 4,
  // комиссия Stripe с запасом (карты из других стран + конвертация), %
  feeFixed: 0.3,
  // фиксированная часть комиссии Stripe, в валюте пакетов
  vat: 0,
  // НДС / IVA, если цены пакетов его включают, %
  fx: null,
  // курс валюты пакетов к $; null — по умолчанию для валюты
  lockUsd: 0.1,
  // face-lock: оценка $ за секунду (точной цены fal.ai не публикует)
  enhanceUsd: 0.04,
  // Topaz 1080p + 60 кадров, $ за секунду
  failReserve: 10,
  // запас на неудачные генерации, % (их стоимость fal.ai списывает, а клиенту возвращаем)
  usd: {}
  // свои цены fal.ai за модели, если поменялись: { modelId: $ }
};
db.settings.econ ||= {};
function econ() {
  const e = { ...DEFAULT_ECON, ...db.settings.econ, usd: { ...db.settings.econ?.usd || {} } };
  const cur = db.settings.currency || "eur";
  e.fxRate = Number(e.fx) > 0 ? Number(e.fx) : FX[cur] || 1;
  return e;
}
var usdOf = (m) => {
  const o = econ().usd[m.id];
  return Number(o) > 0 ? Number(o) : m.usd;
};
function rubyValueUsd() {
  const e = econ();
  const packs2 = db.settings.packs || [];
  if (!packs2.length) return 0.05;
  const net = packs2.map((p) => {
    const afterVat = p.price / (1 + (e.vat || 0) / 100);
    const afterFee = afterVat - p.price * (e.feePct / 100) - e.feeFixed;
    return Math.max(1e-4, afterFee / p.credits) * e.fxRate;
  });
  return Math.min(...net);
}
var rubiesPerUsd = () => econ().markup * (1 + econ().failReserve / 100) / rubyValueUsd();
function rates() {
  const k = rubiesPerUsd(), e = econ();
  const r2 = (x) => Math.round(x * 100) / 100;
  return {
    k,
    trend: Object.fromEntries(TREND_MODELS.map((m) => [m.id, r2(usdOf(m) * k)])),
    style: Object.fromEntries(STYLE_MODELS.map((m) => [m.id, r2(usdOf(m) * k)])),
    frame: Object.fromEntries(FRAME_MODELS.map((m) => [m.id, Math.ceil(usdOf(m) * k)])),
    lock: r2(e.lockUsd * k),
    enhance: r2(e.enhanceUsd * k)
  };
}
function quote(o) {
  const R = rates();
  const secs = Math.max(1, Math.ceil(o.seconds || 0));
  const parts = {
    frame: R.frame[o.frame] ?? 0,
    video: Math.ceil(secs * (o.mode === "trend" ? R.trend[o.model] ?? R.trend.mc3p : R.style[o.model] ?? R.style.kling25)),
    lock: o.faceLock ? Math.ceil(secs * R.lock) : 0,
    enhance: o.enhance ? Math.ceil(secs * R.enhance) : 0
  };
  return { total: Object.values(parts).reduce((a, b) => a + b, 0), parts };
}
function usdCost(o) {
  const e = econ(), secs = Math.max(1, Math.ceil(o.seconds || 0));
  const fr = usdOf(FRAME_MODELS.find((m) => m.id === o.frame) || FRAME_MODELS[2]);
  const vm = o.mode === "trend" ? TREND_MODELS.find((m) => m.id === o.model) : STYLE_MODELS.find((m) => m.id === o.model);
  return +(fr + usdOf(vm || STYLE_MODELS[2]) * secs + (o.enhance ? e.enhanceUsd * secs : 0) + (o.faceLock ? e.lockUsd * secs : 0)).toFixed(2);
}
function saveEcon(b) {
  const n = (v, d, min, max) => {
    const x = Number(v);
    return Number.isFinite(x) && x >= min && x <= max ? x : d;
  };
  const cur = econ();
  const usd = {};
  for (const m of [...TREND_MODELS, ...STYLE_MODELS, ...FRAME_MODELS]) {
    const v = Number(b.usd?.[m.id]);
    if (v > 0 && v !== m.usd) usd[m.id] = v;
  }
  db.settings.econ = {
    markup: n(b.markup, cur.markup, 1, 20),
    feePct: n(b.feePct, cur.feePct, 0, 20),
    feeFixed: n(b.feeFixed, cur.feeFixed, 0, 5),
    vat: n(b.vat, cur.vat, 0, 30),
    fx: Number(b.fx) > 0 ? n(b.fx, null, 0.1, 10) : null,
    lockUsd: n(b.lockUsd, cur.lockUsd, 0, 5),
    enhanceUsd: n(b.enhanceUsd, cur.enhanceUsd, 0, 5),
    failReserve: n(b.failReserve, cur.failReserve, 0, 100),
    usd
  };
  save();
}
function econReport() {
  const e = econ(), R = rates(), rv = rubyValueUsd();
  const cur = (db.settings.currency || "eur").toUpperCase();
  const packs2 = db.settings.packs || [];
  const best = packs2.reduce((a, p) => !a || p.price / p.credits < a.price / a.credits ? p : a, null);
  const rubyPrice = best ? best.price / best.credits : 0;
  const row = (label, o) => {
    const q = quote(o), cost = usdCost(o);
    return { label, rubies: q.total, client: +(q.total * rubyPrice).toFixed(2), net: +(q.total * rv).toFixed(2), cost, x: +(q.total * rv / Math.max(0.01, cost)).toFixed(2) };
  };
  return {
    econ: e,
    currency: cur,
    rubyValueUsd: +rv.toFixed(4),
    rubyPrice: +rubyPrice.toFixed(4),
    rubiesPerUsd: +R.k.toFixed(2),
    models: {
      trend: TREND_MODELS.map((m) => ({ id: m.id, name: m.name, usd: usdOf(m), def: m.usd, perSec: R.trend[m.id] })),
      style: STYLE_MODELS.map((m) => ({ id: m.id, name: m.name, usd: usdOf(m), def: m.usd, perSec: R.style[m.id] })),
      frame: FRAME_MODELS.filter((m) => m.ep).map((m) => ({ id: m.id, name: m.name, usd: usdOf(m), def: m.usd, price: R.frame[m.id] }))
    },
    examples: [
      row("\u0421\u0442\u0438\u043B\u044C Hailuo 768p, 6 \u0441\u0435\u043A", { mode: "style", model: "hailuo768", frame: "nb", enhance: false, seconds: 6 }),
      row("\u0421\u0442\u0438\u043B\u044C Kling 2.5, 10 \u0441\u0435\u043A, Full HD 60", { mode: "style", model: "kling25", frame: "nb", enhance: true, seconds: 10 }),
      row("\u0422\u0440\u0435\u043D\u0434 Kling 3 Std, 10 \u0441\u0435\u043A, Full HD 60", { mode: "trend", model: "mc3s", frame: "nb", enhance: true, seconds: 10 }),
      row("\u0422\u0440\u0435\u043D\u0434 Kling 3 Pro, 10 \u0441\u0435\u043A, \u0432\u0441\u0451 \u043B\u0443\u0447\u0448\u0435\u0435", { mode: "trend", model: "mc3p", frame: "nbpro", enhance: true, seconds: 10 }),
      row("\u0421\u0442\u0438\u043B\u044C Veo 3.1, 8 \u0441\u0435\u043A, \u0432\u0441\u0451 \u043B\u0443\u0447\u0448\u0435\u0435", { mode: "style", model: "veo31", frame: "nbpro", enhance: true, seconds: 8 }),
      row("\u0422\u0440\u0435\u043D\u0434 30 \u0441\u0435\u043A, Kling 3 Pro, \u0432\u0441\u0451 \u043B\u0443\u0447\u0448\u0435\u0435", { mode: "trend", model: "mc3p", frame: "nbpro", enhance: true, seconds: 30 })
    ]
  };
}
function publicCatalog() {
  const R = rates();
  return {
    trendModels: TREND_MODELS.map((m) => ({ id: m.id, tier: m.tier, name: m.name, perSec: R.trend[m.id] })),
    styleModels: STYLE_MODELS.map((m) => ({ id: m.id, tier: m.tier, name: m.name, note: m.note, durs: m.durs, audio: m.audio, perSec: R.style[m.id] })),
    frameModels: FRAME_MODELS.map((m) => ({ id: m.id, name: m.name, price: R.frame[m.id] })),
    faceLockPerSec: R.lock,
    enhancePerSec: R.enhance
  };
}

// src/dance.mjs
import fs4 from "node:fs";
import path4 from "node:path";

// src/post.mjs
import { spawn } from "node:child_process";
import fs3 from "node:fs";
import path3 from "node:path";
var FFMPEG = process.env.FFMPEG_PATH || "ffmpeg";
var FFPROBE = process.env.FFPROBE_PATH || "ffprobe";
function exec(bin, args, timeoutMs = 10 * 60 * 1e3) {
  return new Promise((ok, no) => {
    const p = spawn(bin, args, { stdio: ["ignore", "pipe", "pipe"] });
    let out = "", err = "";
    p.stdout.on("data", (d) => {
      out += d;
    });
    p.stderr.on("data", (d) => {
      err = (err + d).slice(-4e3);
    });
    const t = setTimeout(() => {
      p.kill("SIGKILL");
      no(new Error("ffmpeg: \u0441\u043B\u0438\u0448\u043A\u043E\u043C \u0434\u043E\u043B\u0433\u043E"));
    }, timeoutMs);
    p.on("error", (e) => {
      clearTimeout(t);
      no(new Error(`${bin} \u043D\u0435\u0434\u043E\u0441\u0442\u0443\u043F\u0435\u043D: ${e.message}`));
    });
    p.on("close", (code) => {
      clearTimeout(t);
      code === 0 ? ok(out) : no(new Error(`${path3.basename(bin)} (${code}): ${err.split("\n").filter(Boolean).slice(-2).join(" | ")}`));
    });
  });
}
async function hasFfmpeg() {
  try {
    await exec(FFMPEG, ["-version"], 1e4);
    return true;
  } catch {
    return false;
  }
}
async function probe2(src) {
  const out = await exec(FFPROBE, ["-v", "error", "-show_entries", "format=duration:stream=codec_type,width,height", "-of", "json", src], 6e4);
  const j = JSON.parse(out || "{}");
  const v = (j.streams || []).find((s) => s.codec_type === "video") || {};
  return { duration: Number(j.format?.duration) || 0, width: v.width || 0, height: v.height || 0, audio: (j.streams || []).some((s) => s.codec_type === "audio") };
}
var OUT = { w: 1080, h: 1920 };
var LOOKS = {
  cheap: { pre: "scale=480:-2:flags=bilinear,gblur=sigma=0.5,eq=contrast=1.1:saturation=0.9:brightness='0.02+0.025*sin(t*0.9)':eval=frame,colorbalance=rs=0.04:gs=0.03:bs=-0.04,noise=alls=16:allf=t+u", post: "" },
  oldiphone: { pre: "", post: "eq=contrast=1.04:saturation=1.04:brightness='0.01+0.01*sin(t*0.9)':eval=frame,colorbalance=rs=0.03:bs=-0.03,noise=alls=6:allf=t" },
  none: { pre: "", post: "" }
};
function fitFilter(w, h) {
  const { w: W, h: H } = OUT, ar = w && h ? w / h : 9 / 16;
  if (Math.abs(ar / (9 / 16) - 1) <= 0.15) return `scale=${W}:${H}:force_original_aspect_ratio=increase:flags=lanczos,crop=${W}:${H},setsar=1`;
  return `split[bg0][fg0];[bg0]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},boxblur=28:2,eq=brightness=-0.07:saturation=0.9[bg];[fg0]scale=${W}:${H}:force_original_aspect_ratio=decrease:flags=lanczos[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1`;
}
// водяной знак на каждом видео; WATERMARK_TEXT="" в Variables — отключить
var WATERMARK = (process.env.WATERMARK_TEXT ?? "snapdance.us").trim();
var WM_FONT = [process.env.WATERMARK_FONT, "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"].find((f) => f && fs3.existsSync(f)) || "";
function watermarkFilter() {
  if (!WATERMARK) return "";
  const esc = (s) => s.replace(/\\/g, "\\\\").replace(/'/g, "\u2019").replace(/:/g, "\\:").replace(/%/g, "\\%");
  // слева, на 3/4 высоты: не перекрывается кнопками и подписью TikTok/Reels
  return `drawtext=${WM_FONT ? `fontfile='${esc(WM_FONT)}':` : ""}text='${esc(WATERMARK)}':fontsize=h/34:fontcolor=white@0.75:shadowcolor=black@0.55:shadowx=2:shadowy=2:x=w*0.05:y=h*0.74`;
}
async function watermarkOnly(src, out) {
  const wm = watermarkFilter();
  if (!wm) throw new Error("водяной знак отключён");
  await exec(FFMPEG, ["-y", "-hide_banner", "-loglevel", "error", "-i", src, "-vf", `${wm},format=yuv420p`, "-c:v", "libx264", "-preset", "fast", "-crf", "18", "-c:a", "copy", "-movflags", "+faststart", out]);
  if (!fs3.existsSync(out) || fs3.statSync(out).size < 1e4) throw new Error("ffmpeg: пустой результат");
  return out;
}
async function finish({ video, audioFrom, out, look = "none", startAt = 0, fps = 30 }) {
  const info = await probe2(video).catch(() => ({ duration: 0, width: 0, height: 0, audio: false }));
  const ss = info.duration > startAt + 2 ? startAt : 0;
  fps = fps > 30 ? 60 : 30;
  const L = LOOKS[look] || LOOKS.none;
  const useAudio = audioFrom && audioFrom !== video ? await probe2(audioFrom).then((x) => x.audio).catch(() => false) : false;
  const ownAudio = !useAudio && info.audio;
  const args = ["-y", "-hide_banner", "-loglevel", "error", "-ss", String(ss), "-i", video];
  if (useAudio) args.push("-ss", String(ss), "-i", audioFrom);
  if (!useAudio && !ownAudio) args.push("-f", "lavfi", "-i", "anullsrc=r=48000:cl=stereo");
  const chain = [L.pre, fitFilter(info.width, info.height), L.post, `fps=${fps}`, watermarkFilter(), "format=yuv420p"].filter(Boolean).join(",");
  const aIn = useAudio ? "1:a:0" : ownAudio ? "0:a:0" : "1:a:0";
  const kbps = fps > 30 ? 12e3 : 8e3;
  args.push(
    "-filter_complex",
    `[0:v:0]${chain}[v]`,
    "-map",
    "[v]",
    "-map",
    aIn,
    "-c:v",
    "libx264",
    "-preset",
    "fast",
    "-profile:v",
    "high",
    "-level:v",
    "4.2",
    "-b:v",
    `${kbps}k`,
    "-maxrate",
    `${Math.round(kbps * 1.25)}k`,
    "-bufsize",
    `${kbps * 2}k`,
    "-g",
    String(fps * 2),
    "-keyint_min",
    String(fps),
    "-sc_threshold",
    "0",
    "-bf",
    "2",
    "-colorspace",
    "bt709",
    "-color_primaries",
    "bt709",
    "-color_trc",
    "bt709",
    "-color_range",
    "tv",
    "-c:a",
    "aac",
    "-b:a",
    "192k",
    "-ar",
    "48000",
    "-ac",
    "2",
    "-shortest",
    "-movflags",
    "+faststart",
    "-brand",
    "mp42",
    out
  );
  await exec(FFMPEG, args);
  if (!fs3.existsSync(out) || fs3.statSync(out).size < 1e4) throw new Error("ffmpeg: \u043F\u0443\u0441\u0442\u043E\u0439 \u0440\u0435\u0437\u0443\u043B\u044C\u0442\u0430\u0442");
  return out;
}
async function poster(video, out) {
  await exec(FFMPEG, ["-y", "-hide_banner", "-loglevel", "error", "-ss", "0.8", "-i", video, "-frames:v", "1", "-vf", "scale=480:-2", "-q:v", "5", out], 6e4);
  return out;
}

// src/credits.mjs
function charge(key, n) {
  const rec = db.keys[key];
  if (!rec) throw new UserError("\u041A\u043E\u0434 \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D. \u041A\u0443\u043F\u0438\u0442\u0435 \u043F\u0430\u043A\u0435\u0442 \u0438\u043B\u0438 \u0432\u0432\u0435\u0434\u0438\u0442\u0435 \u043A\u043E\u0434.", 401);
  if (n <= 0) return;
  if (rec.credits < n) throw new UserError(rec.credits ? `\u041D\u0443\u0436\u043D\u043E \u{1F48E} ${n}, \u043D\u0430 \u0431\u0430\u043B\u0430\u043D\u0441\u0435 \u{1F48E} ${rec.credits}. \u041F\u043E\u043F\u043E\u043B\u043D\u0438\u0442\u0435 \u0440\u0443\u0431\u0438\u043D\u044B.` : "\u0420\u0443\u0431\u0438\u043D\u044B \u0437\u0430\u043A\u043E\u043D\u0447\u0438\u043B\u0438\u0441\u044C. \u041F\u043E\u043F\u043E\u043B\u043D\u0438\u0442\u0435 \u0431\u0430\u043B\u0430\u043D\u0441.", 402);
  rec.credits -= n;
  rec.spent = (rec.spent || 0) + n;
  save();
}
function refund(key, n) {
  const rec = db.keys[key];
  if (!rec || n <= 0) return;
  rec.credits += n;
  rec.spent = Math.max(0, (rec.spent || 0) - n);
  save();
}

// src/dance.mjs
db.jobs ||= [];
db.uploads ||= {};
var clean = (v, max) => String(v ?? "").replace(/\s+/g, " ").trim().slice(0, max);
var STYLES = [
  { id: "hands", icon: "\u{1F64C}", name: "\u0425\u0435\u043D\u0434-\u0434\u044D\u043D\u0441", hint: "\u0420\u0443\u043A\u0438 \u0438 \u043C\u0438\u043C\u0438\u043A\u0430, \u0432\u0438\u0440\u0443\u0441\u043D\u044B\u0439 \u0444\u043E\u0440\u043C\u0430\u0442", moves: "a viral TikTok hand-dance: quick precise arm and hand choreography in front of the chest, finger points, waves and claps on the beat, expressive face, feet mostly in place" },
  { id: "shuffle", icon: "\u{1F45F}", name: "\u0428\u0430\u0444\u0444\u043B", hint: "\u0411\u044B\u0441\u0442\u0440\u044B\u0435 \u043D\u043E\u0433\u0438, \u044D\u043D\u0435\u0440\u0433\u0438\u044F", moves: "a Melbourne shuffle: fast running-man and t-step footwork, gliding in place, arms swinging with energy" },
  { id: "groove", icon: "\u{1F3A7}", name: "\u0425\u0438\u043F-\u0445\u043E\u043F \u0433\u0440\u0443\u0432", hint: "\u0420\u0430\u0441\u0441\u043B\u0430\u0431\u043B\u0435\u043D\u043D\u043E \u0438 \u0441\u0442\u0438\u043B\u044C\u043D\u043E", moves: "a relaxed hip-hop groove: bounces, body rolls, shoulder hits, two-step and a confident pose at the end" },
  { id: "kpop", icon: "\u2B50", name: "K-pop \u0441\u0432\u044F\u0437\u043A\u0430", hint: "\u0427\u0451\u0442\u043A\u0430\u044F \u0445\u043E\u0440\u0435\u043E\u0433\u0440\u0430\u0444\u0438\u044F", moves: "a sharp K-pop style point choreography: crisp synchronized arm lines, quick turns, a cute finishing pose to the camera" },
  { id: "dad", icon: "\u{1F602}", name: "\u0421\u043C\u0435\u0448\u043D\u043E\u0439 \u043F\u0430\u043F\u0438\u043D \u0442\u0430\u043D\u0435\u0446", hint: "\u041D\u0435\u043B\u0435\u043F\u043E \u0438 \u0441\u043C\u0435\u0448\u043D\u043E", moves: "a hilarious awkward dad dance: goofy enthusiastic moves, finger guns, the sprinkler, the lawnmower, big proud smile, totally committed" },
  { id: "tecktonik", icon: "\u26A1", name: "\u042D\u043B\u0435\u043A\u0442\u0440\u043E", hint: "\u0422\u0435\u043A\u0442\u043E\u043D\u0438\u043A, \u0440\u0443\u043A\u0438-\u0432\u0441\u043F\u044B\u0448\u043A\u0438", moves: "an electro tecktonik dance: fast arm waves and wrist rolls around the head, sharp hits on every beat" },
  { id: "latin", icon: "\u{1F336}\uFE0F", name: "\u041B\u0430\u0442\u0438\u043D\u0430 \u0441\u043E\u043B\u043E", hint: "\u0421\u0430\u043B\u044C\u0441\u0430-\u0448\u0430\u0433\u0438, \u043B\u0451\u0433\u043A\u043E\u0441\u0442\u044C", moves: "a joyful solo salsa and bachata footwork: light steps, hip sways kept tasteful, a spin and a smile" },
  { id: "slow", icon: "\u{1F319}", name: "\u041F\u043B\u0430\u0432\u043D\u044B\u0439 \u0432\u0430\u0439\u0431", hint: "\u041C\u0435\u0434\u043B\u0435\u043D\u043D\u043E \u0438 \u044D\u0441\u0442\u0435\u0442\u0438\u0447\u043D\u043E", moves: "a slow aesthetic vibe dance: smooth waves, gentle sways, dreamy expression, graceful hand movements" }
];
var CAM = {
  tripod: "Shot on a smartphone front camera propped on a shelf: vertical 9:16, slight wide-angle phone lens look, auto-exposure, natural home lighting, subtle phone video compression, authentic amateur TikTok footage, static camera.",
  friend: "Filmed handheld on a smartphone by a friend: vertical 9:16, natural handheld micro-shake, slight reframing and follow, phone auto-exposure, authentic amateur TikTok footage.",
  mirror: "Selfie-style clip from a phone front camera held close, slightly too close at times, arm-length framing that shifts while dancing, authentic amateur TikTok footage."
};
var PHONE = {
  cheap: "Looks like an everyday clip recorded on a cheap budget Android phone: slightly soft focus, visible digital noise and grain in the shadows, mild video compression artifacts, highlights a bit blown out near windows and lamps, auto white balance slightly off and warm, occasional tiny focus hunting, ordinary room lighting. Not cinematic, no film look, no professional lighting, no color grading.",
  oldiphone: "Looks like a casual clip recorded on an older iPhone: natural phone sharpening, light grain in low light, warm indoor white balance, slight highlight roll-off, ordinary lighting. Not cinematic, no color grading.",
  none: ""
};
var PLACE = { photo: "Keep the same location, background and outfit as in the photo.", room: "In a cozy bedroom with fairy lights; keep the same outfit.", street: "Outdoors on a city sidewalk in daylight; keep the same outfit.", gym: "In a bright dance studio with a mirror wall; keep the same outfit.", party: "At a house party with colorful LED lights and blurred friends in the background; keep the same outfit." };
var FACE = "During fast moves, spins and head turns the face may blur briefly, but whenever it is visible it is exactly the same person as in the reference photos. The face must stay identical to the reference photo in every single frame: same eyes, nose, mouth, jawline, skin tone, hairline and expression style. No morphing, no face drift, no changing identity, no beauty filter. Keep the face mostly toward the camera and in focus; avoid long spins or turns that hide the face.";
var NEG = "Keep it tasteful and family-friendly: no suggestive or sexual moves. Keep the person's face, body, hairstyle and outfit exactly as in the photo. No text, captions, logos or watermarks.";
async function upload(req, key, kind) {
  const ct = String(req.headers["content-type"] || "").split(";")[0].trim().toLowerCase();
  const id = "u-" + newId();
  let ext, limit;
  if (kind === "photo") {
    ext = { "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp" }[ct];
    if (!ext) throw new UserError("\u041D\u0443\u0436\u043D\u043E \u0444\u043E\u0442\u043E: JPG, PNG \u0438\u043B\u0438 WEBP.");
    limit = 15e6;
  } else {
    ext = { "video/mp4": "mp4", "video/quicktime": "mov", "video/webm": "webm", "video/x-m4v": "m4v" }[ct] || (ct.startsWith("video/") ? "mp4" : "");
    if (!ext) throw new UserError("\u041D\u0443\u0436\u0435\u043D \u0432\u0438\u0434\u0435\u043E\u0444\u0430\u0439\u043B: MP4, MOV \u0438\u043B\u0438 WEBM.");
    limit = 12e7;
  }
  const r = await saveUpload(req, id, ext, limit);
  const file = path4.basename(r.path);
  const rec = { key, kind, created: Date.now(), path: r.path };
  if (kind === "video") {
    const info = await probe2(fileOf(r.path)).catch(() => null);
    if (!info || !info.duration) {
      removeMedia(id + ".");
      throw new UserError("\u041D\u0435 \u043F\u043E\u043B\u0443\u0447\u0438\u043B\u043E\u0441\u044C \u043F\u0440\u043E\u0447\u0438\u0442\u0430\u0442\u044C \u0440\u043E\u043B\u0438\u043A. \u041F\u043E\u043F\u0440\u043E\u0431\u0443\u0439\u0442\u0435 MP4 \u0441 \u0442\u0435\u043B\u0435\u0444\u043E\u043D\u0430.");
    }
    if (info.duration > 30.5) {
      removeMedia(id + ".");
      throw new UserError(`\u0420\u043E\u043B\u0438\u043A ${Math.round(info.duration)} \u0441\u0435\u043A \u2014 \u043D\u0443\u0436\u043D\u043E \u043D\u0435 \u0431\u043E\u043B\u044C\u0448\u0435 30. \u041E\u0431\u0440\u0435\u0436\u044C\u0442\u0435 \u0435\u0433\u043E \u0432 \u0433\u0430\u043B\u0435\u0440\u0435\u0435 \u0442\u0435\u043B\u0435\u0444\u043E\u043D\u0430.`);
    }
    if (info.duration < 2) {
      removeMedia(id + ".");
      throw new UserError("\u0420\u043E\u043B\u0438\u043A \u0441\u043B\u0438\u0448\u043A\u043E\u043C \u043A\u043E\u0440\u043E\u0442\u043A\u0438\u0439 \u2014 \u043D\u0443\u0436\u043D\u043E \u0445\u043E\u0442\u044F \u0431\u044B 2\u20133 \u0441\u0435\u043A\u0443\u043D\u0434\u044B \u0442\u0430\u043D\u0446\u0430.");
    }
    rec.duration = info.duration;
  }
  db.uploads[file] = rec;
  save();
  return { path: r.path, duration: rec.duration || 0 };
}
function ownUpload(key, p, kind) {
  const file = path4.basename(String(p || ""));
  const u = db.uploads[file];
  if (!u || u.key !== key || u.kind !== kind || !mediaExists(u.path)) throw new UserError(kind === "photo" ? "\u0424\u043E\u0442\u043E \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D\u043E \u2014 \u0437\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u0435\u0433\u043E \u0435\u0449\u0451 \u0440\u0430\u0437." : "\u0420\u043E\u043B\u0438\u043A \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D \u2014 \u0437\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u0435\u0433\u043E \u0435\u0449\u0451 \u0440\u0430\u0437.");
  return u;
}
function options(b) {
  const mode = b.mode === "style" ? "style" : "trend";
  const o = {
    mode,
    cam: CAM[b.cam] ? b.cam : "tripod",
    place: PLACE[b.place] ? b.place : "photo",
    phone: PHONE[b.phone] !== void 0 ? b.phone : "oldiphone",
    frame: FRAME_MODELS.some((m) => m.id === b.frame) ? b.frame : "nbpro",
    faceLock: false,
    enhance: !!b.enhance,
    keepSound: b.keepSound !== false,
    extra: clean(b.extra, 200),
    author: /^[\w.]{2,24}$/.test(b.author || "") ? b.author : ""
  };
  if (mode === "trend") o.model = TREND_MODELS.some((m) => m.id === b.model) ? b.model : "mc3p";
  else {
    const m = STYLE_MODELS.find((x) => x.id === b.model) || STYLE_MODELS[2];
    o.model = m.id;
    o.style = (STYLES.find((s) => s.id === b.style) || STYLES[0]).id;
    o.dur = m.durs.includes(+b.dur) ? +b.dur : m.durs.includes(8) ? 8 : m.durs[0];
  }
  return o;
}
function estimate(key, b) {
  const o = options(b);
  let seconds = o.dur || 0;
  if (o.mode === "trend") seconds = b.ref ? db.uploads[path4.basename(String(b.ref))]?.duration || 10 : +b.seconds || 10;
  return quote({ ...o, seconds });
}
async function create(key, b) {
  if (!b.consent || !b.adult) throw new UserError("\u041F\u043E\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u0435, \u0447\u0442\u043E \u0443 \u0432\u0430\u0441 \u0435\u0441\u0442\u044C \u0441\u043E\u0433\u043B\u0430\u0441\u0438\u0435 \u0447\u0435\u043B\u043E\u0432\u0435\u043A\u0430 \u0441 \u0444\u043E\u0442\u043E \u0438 \u0447\u0442\u043E \u0435\u043C\u0443 \u0435\u0441\u0442\u044C 18.");
  const o = options(b);
  const photos = (Array.isArray(b.photos) ? b.photos : []).slice(0, 3).map((p) => p ? ownUpload(key, p, "photo").path : null);
  if (!photos[0]) throw new UserError("\u0417\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u0444\u043E\u0442\u043E \u0447\u0435\u043B\u043E\u0432\u0435\u043A\u0430 \u0432 \u043F\u043E\u043B\u043D\u044B\u0439 \u0440\u043E\u0441\u0442.");
  const faceIdx = Number.isInteger(b.faceIdx) && photos[b.faceIdx] ? b.faceIdx : photos[1] ? 1 : photos[2] ? 2 : 0;
  let seconds = o.dur, ref2 = null;
  if (o.mode === "trend") {
    const u = ownUpload(key, b.ref, "video");
    ref2 = u.path;
    seconds = u.duration;
  }
  const q = quote({ ...o, seconds });
  charge(key, q.total);
  const j = {
    id: newId(),
    key,
    created: Date.now(),
    status: "working",
    stage: "frame",
    ...o,
    seconds,
    photos,
    faceIdx,
    ref: ref2,
    paid: q.total,
    parts: q.parts,
    usd: usdCost({ ...o, seconds }),
    notes: []
  };
  db.jobs.unshift(j);
  try {
    await startFrame(j);
  } catch (e) {
    fail(j, e.message);
    save();
    throw new UserError("\u041D\u0435 \u0443\u0434\u0430\u043B\u043E\u0441\u044C \u0437\u0430\u043F\u0443\u0441\u0442\u0438\u0442\u044C \u0433\u0435\u043D\u0435\u0440\u0430\u0446\u0438\u044E. \u0420\u0443\u0431\u0438\u043D\u044B \u0432\u043E\u0437\u0432\u0440\u0430\u0449\u0435\u043D\u044B.", 502);
  }
  save();
  return j;
}
var urls = (j) => {
  const all = j.photos.filter(Boolean).map((p) => ref(p));
  const face = ref(j.photos[j.faceIdx] || j.photos[0]);
  return { main: ref(j.photos[0]), face, all: [face, ...all.filter((u) => u !== face)] };
};
var refsFor = (face, all, frame) => {
  const r = [...all.filter((u) => u !== face), frame].filter((u, i, a) => u && a.indexOf(u) === i).slice(0, 3);
  return r.length ? r : [face];
};
async function startFrame(j) {
  const fm = FRAME_MODELS.find((m) => m.id === j.frame);
  if (!fm?.ep) {
    j.frameUrl = urls(j).main;
    return startVideo(j);
  }
  const U = urls(j);
  const style = STYLES.find((s) => s.id === j.style);
  const action = j.mode === "style" ? `starting to dance: ${style.moves.split(":")[0]}` : "in the middle of a dance move";
  const prompt = [
    "Create one still frame taken from a vertical 9:16 smartphone video.",
    j.photos.filter(Boolean).length > 1 ? "All reference photos show the same person (full body and face close-ups). The first photo shows the outfit and body." : "",
    "Show this same person: keep the exact face, facial features, skin tone, age, hairstyle, body type and outfit. The face is clearly visible and sharp, turned toward the camera.",
    PLACE[j.place],
    `Full body visible, caught naturally ${action}, candid and mid-motion, not posing for a photo. Use a different camera angle and framing than the original photo.`,
    CAM[j.cam],
    PHONE[j.phone],
    "No text, no watermark."
  ].filter(Boolean).join(" ");
  const r = await submit2(fm.ep, { prompt, image_urls: [U.main, ...U.all.filter((u) => u !== U.main)].slice(0, 3), num_images: 1, aspect_ratio: "9:16", resolution: "2K", output_format: "jpeg" }, ["resolution", "output_format"]);
  if (!r.ok) {
    j.notes.push("\u043F\u0435\u0440\u0432\u044B\u0439 \u043A\u0430\u0434\u0440 \u043D\u0435 \u0437\u0430\u043F\u0443\u0441\u0442\u0438\u043B\u0441\u044F: " + r.error.admin);
    refund(j.key, j.parts.frame);
    j.paid -= j.parts.frame;
    j.parts.frame = 0;
    j.frameUrl = U.main;
    return startVideo(j);
  }
  j.job = r.job;
  j.stage = "frame";
}
async function startVideo(j) {
  const U = urls(j);
  const refs = refsFor(U.face, U.all, j.frameUrl);
  let r;
  if (j.mode === "trend") {
    const m = TREND_MODELS.find((x) => x.id === j.model);
    const prompt = [`${m.elements ? "@Element1" : "The person from the image"} dances, repeating the exact choreography and timing of the reference video, moving from the very first frame.`, FACE, CAM[j.cam], PHONE[j.phone], PLACE[j.place], NEG].filter(Boolean).join(" ");
    const input = {
      image_url: j.frameUrl,
      video_url: ref(j.ref),
      character_orientation: "video",
      keep_original_sound: j.keepSound,
      prompt,
      ...m.elements ? { elements: [{ frontal_image_url: U.face, reference_image_urls: refs }] } : {}
    };
    r = await submit2(m.ep, input, ["elements", "keep_original_sound"]);
  } else {
    const m = STYLE_MODELS.find((x) => x.id === j.model);
    const style = STYLES.find((s) => s.id === j.style);
    const prompt = [
      `The person in the image dances ${style.moves}. The dance is already in full swing from the very first frame: no static pause at the start.`,
      j.extra ? `Also: ${j.extra}.` : "",
      "Full body visible, energetic and natural motion with real-world physics, dancing on the beat of an upbeat trending pop track.",
      m.audio ? "" : "Vertical 9:16 framing.",
      FACE,
      CAM[j.cam],
      PHONE[j.phone],
      PLACE[j.place],
      NEG
    ].filter(Boolean).join(" ");
    r = await submit2(m.ep, m.input(j.frameUrl, prompt, j.dur, U.face, refs), ["resolution", "prompt_optimizer", "negative_prompt", "elements"]);
  }
  if (!r.ok) throw new Error(r.error.admin);
  j.job = r.job;
  j.stage = "video";
}
async function startLock(j) {
  const face = urls(j).face, video = j.videoUrl;
  let r = await submit2(FACE_EP, { source_face_url: face, target_video_url: video, enable_occlusion_prevention: true }, ["enable_occlusion_prevention"]);
  if (!r.ok && r.status === 422) {
    const need = (Array.isArray(r.data?.detail) ? r.data.detail : []).map((x) => (x.loc || []).slice(-1)[0]).filter((n) => typeof n === "string" && n !== "body");
    if (need.length) {
      const input = {};
      for (const n of need) input[n] = /video/i.test(n) ? video : face;
      if (Object.values(input).includes(video) && Object.values(input).includes(face)) r = await submit2(FACE_EP, input);
    }
  }
  if (!r.ok) return skip(j, "lock", "face-lock \u043D\u0435 \u0437\u0430\u043F\u0443\u0441\u0442\u0438\u043B\u0441\u044F: " + r.error.admin);
  j.job = r.job;
  j.stage = "lock";
}
async function startEnhance(j) {
  const src = j.lockedUrl || j.videoUrl;
  const info = await probe2(src).catch(() => null);
  const long = info?.height ? Math.max(info.width, info.height) : 1280;
  const factor = Math.max(1, Math.min(2, +(1920 / long).toFixed(2)));
  const r = await submit2(UPSCALE_EP, { video_url: src, model: "Proteus", upscale_factor: factor, target_fps: 60, H264_output: true, recover_detail: 0.7 }, ["recover_detail"]);
  if (!r.ok) return skip(j, "enhance", "Topaz \u043D\u0435 \u0437\u0430\u043F\u0443\u0441\u0442\u0438\u043B\u0441\u044F: " + r.error.admin);
  j.job = r.job;
  j.stage = "enhance";
}
function skip(j, part, note) {
  j.notes.push(note);
  const n = j.parts[part] || 0;
  if (n) {
    refund(j.key, n);
    j.paid -= n;
    j.parts[part] = 0;
  }
  return next(j, part);
}
async function next(j, after) {
  const order = ["video", "lock", "enhance", "post"];
  for (const s of order.slice(order.indexOf(after) + 1)) {
    if (s === "lock" && j.faceLock) return startLock(j);
    if (s === "enhance" && j.enhance) return startEnhance(j);
    if (s === "post") {
      j.stage = "post";
      delete j.job;
      return;
    }
  }
}
function fail(j, err) {
  j.status = "failed";
  j.error = String(err || "\u043E\u0448\u0438\u0431\u043A\u0430").slice(0, 400);
  delete j.job;
  if (j.paid > 0) {
    refund(j.key, j.paid);
    j.refunded = j.paid;
    j.paid = 0;
  }
}
var posting = 0;
async function post(j) {
  if (j.posting) return;
  j.posting = true;
  posting++;
  const work = j.enhancedUrl || j.lockedUrl || j.videoUrl;
  const out = path4.join(MEDIA_DIR, `sd-${j.id}.mp4`);
  const tmp = [];
  const local = async (u, name) => {
    const r = await fetch(u);
    if (!r.ok) throw new Error("\u043D\u0435 \u0443\u0434\u0430\u043B\u043E\u0441\u044C \u0441\u043A\u0430\u0447\u0430\u0442\u044C \u0432\u0438\u0434\u0435\u043E");
    const f = path4.join(MEDIA_DIR, name);
    fs4.writeFileSync(f, Buffer.from(await r.arrayBuffer()));
    tmp.push(f);
    return f;
  };
  try {
    const fps = j.enhancedUrl && j.phone !== "cheap" ? 60 : 30;
    const v = await local(work, `tmp-${j.id}-v.mp4`);
    const a = work !== j.videoUrl ? await local(j.videoUrl, `tmp-${j.id}-a.mp4`).catch(() => "") : "";
    await finish({ video: v, audioFrom: a, out, look: j.phone, startAt: j.mode === "style" ? 0.5 : 0.3, fps });
  } catch (e) {
    j.notes.push("\u043E\u0431\u0440\u0430\u0431\u043E\u0442\u043A\u0430: " + e.message);
    try {
      const v = tmp[0] && fs4.existsSync(tmp[0]) ? tmp[0] : await local(work, `tmp-${j.id}-v.mp4`);
      await watermarkOnly(v, out);
    } catch (e3) {
      j.notes.push("\u0432\u043E\u0434\u044F\u043D\u043E\u0439 \u0437\u043D\u0430\u043A: " + e3.message);
      try {
        await saveRemote(work, `sd-${j.id}`, "mp4");
      } catch (e2) {
        for (const f of tmp) fs4.rmSync(f, { force: true });
        fail(j, "\u043D\u0435 \u0443\u0434\u0430\u043B\u043E\u0441\u044C \u0441\u043E\u0445\u0440\u0430\u043D\u0438\u0442\u044C \u0432\u0438\u0434\u0435\u043E: " + e2.message);
        posting--;
        j.posting = false;
        save();
        return;
      }
    }
  }
  for (const f of tmp) fs4.rmSync(f, { force: true });
  try {
    await poster(out, path4.join(MEDIA_DIR, `sd-${j.id}-poster.jpg`));
    j.poster = `/media/sd-${j.id}-poster.jpg`;
  } catch {
  }
  j.result = `/media/sd-${j.id}.mp4`;
  j.status = "done";
  j.stage = "";
  j.done = Date.now();
  delete j.posting;
  posting--;
  save();
}
var running = null;
var busy = () => db.jobs.some((j) => j.status === "working");
function poll() {
  if (!running) running = step().finally(() => {
    running = null;
  });
  return running;
}
async function step() {
  for (const j of db.jobs) {
    if (j.status !== "working") continue;
    try {
      if (j.stage === "post") {
        if (!j.posting && posting < 2) post(j);
        continue;
      }
      const r = await check2(j.job);
      if (r.state === "working") continue;
      if (j.stage === "frame") {
        const img = r.state === "done" ? imagesOf(r.data)[0] : null;
        if (!img) {
          j.notes.push("\u043F\u0435\u0440\u0432\u044B\u0439 \u043A\u0430\u0434\u0440: " + (r.error || "\u043D\u0435\u0442 \u043A\u0430\u0440\u0442\u0438\u043D\u043A\u0438"));
          refund(j.key, j.parts.frame);
          j.paid -= j.parts.frame;
          j.parts.frame = 0;
          j.frameUrl = urls(j).main;
        } else {
          j.frameUrl = img;
          j.frame_img = img;
        }
        await startVideo(j);
      } else if (j.stage === "video") {
        if (r.state === "failed") throw new Error(r.error);
        j.videoUrl = videoOf(r.data);
        if (!j.videoUrl) throw new Error("\u043C\u043E\u0434\u0435\u043B\u044C \u043D\u0435 \u0432\u0435\u0440\u043D\u0443\u043B\u0430 \u0432\u0438\u0434\u0435\u043E");
        await next(j, "video");
      } else if (j.stage === "lock") {
        const u = r.state === "done" ? videoOf(r.data) || r.data?.output?.url : null;
        if (!u) await skip(j, "lock", "face-lock: " + (r.error || "\u043D\u0435\u0442 \u0432\u0438\u0434\u0435\u043E"));
        else {
          j.lockedUrl = u;
          await next(j, "lock");
        }
      } else if (j.stage === "enhance") {
        const u = r.state === "done" ? videoOf(r.data) : null;
        if (!u) await skip(j, "enhance", "Topaz: " + (r.error || "\u043D\u0435\u0442 \u0432\u0438\u0434\u0435\u043E"));
        else {
          j.enhancedUrl = u;
          await next(j, "enhance");
        }
      }
    } catch (e) {
      fail(j, e.message);
    }
  }
  save();
}
for (const j of db.jobs) delete j.posting;
var STAGE = { frame: "\u0413\u043E\u0442\u043E\u0432\u0438\u043C \u043F\u0435\u0440\u0432\u044B\u0439 \u043A\u0430\u0434\u0440 \u043F\u043E \u0442\u0435\u043C\u0435", video: "\u0427\u0435\u043B\u043E\u0432\u0435\u043A \u0441 \u0444\u043E\u0442\u043E \u0442\u0430\u043D\u0446\u0443\u0435\u0442", lock: "\u0424\u0438\u043A\u0441\u0438\u0440\u0443\u0435\u043C \u043B\u0438\u0446\u043E \u0432 \u043A\u0430\u0436\u0434\u043E\u043C \u043A\u0430\u0434\u0440\u0435", enhance: "\u041F\u043E\u0432\u044B\u0448\u0430\u0435\u043C \u0434\u043E 1080p \u0438 60 \u043A\u0430\u0434\u0440\u043E\u0432", post: "\u0414\u0435\u043B\u0430\u0435\u043C \xAB\u043A\u0430\u043A \u0441 \u0442\u0435\u043B\u0435\u0444\u043E\u043D\u0430\xBB" };
var summary = (j) => ({
  id: j.id,
  mode: j.mode,
  style: j.style,
  styleName: STYLES.find((s) => s.id === j.style)?.name || "",
  model: j.model,
  modelName: [...TREND_MODELS, ...STYLE_MODELS].find((m) => m.id === j.model)?.name || j.model,
  status: j.status,
  stage: j.stage,
  stageText: STAGE[j.stage] || "",
  error: j.status === "failed" ? "\u041D\u0435 \u043F\u043E\u043B\u0443\u0447\u0438\u043B\u043E\u0441\u044C. \u0420\u0443\u0431\u0438\u043D\u044B \u0432\u043E\u0437\u0432\u0440\u0430\u0449\u0435\u043D\u044B." : "",
  result: j.result || "",
  poster: j.poster || "",
  frame: j.frame_img || "",
  created: j.created,
  paid: j.paid,
  refunded: j.refunded || 0,
  author: j.author || "",
  faceLock: j.faceLock,
  enhance: j.enhance,
  phone: j.phone,
  partial: j.status === "done" && j.notes?.length ? "\u0427\u0430\u0441\u0442\u044C \u0448\u0430\u0433\u043E\u0432 \u043D\u0435 \u0441\u0440\u0430\u0431\u043E\u0442\u0430\u043B\u0430 \u2014 \u0438\u0445 \u0441\u0442\u043E\u0438\u043C\u043E\u0441\u0442\u044C \u0432\u0435\u0440\u043D\u0443\u043B\u0438." : ""
});
var mine = (key) => db.jobs.filter((j) => j.key === key).slice(0, 60).map(summary);
function remove(key, id) {
  const j = db.jobs.find((x) => x.id === id && x.key === key);
  if (!j) throw new UserError("\u0412\u0438\u0434\u0435\u043E \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D\u043E.", 404);
  if (j.status === "working") throw new UserError("\u0414\u043E\u0436\u0434\u0438\u0442\u0435\u0441\u044C \u043E\u043A\u043E\u043D\u0447\u0430\u043D\u0438\u044F \u0433\u0435\u043D\u0435\u0440\u0430\u0446\u0438\u0438.");
  removeMedia(`sd-${j.id}`);
  db.jobs = db.jobs.filter((x) => x !== j);
  save();
}
function cleanup() {
  const old = Date.now() - 3 * 864e5;
  for (const [file, u] of Object.entries(db.uploads)) {
    if (u.created < old && !db.jobs.some((j) => j.status === "working" && (j.photos?.includes(u.path) || j.ref === u.path))) {
      fs4.rmSync(fileOf(u.path), { force: true });
      delete db.uploads[file];
    }
  }
  save();
}
async function caption(b) {
  const style = STYLES.find((s) => s.id === b.style);
  const lang = ["es", "en", "ru"].includes(b.lang) ? b.lang : "es";
  const LN = { es: { name: "espa\xF1ol (Espa\xF1a)", tags: "#fyp #parati #baile", ai: "#hechoconIA" }, en: { name: "English", tags: "#fyp #foryou #dance", ai: "#madewithAI" }, ru: { name: "\u0440\u0443\u0441\u0441\u043A\u0438\u0439", tags: "#fyp #\u0440\u0435\u043A\u043E\u043C\u0435\u043D\u0434\u0430\u0446\u0438\u0438", ai: "#\u0441\u0434\u0435\u043B\u0430\u043D\u043E\u0418\u0418" } }[lang];
  const r = await submit2("fal-ai/any-llm", {
    model: "google/gemini-2.5-flash",
    system_prompt: `You are a TikTok SMM specialist. Write short, lively captions in ${LN.name} with 1\u20132 emoji.`,
    prompt: `Write a TikTok caption in ${LN.name} for a video where a person dances ${b.mode === "trend" ? "a trending dance to a popular sound" : `in the style "${{ hands: "hand dance", shuffle: "shuffle", groove: "hip-hop groove", kpop: "K-pop routine", dad: "funny dad dance", tecktonik: "electro / tecktonik", latin: "solo latin / salsa", slow: "smooth slow vibe" }[style?.id] || "dance"}"`}. The video is AI-generated. Format: one hook line up to 80 characters that grabs attention in the first seconds and invites comments, then an empty line and 8\u201310 hashtags: a mix of broad ones (like ${LN.tags}) and niche ones for the dance style, ending with ${LN.ai}. Output only the caption text, no explanations.`
  });
  if (!r.ok) throw new UserError("\u041D\u0435 \u043F\u043E\u043B\u0443\u0447\u0438\u043B\u043E\u0441\u044C \u043F\u0440\u0438\u0434\u0443\u043C\u0430\u0442\u044C \u043F\u043E\u0434\u043F\u0438\u0441\u044C.", 502);
  for (let i = 0; i < 20; i++) {
    await new Promise((ok) => setTimeout(ok, 1500));
    const c = await check2(r.job);
    if (c.state === "done") return String(c.data?.output || "").trim().slice(0, 500);
    if (c.state === "failed") break;
  }
  throw new UserError("\u041D\u0435 \u043F\u043E\u043B\u0443\u0447\u0438\u043B\u043E\u0441\u044C \u043F\u0440\u0438\u0434\u0443\u043C\u0430\u0442\u044C \u043F\u043E\u0434\u043F\u0438\u0441\u044C.", 502);
}

// src/examples.mjs
import fs5 from "node:fs";
import path5 from "node:path";
db.examples ||= [];
var clean2 = (v, max) => String(v ?? "").replace(/\s+/g, " ").trim().slice(0, max);
async function upload2(req, kind) {
  const ct = String(req.headers["content-type"] || "").split(";")[0].trim().toLowerCase();
  const id = "ex-" + newId();
  if (kind === "photo") {
    const ext2 = { "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp" }[ct];
    if (!ext2) throw new UserError("\u0414\u043B\u044F \xAB\u0434\u043E\xBB \u043D\u0443\u0436\u043D\u043E \u0444\u043E\u0442\u043E: JPG, PNG \u0438\u043B\u0438 WEBP.");
    return (await saveUpload(req, id, ext2, 15e6)).path;
  }
  const ext = { "video/mp4": "mp4", "video/quicktime": "mov", "video/webm": "webm", "video/x-m4v": "m4v" }[ct] || (ct.startsWith("video/") ? "mp4" : "");
  if (!ext) throw new UserError("\u0414\u043B\u044F \xAB\u043F\u043E\u0441\u043B\u0435\xBB \u043D\u0443\u0436\u043D\u043E \u0432\u0438\u0434\u0435\u043E: MP4, MOV \u0438\u043B\u0438 WEBM.");
  const r = await saveUpload(req, id, ext, 15e7);
  const info = await probe2(fileOf(r.path)).catch(() => null);
  if (info && !info.duration) {
    removeMedia(id + ".");
    throw new UserError("\u041D\u0435 \u043F\u043E\u043B\u0443\u0447\u0438\u043B\u043E\u0441\u044C \u043F\u0440\u043E\u0447\u0438\u0442\u0430\u0442\u044C \u0432\u0438\u0434\u0435\u043E.");
  }
  return r.path;
}
var isEx = (p) => /^\/media\/ex-[\w-]+\.\w+$/.test(String(p || "")) && mediaExists(p);
async function makePoster(after) {
  const name = path5.basename(after).replace(/\.\w+$/, "") + "-poster.jpg";
  try {
    await poster(fileOf(after), path5.join(MEDIA_DIR, name));
    return `/media/${name}`;
  } catch {
    return "";
  }
}
async function create2(b) {
  if (!isEx(b.before)) throw new UserError("\u0417\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u0444\u043E\u0442\u043E \xAB\u0434\u043E\xBB.");
  if (!isEx(b.after)) throw new UserError("\u0417\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u0432\u0438\u0434\u0435\u043E \xAB\u043F\u043E\u0441\u043B\u0435\xBB.");
  const ex = { id: newId(), before: b.before, after: b.after, poster: await makePoster(b.after), caption: clean2(b.caption, 80), published: true, created: Date.now() };
  db.examples.unshift(ex);
  save();
  return ex;
}
async function fromJob(id, caption2) {
  const j = db.jobs.find((x) => x.id === id);
  if (!j || j.status !== "done" || !j.result) throw new UserError("\u0412\u0438\u0434\u0435\u043E \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D\u043E \u0438\u043B\u0438 \u043D\u0435 \u0433\u043E\u0442\u043E\u0432\u043E.", 404);
  if (!mediaExists(j.photos?.[0])) throw new UserError("\u0418\u0441\u0445\u043E\u0434\u043D\u043E\u0435 \u0444\u043E\u0442\u043E \u0443\u0436\u0435 \u0443\u0434\u0430\u043B\u0435\u043D\u043E (\u0445\u0440\u0430\u043D\u0438\u0442\u0441\u044F 3 \u0434\u043D\u044F). \u0417\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u043F\u0430\u0440\u0443 \u0432\u0440\u0443\u0447\u043D\u0443\u044E.");
  const nid = newId();
  const copy = (src, name) => {
    const ext = path5.extname(fileOf(src));
    const file = `ex-${nid}-${name}${ext}`;
    fs5.copyFileSync(fileOf(src), path5.join(MEDIA_DIR, file));
    return `/media/${file}`;
  };
  return create2({ before: copy(j.photos[0], "b"), after: copy(j.result, "a"), caption: caption2 || (j.mode === "trend" ? "\u0422\u0440\u0435\u043D\u0434-\u0442\u0430\u043D\u0435\u0446 \u0438\u0437 \u043E\u0434\u043D\u043E\u0433\u043E \u0444\u043E\u0442\u043E" : "\u0422\u0430\u043D\u0435\u0446 \u043F\u043E \u0441\u0442\u0438\u043B\u044E \u0438\u0437 \u043E\u0434\u043D\u043E\u0433\u043E \u0444\u043E\u0442\u043E") });
}
function update(b) {
  const i = db.examples.findIndex((x) => x.id === b.id);
  if (i < 0) throw new UserError("\u041F\u0440\u0438\u043C\u0435\u0440 \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D.", 404);
  const ex = db.examples[i];
  if (b.caption !== void 0) ex.caption = clean2(b.caption, 80);
  if (b.published !== void 0) ex.published = !!b.published;
  if (b.move === "up" && i > 0) [db.examples[i - 1], db.examples[i]] = [db.examples[i], db.examples[i - 1]];
  if (b.move === "down" && i < db.examples.length - 1) [db.examples[i + 1], db.examples[i]] = [db.examples[i], db.examples[i + 1]];
  save();
}
function remove2(id) {
  const ex = db.examples.find((x) => x.id === id);
  if (!ex) throw new UserError("\u041F\u0440\u0438\u043C\u0435\u0440 \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D.", 404);
  for (const p of [ex.before, ex.after, ex.poster]) if (p) fs5.rmSync(fileOf(p), { force: true });
  db.examples = db.examples.filter((x) => x !== ex);
  save();
}
var list = () => db.examples;
var published = () => db.examples.filter((x) => x.published).slice(0, 12).map(({ id, before, after, poster: poster2, caption: caption2 }) => ({ id, before, after, poster: poster2, caption: caption2 }));

// src/server.mjs
var { UserError: UserError2 } = fal_exports;
var BRAND = process.env.STUDIO_NAME || "SnapDance";
var CONTACT = process.env.CONTACT_EMAIL || "";
var ROOT = path6.dirname(fileURLToPath(import.meta.url));
var PUBLIC = fs6.existsSync(path6.join(ROOT, "public", "index.html")) ? path6.join(ROOT, "public") : ROOT;
var PORT = process.env.PORT || 3e3;
var FFMPEG_OK = null;
hasFfmpeg().then((ok) => {
  FFMPEG_OK = ok;
  if (!ok) console.warn("ffmpeg \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D \u2014 \u0432\u0438\u0434\u0435\u043E \u0431\u0443\u0434\u0443\u0442 \u0431\u0435\u0437 \u043E\u0431\u0440\u0430\u0431\u043E\u0442\u043A\u0438 \xAB\u043A\u0430\u043A \u0441 \u0442\u0435\u043B\u0435\u0444\u043E\u043D\u0430\xBB");
});
var json = (res, data, status = 200) => {
  res.writeHead(status, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
  res.end(JSON.stringify(data));
};
async function readBody(req, limit = 1e6) {
  const chunks = [];
  let size = 0;
  for await (const c of req) {
    size += c.length;
    if (size > limit) throw new UserError2("\u0421\u043B\u0438\u0448\u043A\u043E\u043C \u0431\u043E\u043B\u044C\u0448\u043E\u0439 \u0437\u0430\u043F\u0440\u043E\u0441.", 413);
    chunks.push(c);
  }
  return Buffer.concat(chunks).toString("utf8");
}
var body = async (req, limit) => {
  const raw = await readBody(req, limit);
  try {
    return raw ? JSON.parse(raw) : {};
  } catch {
    throw new UserError2("\u041D\u0435\u043A\u043E\u0440\u0440\u0435\u043A\u0442\u043D\u044B\u0439 \u0437\u0430\u043F\u0440\u043E\u0441.");
  }
};
function origin(req) {
  const proto = String(req.headers["x-forwarded-proto"] || "https").split(",")[0];
  const host = String(req.headers["x-forwarded-host"] || req.headers.host || "").split(",")[0];
  const o = cleanOrigin(process.env.PUBLIC_URL) || `${/^(localhost|127\.)/.test(host) ? "http" : proto}://${host}`;
  noteOrigin(o);
  return o;
}
var PACK_ES = { start: "Inicio", pop: "Tendencia", pro: "Estudio" };
var packs = () => db.settings.packs.map((p) => p.name?.es ? p : { ...p, name: { ...p.name, es: PACK_ES[p.id] || p.name?.en || p.name?.ru || p.id } });
var currency = () => db.settings.currency || "eur";
function clientKey(req) {
  const k = normKey(req.headers["x-key"]);
  if (!db.keys[k]) throw new UserError2("\u041A\u043E\u0434 \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D. \u041A\u0443\u043F\u0438\u0442\u0435 \u0440\u0443\u0431\u0438\u043D\u044B \u0438\u043B\u0438 \u0432\u0432\u0435\u0434\u0438\u0442\u0435 \u0441\u0432\u043E\u0439 \u043A\u043E\u0434.", 401);
  return k;
}
function isAdmin(req) {
  const pass = process.env.ADMIN_PASSWORD || "";
  if (!pass) throw new UserError2("\u0410\u0434\u043C\u0438\u043D\u043A\u0430 \u0432\u044B\u043A\u043B\u044E\u0447\u0435\u043D\u0430: \u0437\u0430\u0434\u0430\u0439\u0442\u0435 ADMIN_PASSWORD \u0432 Railway \u2192 Variables.", 403);
  const a = crypto3.createHash("sha256").update(pass).digest(), b = crypto3.createHash("sha256").update(String(req.headers["x-admin"] || "")).digest();
  if (!crypto3.timingSafeEqual(a, b)) throw new UserError2("\u041D\u0435\u0432\u0435\u0440\u043D\u044B\u0439 \u043F\u0430\u0440\u043E\u043B\u044C.", 401);
}
function fulfill(session) {
  if (!session || session.payment_status !== "paid") return null;
  const existing = db.orders.find((o) => o.id === session.id);
  if (existing) return { key: existing.key, added: 0, credits: db.keys[existing.key]?.credits ?? 0 };
  const credits = parseInt(session.metadata?.credits, 10) || 0;
  let key = normKey(session.metadata?.key);
  const email = session.customer_details?.email || session.customer_email || "";
  if (!db.keys[key]) {
    key = newKey();
    db.keys[key] = { credits: 0, spent: 0, email, created: Date.now(), source: "stripe", note: "" };
  }
  db.keys[key].credits += credits;
  if (email && !db.keys[key].email) db.keys[key].email = email;
  db.orders.unshift({ id: session.id, key, email, pack: session.metadata?.pack || "", credits, amount: (session.amount_total || 0) / 100, currency: session.currency || currency(), created: Date.now() });
  save();
  return { key, added: credits, credits: db.keys[key].credits };
}
var routes = {
  "GET /api/config": async (req, res) => json(res, {
    brand: BRAND,
    contact: CONTACT,
    currency: currency(),
    stripe: stripeEnabled(),
    packs: packs(),
    catalog: publicCatalog(),
    styles: STYLES.map(({ id, icon, name, hint }) => ({ id, icon, name, hint })),
    examples: published()
  }),
  "GET /api/me": async (req, res) => {
    const k = clientKey(req);
    json(res, { key: k, credits: db.keys[k].credits });
  },
  "POST /api/quote": async (req, res) => json(res, estimate("", await body(req))),
  "POST /api/upload": async (req, res, url) => {
    const k = clientKey(req);
    origin(req);
    const kind = url.searchParams.get("kind") === "video" ? "video" : "photo";
    json(res, await upload(req, k, kind));
  },
  "POST /api/jobs": async (req, res) => {
    const k = clientKey(req);
    origin(req);
    const j = await create(k, await body(req));
    json(res, { job: summary(j), credits: db.keys[k].credits });
  },
  "GET /api/jobs": async (req, res) => {
    const k = clientKey(req);
    origin(req);
    if (db.jobs.some((j) => j.key === k && j.status === "working")) await poll();
    json(res, { credits: db.keys[k].credits, jobs: mine(k) });
  },
  "POST /api/jobs/delete": async (req, res) => {
    const k = clientKey(req);
    remove(k, (await body(req)).id);
    json(res, { ok: true });
  },
  "POST /api/caption": async (req, res) => {
    clientKey(req);
    json(res, { caption: await caption({ ...await body(req), lang: langOf(req) }) });
  },
  // оплата
  "POST /api/checkout": async (req, res) => {
    if (!stripeEnabled()) throw new UserError2("\u041E\u043F\u043B\u0430\u0442\u0430 \u0435\u0449\u0451 \u043D\u0435 \u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0435\u043D\u0430.", 503);
    const b = await body(req);
    const pack = packs().find((p) => p.id === b.pack);
    if (!pack) throw new UserError2("\u041F\u0430\u043A\u0435\u0442 \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D.");
    const key = db.keys[normKey(b.key)] ? normKey(b.key) : "";
    const s = await createCheckout({ pack, currency: currency(), key, origin: origin(req), lang: ["es", "en", "ru"].includes(b.lang) ? b.lang : langOf(req), brand: BRAND });
    json(res, { url: s.url });
  },
  "GET /api/checkout/confirm": async (req, res, url) => {
    const id = url.searchParams.get("session_id") || "";
    if (!/^cs_[\w]+$/.test(id)) throw new UserError2("\u041D\u0435\u043A\u043E\u0440\u0440\u0435\u043A\u0442\u043D\u044B\u0439 \u043F\u043B\u0430\u0442\u0451\u0436.");
    const r = fulfill(await retrieveSession(id));
    if (!r) throw new UserError2("\u041F\u043B\u0430\u0442\u0451\u0436 \u0435\u0449\u0451 \u043D\u0435 \u043F\u043E\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0451\u043D. \u041E\u0431\u043D\u043E\u0432\u0438\u0442\u0435 \u0441\u0442\u0440\u0430\u043D\u0438\u0446\u0443 \u0447\u0435\u0440\u0435\u0437 \u043C\u0438\u043D\u0443\u0442\u0443.", 402);
    json(res, r);
  },
  "POST /api/stripe/webhook": async (req, res) => {
    const raw = await readBody(req, 1e6);
    const event = verifyWebhook(raw, req.headers["stripe-signature"]);
    if (!event) return json(res, { error: "bad signature" }, 400);
    if (event.type === "checkout.session.completed" || event.type === "checkout.session.async_payment_succeeded") fulfill(event.data.object);
    json(res, { received: true });
  },
  "GET /api/health": async (req, res) => {
    const p = await probe();
    json(res, {
      fal: p.text,
      falOk: p.ok,
      ffmpeg: FFMPEG_OK ? "\u0435\u0441\u0442\u044C" : "\u043D\u0435\u0442 (\u0432\u0438\u0434\u0435\u043E \u0431\u0435\u0437 \u043E\u0431\u0440\u0430\u0431\u043E\u0442\u043A\u0438 \xAB\u043A\u0430\u043A \u0441 \u0442\u0435\u043B\u0435\u0444\u043E\u043D\u0430\xBB)",
      stripe: (await check()).text,
      webhook: webhookEnabled() ? "\u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0451\u043D" : "\u043D\u0435 \u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0451\u043D (STRIPE_WEBHOOK_SECRET)",
      storage: PERSISTENT ? `\u0441\u043E\u0445\u0440\u0430\u043D\u044F\u0435\u0442\u0441\u044F (${DATA_DIR})` : "\u0412\u041D\u0418\u041C\u0410\u041D\u0418\u0415: Volume \u043D\u0435 \u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0451\u043D, \u0434\u0430\u043D\u043D\u044B\u0435 \u043F\u0440\u043E\u043F\u0430\u0434\u0443\u0442 \u043F\u0440\u0438 \u043F\u0435\u0440\u0435\u0437\u0430\u043F\u0443\u0441\u043A\u0435",
      publicUrl: process.env.PUBLIC_URL ? cleanOrigin(process.env.PUBLIC_URL) ? `\u0437\u0430\u0434\u0430\u043D: ${cleanOrigin(process.env.PUBLIC_URL)}` : "\u041E\u0428\u0418\u0411\u041A\u0410: PUBLIC_URL \u043D\u0435 \u043F\u043E\u0445\u043E\u0436 \u043D\u0430 \u0430\u0434\u0440\u0435\u0441 \u0441\u0430\u0439\u0442\u0430" : "\u043D\u0435 \u0437\u0430\u0434\u0430\u043D (PUBLIC_URL)",
      admin: process.env.ADMIN_PASSWORD ? "\u0432\u043A\u043B\u044E\u0447\u0435\u043D\u0430" : "\u0432\u044B\u043A\u043B\u044E\u0447\u0435\u043D\u0430 (ADMIN_PASSWORD)"
    });
  },
  // ---------- админка ----------
  "GET /api/admin/stats": async (req, res) => {
    isAdmin(req);
    origin(req);
    const DAY = 864e5, start = /* @__PURE__ */ new Date();
    start.setHours(0, 0, 0, 0);
    const days = [];
    for (let i = 13; i >= 0; i--) {
      const from = start.getTime() - i * DAY, to = from + DAY;
      const js = db.jobs.filter((j) => j.created >= from && j.created < to && j.status === "done");
      const os = db.orders.filter((o) => o.created >= from && o.created < to);
      days.push({ day: from, videos: js.length, revenue: os.reduce((s, o) => s + o.amount, 0) });
    }
    const since = (ms) => db.orders.filter((o) => o.created >= Date.now() - ms);
    const sum = (a) => a.reduce((s, o) => s + o.amount, 0);
    const done = db.jobs.filter((j) => j.status === "done");
    const p = await probe();
    json(res, {
      brand: BRAND,
      currency: currency(),
      days,
      today: days[13],
      revenue7: sum(since(7 * DAY)),
      revenue30: sum(since(30 * DAY)),
      revenueAll: sum(db.orders),
      orders: db.orders.length,
      videos: done.length,
      trend: done.filter((j) => j.mode === "trend").length,
      style: done.filter((j) => j.mode === "style").length,
      failed: db.jobs.filter((j) => j.status === "failed").length,
      working: db.jobs.filter((j) => j.status === "working").length,
      falCost: +done.reduce((s, j) => s + (j.usd || 0), 0).toFixed(2),
      rubiesSold: db.orders.reduce((s, o) => s + o.credits, 0),
      rubiesLeft: Object.values(db.keys).reduce((s, k) => s + k.credits, 0),
      clients: Object.keys(db.keys).length,
      disk: diskUsage(),
      system: { fal: p.text, falOk: p.ok, ffmpeg: FFMPEG_OK, stripe: stripeEnabled(), webhook: webhookEnabled(), persistent: PERSISTENT, dataDir: DATA_DIR, publicUrl: !!process.env.PUBLIC_URL }
    });
  },
  "GET /api/admin/jobs": async (req, res) => {
    isAdmin(req);
    json(res, db.jobs.slice(0, 200).map((j) => ({ ...summary(j), key: j.key, email: db.keys[j.key]?.email || "", usd: j.usd, notes: j.notes || [], rawError: j.error || "", seconds: Math.round(j.seconds || 0), frameModel: j.frame })));
  },
  "GET /api/admin/orders": async (req, res) => {
    isAdmin(req);
    json(res, db.orders.slice(0, 300));
  },
  "GET /api/admin/keys": async (req, res) => {
    isAdmin(req);
    json(res, Object.entries(db.keys).map(([key, v]) => ({ key, ...v })).sort((a, b) => b.created - a.created).slice(0, 500));
  },
  "POST /api/admin/keys": async (req, res) => {
    isAdmin(req);
    const { credits, note, email } = await body(req);
    const c = Math.max(0, Math.min(1e5, parseInt(credits, 10) || 0));
    if (!c) throw new UserError2("\u0423\u043A\u0430\u0436\u0438\u0442\u0435 \u043A\u043E\u043B\u0438\u0447\u0435\u0441\u0442\u0432\u043E \u0440\u0443\u0431\u0438\u043D\u043E\u0432.");
    const key = newKey();
    db.keys[key] = { credits: c, spent: 0, email: String(email || "").slice(0, 120), created: Date.now(), source: "promo", note: String(note || "").slice(0, 120) };
    save();
    json(res, { key, ...db.keys[key] });
  },
  "POST /api/admin/keys/adjust": async (req, res) => {
    isAdmin(req);
    const { key, delta } = await body(req);
    const rec = db.keys[normKey(key)];
    if (!rec) throw new UserError2("\u041A\u043E\u0434 \u043D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D.", 404);
    rec.credits = Math.max(0, rec.credits + (parseInt(delta, 10) || 0));
    save();
    json(res, { key: normKey(key), credits: rec.credits });
  },
  "POST /api/admin/packs": async (req, res) => {
    isAdmin(req);
    const { packs: list2, currency: cur } = await body(req);
    if (!Array.isArray(list2) || !list2.length || list2.length > 6) throw new UserError2("\u041D\u0443\u0436\u043D\u043E \u043E\u0442 1 \u0434\u043E 6 \u043F\u0430\u043A\u0435\u0442\u043E\u0432.");
    db.settings.packs = list2.map((p, i) => ({
      id: String(p.id || `pack${i}`).replace(/[^\w-]/g, "").slice(0, 20) || `pack${i}`,
      credits: Math.max(1, parseInt(p.credits, 10) || 1),
      price: Math.max(0.5, Math.round((parseFloat(p.price) || 1) * 100) / 100),
      name: { es: String(p.name?.es || "").slice(0, 40) || "Paquete", en: String(p.name?.en || "").slice(0, 40) || "Pack", ru: String(p.name?.ru || "").slice(0, 40) || "\u041F\u0430\u043A\u0435\u0442" },
      popular: Boolean(p.popular)
    }));
    if (["eur", "usd", "gbp"].includes(cur)) db.settings.currency = cur;
    save();
    json(res, { packs: db.settings.packs, currency: db.settings.currency });
  },
  "GET /api/admin/prices": async (req, res) => {
    isAdmin(req);
    json(res, econReport());
  },
  // примеры «до и после»
  "GET /api/admin/examples": async (req, res) => {
    isAdmin(req);
    json(res, list());
  },
  "POST /api/admin/examples/upload": async (req, res, url) => {
    isAdmin(req);
    json(res, { path: await upload2(req, url.searchParams.get("kind") === "video" ? "video" : "photo") });
  },
  "POST /api/admin/examples": async (req, res) => {
    isAdmin(req);
    json(res, await create2(await body(req)));
  },
  "POST /api/admin/examples/from-job": async (req, res) => {
    isAdmin(req);
    const b = await body(req);
    json(res, await fromJob(b.id, b.caption));
  },
  "POST /api/admin/examples/update": async (req, res) => {
    isAdmin(req);
    update(await body(req));
    json(res, { ok: true });
  },
  "POST /api/admin/examples/delete": async (req, res) => {
    isAdmin(req);
    remove2((await body(req)).id);
    json(res, { ok: true });
  },
  "POST /api/admin/prices": async (req, res) => {
    isAdmin(req);
    saveEcon(await body(req));
    json(res, econReport());
  },
  "GET /api/admin/marketing": async (req, res) => {
    isAdmin(req);
    json(res, db.settings.marketing || {});
  },
  "POST /api/admin/marketing": async (req, res) => {
    isAdmin(req);
    const b = await body(req);
    db.settings.marketing = {
      ga4: String(b.ga4 || "").trim(),
      fbPixel: String(b.fbPixel || "").trim(),
      tiktokPixel: String(b.tiktokPixel || "").trim(),
      gscMeta: String(b.gscMeta || "").trim(),
      enableAIOpt: Boolean(b.enableAIOpt)
    };
    save();
    json(res, { ok: true, marketing: db.settings.marketing });
  },
  "GET /api/admin/ios-package": async (req, res) => {
    isAdmin(req);
    // Generate a simple Capacitor-ready zip instruction or placeholder package
    // For full package we return a JSON with instructions + downloadable config
    const siteUrl = process.env.PUBLIC_URL || "https://your-domain.com";
    const pkg = {
      name: "snapdance-ios",
      version: "1.0.0",
      siteUrl,
      instructions: "Скачай Capacitor template, подставь URL сайта, собери в Xcode и загрузи в App Store. Пакет содержит базовый capacitor.config.json и Info.plist-заготовки."
    };
    res.writeHead(200, { "content-type": "application/json" });
    res.end(JSON.stringify(pkg));
  },
};
var PAGES = { "/": "index.html", "/admin": "admin.html" };
function serveStatic(req, res, pathname) {
  const page = PAGES[pathname];
  const file = page && path6.join(PUBLIC, page);
  if (file && fs6.existsSync(file)) {
    const h = { "content-type": "text/html; charset=utf-8", "cache-control": "no-cache", "x-content-type-options": "nosniff" };
    if (pathname === "/admin") h["x-robots-tag"] = "noindex, nofollow";
    if (pathname === "/" && db.settings.marketing) {
      let html = fs6.readFileSync(file, "utf8");
      const m = db.settings.marketing;
      let inject = "";
      // Google Analytics 4
      if (m.ga4) {
        inject += `<script async src="https://www.googletagmanager.com/gtag/js?id=${m.ga4}"></script>
<script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','${m.ga4}');</script>\n`;
      }
      // Facebook Pixel
      if (m.fbPixel) {
        inject += `<script>!function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,document,'script','https://connect.facebook.net/en_US/fbevents.js');fbq('init','${m.fbPixel}');fbq('track','PageView');</script>
<noscript><img height="1" width="1" style="display:none" src="https://www.facebook.com/tr?id=${m.fbPixel}&ev=PageView&noscript=1"/></noscript>\n`;
      }
      // TikTok Pixel
      if (m.tiktokPixel) {
        inject += `<script>!function(w,d,t){w.TiktokAnalyticsObject=t;var ttq=w[t]=w[t]||[];ttq.methods=["page","track","identify","instances","debug","on","off","once","ready","alias","group","enableCookie","disableCookie"],ttq.setAndDefer=function(t,e){t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}};for(var i=0;i<ttq.methods.length;i++)ttq.setAndDefer(ttq,ttq.methods[i]);ttq.instance=function(t){for(var e=ttq._i[t]||[],n=0;n<ttq.methods.length;n++)ttq.setAndDefer(e,ttq.methods[n]);return e};ttq.load=function(e,n){var i="https://analytics.tiktok.com/i18n/pixel/events.js";ttq._i=ttq._i||{};ttq._i[e]=[];ttq._i[e]._u=i;ttq._t=ttq._t||{};ttq._t[e]=+new Date;ttq._o=ttq._o||{};ttq._o[e]=n||{};var o=document.createElement("script");o.type="text/javascript";o.async=!0;o.src=i+"?sdkid="+e+"&lib="+t;var a=document.getElementsByTagName("script")[0];a.parentNode.insertBefore(o,a)};ttq.load('${m.tiktokPixel}');ttq.page();}(window,document,'ttq');</script>\n`;
      }
      // Google Search Console meta
      if (m.gscMeta) {
        inject += `<meta name="google-site-verification" content="${m.gscMeta}">\n`;
      }
      // AI Optimization (schema + meta for Google AI / GPT crawlers)
      if (m.enableAIOpt !== false) {
        inject += `<script type="application/ld+json">
{"@context":"https://schema.org","@type":"WebApplication","name":"SnapDance","applicationCategory":"MultimediaApplication","operatingSystem":"Web, iOS, Android","offers":{"@type":"Offer","price":"0","priceCurrency":"EUR"},"description":"Turn a selfie into a trending TikTok dance video with AI. Upload a photo, pick a dance, get a vertical 9:16 video.","url":"${process.env.PUBLIC_URL || ""}","featureList":["AI dance generation from photo","TikTok/Reels/Shorts ready","Trending templates","Creator monetization"]}
</script>
<meta name="description" content="AI-powered dance video generator from a single selfie. Perfect for TikTok, Instagram Reels and YouTube Shorts. Upload photo → pick trend → get viral video.">
<meta name="keywords" content="AI dance video, TikTok dance generator, selfie to dance, AI video generator, SnapDance">
<link rel="alternate" type="text/plain" href="/llms.txt" title="LLM-friendly summary">
\n`;
      }
      if (inject) {
        html = html.replace("</head>", inject + "</head>");
      }
      res.writeHead(200, h);
      return res.end(html);
    }
    res.writeHead(200, h);
    return fs6.createReadStream(file).pipe(res);
  }
  if (pathname === "/robots.txt") {
    res.writeHead(200, { "content-type": "text/plain" });
    return res.end("User-agent: *\nAllow: /\nDisallow: /admin\nDisallow: /api/\nSitemap: " + (process.env.PUBLIC_URL || "") + "/sitemap.xml\n");
  }
  if (pathname === "/llms.txt") {
    res.writeHead(200, { "content-type": "text/plain; charset=utf-8" });
    return res.end(`# SnapDance — AI Dance Video Generator

SnapDance lets users upload a selfie and get a trending vertical dance video ready for TikTok, Reels and Shorts.

## How it works
1. Upload 1-3 photos of the same person (full body + face angles).
2. Choose a viral dance template or a style.
3. AI generates a 9:16 video that looks phone-shot.
4. Share or download.

Creators can upload their own dance templates and earn when others use them.

Official site: ${process.env.PUBLIC_URL || "https://snapdance.app"}
`);
  }
  res.writeHead(302, { location: "/" });
  res.end();
}
http.createServer(async (req, res) => {
  const url = new URL(req.url, "http://x");
  const handler = routes[`${req.method} ${url.pathname}`];
  try {
    if (handler) return await handler(req, res, url);
    if (url.pathname.startsWith("/api/")) return json(res, { error: tr("\u041D\u0435 \u043D\u0430\u0439\u0434\u0435\u043D\u043E", langOf(req)) }, 404);
    if (url.pathname.startsWith("/media/") && (req.method === "GET" || req.method === "HEAD")) {
      if (serveMedia(req, res, url.pathname.slice(7))) return;
      res.writeHead(404);
      return res.end();
    }
    serveStatic(req, res, url.pathname);
  } catch (e) {
    if (!(e instanceof UserError2)) console.error(e);
    if (!res.headersSent) json(res, { error: tr(e instanceof UserError2 ? e.message : "\u0412\u043D\u0443\u0442\u0440\u0435\u043D\u043D\u044F\u044F \u043E\u0448\u0438\u0431\u043A\u0430 \u0441\u0435\u0440\u0432\u0435\u0440\u0430. \u041F\u043E\u043F\u0440\u043E\u0431\u0443\u0439\u0442\u0435 \u0435\u0449\u0451 \u0440\u0430\u0437.", url.pathname.startsWith("/api/admin") ? "ru" : langOf(req)) }, e.status || 500);
  }
}).listen(PORT, () => console.log(`${BRAND}: \u0441\u0435\u0440\u0432\u0438\u0441 \u0437\u0430\u043F\u0443\u0449\u0435\u043D \u043D\u0430 \u043F\u043E\u0440\u0442\u0443 ${PORT}. \u0414\u0430\u043D\u043D\u044B\u0435: ${DATA_DIR}${PERSISTENT ? "" : " (Volume \u043D\u0435 \u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0451\u043D!)"}`));
setInterval(() => {
  if (busy()) poll().catch(() => {
  });
}, 4e3);
setInterval(() => cleanup(), 6 * 3600 * 1e3);

