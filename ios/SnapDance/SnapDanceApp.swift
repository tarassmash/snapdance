import SwiftUI

@main
struct SnapDanceApp: App {
    @StateObject private var model: AppModel
    @StateObject private var store: Store

    init() {
        // Рубины, купленные в App Store, сервер начисляет на код SD-… (новый код создаётся при первой покупке).
        let m = AppModel()
        _model = StateObject(wrappedValue: m)
        _store = StateObject(wrappedValue: Store(model: m))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environmentObject(store)
        }
    }
}
