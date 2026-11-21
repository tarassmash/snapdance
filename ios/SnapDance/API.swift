import Foundation

// MARK: - Данные сервера

struct Catalog: Decodable {
    struct Model: Decodable { let id: String; let name: String; let perSec: Double }
    struct Frame: Decodable { let id: String; let name: String; let price: Int }
    let trendModels: [Model]
    let frameModels: [Frame]
}

struct AppConfig: Decodable {
    let brand: String
    let contact: String?
    let catalog: Catalog
    let examples: [Example]?

    /// Цена в рубинах — та же формула, что на сайте.
    func price(seconds: Double) -> Int? {
        guard let m = catalog.trendModels.first(where: { $0.id == SDConfig.model }) else { return nil }
        let fr = catalog.frameModels.first(where: { $0.id == SDConfig.frame })?.price ?? 0
        let secs = max(1, Int(ceil(min(seconds, SDConfig.maxRefSeconds))))
        return fr + Int(ceil(Double(secs) * m.perSec))
    }
}

struct Job: Decodable, Identifiable, Equatable {
    let id: String
    let status: String          // working | done | failed
    let stage: String?
    let result: String?
    let poster: String?
    let seconds: Int?
    let created: Double
    let expires: Double?
    let paid: Int?

    var resultURL: URL? { result.flatMap { $0.isEmpty ? nil : URL(string: $0, relativeTo: SDConfig.api)?.absoluteURL } }
    var posterURL: URL? { poster.flatMap { $0.isEmpty ? nil : URL(string: $0, relativeTo: SDConfig.api)?.absoluteURL } }
    var isWorking: Bool { status == "working" || status == "queued" }

    /// Примерный прогресс по этапу (как на сайте).
    var progress: Double {
        switch stage ?? "" {
        case "frame": return 0.15
        case "video": return 0.45
        case "lock": return 0.7
        case "enhance": return 0.85
        case "post": return 0.95
        default: return 0.08
        }
    }
}

struct Upload: Decodable { let path: String; let duration: Double? }
struct JobsResponse: Decodable { let credits: Int; let jobs: [Job] }
struct CreateResponse: Decodable { let job: Job; let credits: Int }
struct MeResponse: Decodable { let key: String; let credits: Int }
struct IAPResult: Decodable { let key: String; let added: Int; let credits: Int }
struct IAPProduct: Decodable { let productId: String; let pack: String; let credits: Int; let popular: Bool }
struct IAPProducts: Decodable { let products: [IAPProduct] }
struct CaptionResponse: Decodable { let caption: String }

struct APIError: LocalizedError {
    let message: String
    let status: Int
    var errorDescription: String? { message }
}

// MARK: - Клиент

final class API {
    static let shared = API()
    var key: String = ""

    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 60
        c.timeoutIntervalForResource = 600
        return URLSession(configuration: c)
    }()

    private func request(_ path: String, method: String = "GET", body: Data? = nil, contentType: String = "application/json") -> URLRequest {
        var r = URLRequest(url: URL(string: path, relativeTo: SDConfig.api)!.absoluteURL)
        r.httpMethod = method
        r.setValue(key, forHTTPHeaderField: "x-key")
        r.setValue(appLang.rawValue, forHTTPHeaderField: "x-lang")
        r.setValue("SnapDanceApp/2.0 iOS", forHTTPHeaderField: "x-client")
        if let body { r.httpBody = body; r.setValue(contentType, forHTTPHeaderField: "content-type") }
        return r
    }

    private func send<T: Decodable>(_ r: URLRequest, as: T.Type) async throws -> T {
        let data: Data, resp: URLResponse
        do { (data, resp) = try await session.data(for: r) } catch { throw APIError(message: L("err.net"), status: 0) }
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(code) else {
            let msg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? String
            throw APIError(message: msg ?? "Error \(code)", status: code)
        }
        do { return try JSONDecoder().decode(T.self, from: data) } catch { throw APIError(message: "Bad response", status: code) }
    }

    private func json<T: Decodable>(_ path: String, _ body: [String: Any], as t: T.Type) async throws -> T {
        let data = try JSONSerialization.data(withJSONObject: body)
        return try await send(request(path, method: "POST", body: data), as: t)
    }

    func config() async throws -> AppConfig { try await send(request("/api/config"), as: AppConfig.self) }
    func me() async throws -> MeResponse { try await send(request("/api/me"), as: MeResponse.self) }
    func jobs() async throws -> JobsResponse { try await send(request("/api/jobs"), as: JobsResponse.self) }
    func products() async throws -> [IAPProduct] { try await send(request("/api/iap/products"), as: IAPProducts.self).products }

    func upload(_ data: Data, kind: String, contentType: String) async throws -> Upload {
        var r = request("/api/upload?kind=\(kind)", method: "POST", body: data, contentType: contentType)
        r.timeoutInterval = 300
        return try await send(r, as: Upload.self)
    }

    func create(photos: [String?], refPath: String, seconds: Double, place: String, glasses: String) async throws -> CreateResponse {
        let ps: [Any] = photos.map { p -> Any in p.map { $0 as Any } ?? NSNull() }
        let faceIdx = photos.count > 1 && photos[1] != nil ? 1 : (photos.count > 2 && photos[2] != nil ? 2 : 0)
        return try await json("/api/jobs", [
            "mode": "trend", "photos": ps, "faceIdx": faceIdx, "consent": true, "adult": true, "ref": refPath, "keepSound": true,
            "model": SDConfig.model, "style": "hands", "dur": min(seconds, SDConfig.maxRefSeconds), "extra": "",
            "frame": SDConfig.frame, "faceLock": false, "enhance": false, "phone": "oldiphone", "cam": "tripod", "place": place, "glasses": glasses,
            "author": "", "lang": appLang.rawValue,
        ], as: CreateResponse.self)
    }

    func delete(job id: String) async throws {
        struct OK: Decodable { let ok: Bool }
        _ = try await json("/api/jobs/delete", ["id": id], as: OK.self)
    }

    func caption(for job: Job) async throws -> String {
        try await json("/api/caption", ["mode": "trend", "style": "hands", "platform": "tt", "id": job.id], as: CaptionResponse.self).caption
    }

    func verifyPurchase(jws: String) async throws -> IAPResult {
        try await json("/api/iap/verify", ["jws": jws, "key": key], as: IAPResult.self)
    }
}
