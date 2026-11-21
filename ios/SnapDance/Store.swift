import Foundation
import StoreKit

/// Покупка рубинов через App Store (StoreKit 2).
/// Каждая покупка — расходуемый товар (Consumable). Подписанную Apple транзакцию проверяет сервер
/// (POST /api/iap/verify) и начисляет рубины на код SD-…; только после этого транзакция закрывается.
@MainActor
final class Store: ObservableObject {
    struct Pack: Identifiable {
        let product: Product
        let credits: Int
        let popular: Bool
        var id: String { product.id }
    }

    @Published var packs: [Pack] = []
    @Published var loading = false
    @Published var buying: String?
    @Published var loadError: String?

    private weak var model: AppModel?
    private var updates: Task<Void, Never>?

    init(model: AppModel) {
        self.model = model
        // Покупки, которые завершились вне приложения или не успели дойти до сервера (сеть, закрыли приложение).
        updates = Task { [weak self] in
            for await result in Transaction.updates { await self?.handle(result) }
        }
        Task { [weak self] in
            for await result in Transaction.unfinished { await self?.handle(result) }
        }
    }

    deinit { updates?.cancel() }

    func load() async {
        guard packs.isEmpty, !loading else { return }
        loading = true; loadError = nil
        defer { loading = false }
        do {
            // Количество рубинов берём с сервера, цены — из App Store (в валюте пользователя).
            let server = (try? await API.shared.products()) ?? []
            var ids = server.map(\.productId)
            if ids.isEmpty { ids = ["start", "pop", "pro"].map { SDConfig.productPrefix + $0 } }
            let products = try await Product.products(for: ids)
            packs = products.map { p in
                let info = server.first { $0.productId == p.id }
                return Pack(product: p, credits: info?.credits ?? 0, popular: info?.popular ?? false)
            }.sorted { $0.product.price < $1.product.price }
            if packs.isEmpty { loadError = L("buy.none") }
        } catch {
            loadError = L("buy.none")
        }
    }

    /// Возвращает текст для пользователя (успех, ожидание или ошибка) либо nil, если покупку отменили.
    func buy(_ pack: Pack) async -> String? {
        buying = pack.id
        defer { buying = nil }
        do {
            switch try await pack.product.purchase() {
            case .success(let result):
                return await handle(result)
            case .pending:
                return L("buy.pending")
            case .userCancelled:
                return nil
            @unknown default:
                return nil
            }
        } catch {
            return L("buy.fail", ["e": error.localizedDescription])
        }
    }

    @discardableResult
    private func handle(_ result: VerificationResult<Transaction>) async -> String? {
        guard case .verified(let tx) = result else { return L("buy.fail", ["e": "verification"]) }
        guard tx.productType == .consumable, tx.revocationDate == nil else { await tx.finish(); return nil }
        #if DEBUG
        // Локальный тест StoreKit в Xcode (Products.storekit): Apple не подписывает такие покупки, сервер их не примет
        if tx.environment == .xcode {
            await tx.finish()
            return L("buy.xcode")
        }
        #endif
        do {
            let r = try await API.shared.verifyPurchase(jws: result.jwsRepresentation)
            await tx.finish()
            if let model { model.credited(key: r.key, credits: r.credits, added: r.added) }
            else { UserDefaults.standard.set(r.key, forKey: "sd-key") }
            return L("buy.ok", ["n": String(r.added)])
        } catch {
            // Не закрываем транзакцию: StoreKit отдаст её снова (Transaction.unfinished), рубины не пропадут.
            return L("buy.fail", ["e": error.localizedDescription])
        }
    }
}
