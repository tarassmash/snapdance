import SwiftUI

// MARK: - Настройки приложения

enum SDConfig {
    /// Сервер SnapDance (тот же, что у сайта).
    static let api = URL(string: "https://snapdance.us")!

    /// Префикс покупок в App Store Connect: <bundle id>.rubies.<пакет> (start / pop / pro).
    static var productPrefix: String { (Bundle.main.bundleIdentifier ?? "us.snapdance.app") + ".rubies." }

    static let privacyURL = URL(string: "https://snapdance.us/privacy")!
    static let termsURL = URL(string: "https://snapdance.us/terms")!
    static let reportURL = URL(string: "https://snapdance.us/report")!
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

enum Lang: String { case es, en, ru }

let appLang: Lang = {
    let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "es"
    if code == "ru" || code == "uk" || code == "be" { return .ru }
    if code == "es" || code == "ca" || code == "gl" || code == "eu" { return .es }
    return .en
}()

/// Сколько видео: «1 видео», «2 vídeos», «1 video».
func videosText(_ n: Int) -> String {
    switch appLang {
    case .ru: return "\(n) видео"
    case .es: return n == 1 ? "1 vídeo" : "\(n) vídeos"
    case .en: return n == 1 ? "1 video" : "\(n) videos"
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
