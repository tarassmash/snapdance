import SwiftUI
import UIKit
import WebKit

/// Обёртка WKWebView для SwiftUI.
struct WebView: UIViewRepresentable {
    @ObservedObject var model: WebViewModel

    func makeUIView(context: Context) -> WKWebView { model.webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

/// Держит WKWebView и обрабатывает навигацию, загрузку видео и диалоги сайта.
final class WebViewModel: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var progress: Double = 0
    @Published var errorMessage: String?

    let webView: WKWebView
    private var progressObservation: NSKeyValueObservation?
    private var downloadDestinations: [ObjectIdentifier: URL] = [:]
    private var didLoad = false

    override init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()              // сохраняет вход, код SD-… и рубины между запусками
        config.allowsInlineMediaPlayback = true           // видео-примеры играют прямо на странице
        config.mediaTypesRequiringUserActionForPlayback = []
        config.applicationNameForUserAgent = AppConfig.userAgentSuffix

        webView = WKWebView(frame: .zero, configuration: config)
        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(AppConfig.background)
        webView.scrollView.backgroundColor = UIColor(AppConfig.background)
        webView.scrollView.contentInsetAdjustmentBehavior = .never   // сайт сам учитывает safe-area
        #if DEBUG
        if #available(iOS 16.4, *) { webView.isInspectable = true }  // отладка через Safari → Разработка
        #endif

        let refresh = UIRefreshControl()
        refresh.tintColor = UIColor(AppConfig.lime)
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refresh

        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            DispatchQueue.main.async { self?.progress = webView.estimatedProgress }
        }
    }

    func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        webView.load(URLRequest(url: AppConfig.startURL))
    }

    func reload() {
        errorMessage = nil
        if webView.url == nil {
            webView.load(URLRequest(url: AppConfig.startURL))
        } else {
            webView.reload()
        }
    }

    @objc private func pullToRefresh(_ sender: UIRefreshControl) {
        reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { sender.endRefreshing() }
    }

    // MARK: - Помощники

    private func openExternally(_ url: URL) {
        UIApplication.shared.open(url)
    }

    private var presenter: UIViewController? {
        var top = webView.window?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }

    private func presentShareSheet(for fileURL: URL) {
        guard let presenter else { return }
        let sheet = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let pop = sheet.popoverPresentationController {       // iPad
            pop.sourceView = webView
            pop.sourceRect = CGRect(x: webView.bounds.midX, y: webView.bounds.midY, width: 1, height: 1)
            pop.permittedArrowDirections = []
        }
        presenter.present(sheet, animated: true)
    }

    private func showAlert(title: String?, message: String) {
        guard let presenter else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        presenter.present(alert, animated: true)
    }

    private func isIgnorableError(_ error: Error) -> Bool {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled { return true }
        if ns.domain == "WebKitErrorDomain" && ns.code == 102 { return true }   // «загрузка прервана» — так бывает при скачивании файла
        return false
    }
}

// MARK: - Навигация

extension WebViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return decisionHandler(.cancel) }

        // Ссылка «⬇ Скачать видео» (<a download>) → скачать файл и открыть меню «Поделиться».
        if navigationAction.shouldPerformDownload {
            return decisionHandler(.download)
        }

        // mailto:, tel:, tiktok:// и прочие схемы — в системные приложения.
        if let scheme = url.scheme?.lowercased(), !["http", "https", "about", "blob", "data"].contains(scheme) {
            openExternally(url)
            return decisionHandler(.cancel)
        }

        // TikTok, Instagram и т.п. — в их приложения, если пользователь сам нажал ссылку.
        if navigationAction.navigationType == .linkActivated, url.hostMatches(AppConfig.externalHosts) {
            openExternally(url)
            return decisionHandler(.cancel)
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let http = navigationResponse.response as? HTTPURLResponse,
           let disposition = http.value(forHTTPHeaderField: "Content-Disposition"),
           disposition.lowercased().hasPrefix("attachment") {
            return decisionHandler(.download)
        }
        decisionHandler(navigationResponse.canShowMIMEType ? .allow : .download)
    }

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        errorMessage = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        guard !isIgnorableError(error) else { return }
        errorMessage = error.localizedDescription
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()   // iOS выгрузил страницу из памяти — тихо перезагружаем
    }
}

// MARK: - Окна и диалоги сайта

extension WebViewModel: WKUIDelegate {
    /// target="_blank" и window.open: свой сайт и Stripe — в этом же окне, остальное — в Safari.
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            if url.hostMatches(AppConfig.internalHosts) {
                webView.load(navigationAction.request)
            } else {
                openExternally(url)
            }
        }
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard let presenter else { return completionHandler() }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        presenter.present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard let presenter else { return completionHandler(false) }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        presenter.present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        guard let presenter else { return completionHandler(nil) }
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { $0.text = defaultText }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        presenter.present(alert, animated: true)
    }
}

// MARK: - Скачивание видео

extension WebViewModel: WKDownloadDelegate {
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse,
                  suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let name = suggestedFilename.isEmpty ? "snapdance.mp4" : suggestedFilename
        let destination = folder.appendingPathComponent(name)
        downloadDestinations[ObjectIdentifier(download)] = destination
        completionHandler(destination)
    }

    func downloadDidFinish(_ download: WKDownload) {
        guard let url = downloadDestinations.removeValue(forKey: ObjectIdentifier(download)) else { return }
        // Меню «Поделиться»: «Сохранить видео» в Фото, TikTok, Instagram, AirDrop…
        presentShareSheet(for: url)
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        downloadDestinations.removeValue(forKey: ObjectIdentifier(download))
        showAlert(title: "Не удалось скачать", message: error.localizedDescription)
    }
}
