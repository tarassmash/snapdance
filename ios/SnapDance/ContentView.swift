import SwiftUI

struct ContentView: View {
    @StateObject private var model = WebViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            AppConfig.background.ignoresSafeArea()

            WebView(model: model)
                .ignoresSafeArea(edges: .bottom)

            if model.isLoading && model.progress < 1 {
                ProgressView(value: model.progress)
                    .progressViewStyle(.linear)
                    .tint(AppConfig.lime)
                    .frame(height: 2)
            }

            if let message = model.errorMessage {
                OfflineView(message: message) { model.reload() }
            }
        }
        .onAppear { model.loadIfNeeded() }
    }
}

private struct OfflineView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(AppConfig.lime)
            Text("Нет соединения")
                .font(.title2.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button(action: retry) {
                Text("Повторить")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(AppConfig.lime, in: Capsule())
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConfig.background.ignoresSafeArea())
    }
}
