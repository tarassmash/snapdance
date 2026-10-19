import SwiftUI

@main
struct SnapDanceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

enum AppConfig {
    /// Адрес сайта, который открывает приложение.
    static let startURL = URL(string: "https://snapdance.us/")!

    /// Домены, которые открываются внутри приложения (сайт и оплата Stripe).
    /// Всё остальное, открытое в новом окне, уходит в Safari / нужное приложение.
    static let internalHosts = ["snapdance.us", "stripe.com", "stripe.network"]

    /// Ссылки на эти сайты всегда открываются в их приложениях (TikTok и т.п.).
    static let externalHosts = ["tiktok.com", "instagram.com", "youtube.com", "youtu.be", "apps.apple.com"]

    /// Добавляется к User-Agent, чтобы сервер мог понять, что запрос из приложения.
    static let userAgentSuffix = "SnapDanceApp/1.0"

    static let background = Color(red: 12 / 255, green: 11 / 255, blue: 16 / 255)
    static let lime = Color(red: 198 / 255, green: 1, blue: 61 / 255)
}

extension URL {
    func hostMatches(_ domains: [String]) -> Bool {
        guard let host = host?.lowercased() else { return false }
        return domains.contains { host == $0 || host.hasSuffix("." + $0) }
    }
}
