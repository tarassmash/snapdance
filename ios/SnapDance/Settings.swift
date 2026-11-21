import SwiftUI
import SafariServices

// MARK: - Настройки: поделиться, оценить, написать разработчикам, условия, EULA, конфиденциальность

enum Links {
    static let appStore = URL(string: "https://apps.apple.com/app/id6837738468")!
    static let writeReview = URL(string: "https://apps.apple.com/app/id6837738468?action=write-review")!
    static let eula = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let supportEmail = "tmonchak@gmail.com"
}

struct SettingsView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var web: WebPage?

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ShareLink(item: Links.appStore, subject: Text("SnapDance"), message: Text(L("set.shareMsg"))) {
                        row("square.and.arrow.up", L("set.share"))
                    }
                    Button { openURL(Links.writeReview) } label: { row("star.fill", L("set.rate")) }
                    Button { writeToUs() } label: { row("envelope.fill", L("set.write")) }
                }
                .listRowBackground(SDConfig.panel)

                Section {
                    Button { web = WebPage(url: SDConfig.termsURL) } label: { row("doc.text", L("set.terms")) }
                    Button { web = WebPage(url: Links.eula) } label: { row("checkmark.seal", L("set.eula")) }
                    Button { web = WebPage(url: SDConfig.privacyURL) } label: { row("hand.raised.fill", L("set.privacy")) }
                    Button { web = WebPage(url: SDConfig.reportURL) } label: { row("exclamationmark.bubble", L("report")) }
                }
                .listRowBackground(SDConfig.panel)

                Section {
                    Button { dismiss(); DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { model.walletReason = nil; model.showWallet = true } } label: {
                        row("diamond.fill", "\(L("wallet")): 💎 \(model.credits)")
                    }
                } footer: {
                    Text("SnapDance \(version)").frame(maxWidth: .infinity).padding(.top, 12)
                }
                .listRowBackground(SDConfig.panel)
            }
            .scrollContentBackground(.hidden)
            .background(SDConfig.bg)
            .navigationTitle(L("set.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(L("close")) { dismiss() } } }
            .sheet(item: $web) { SafariView(url: $0.url).ignoresSafeArea() }
        }
        .preferredColorScheme(.dark)
    }

    private func row(_ icon: String, _ title: String) -> some View {
        Label {
            Text(title).foregroundStyle(.white).lineLimit(1).minimumScaleFactor(0.7)
        } icon: {
            Image(systemName: icon).foregroundStyle(SDConfig.lime)
        }
    }

    private func writeToUs() {
        let subject = "SnapDance \(version)"
        let body = "\n\n—\n\(L("code")): \(model.key.isEmpty ? "-" : model.key)\niOS \(UIDevice.current.systemVersion), \(UIDevice.current.model)"
        var c = URLComponents()
        c.scheme = "mailto"
        c.path = Links.supportEmail
        c.queryItems = [URLQueryItem(name: "subject", value: subject), URLQueryItem(name: "body", value: body)]
        if let url = c.url { openURL(url) }
    }
}

struct WebPage: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

/// Страница сайта внутри приложения (Safari View Controller).
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = UIColor(SDConfig.lime)
        vc.preferredBarTintColor = UIColor(SDConfig.bg)
        vc.dismissButtonStyle = .close
        return vc
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
