import SwiftUI
import UIKit

/// Состояние приложения: код SD-…, баланс, выбранные фото/ролик, задачи и их опрос.
@MainActor
final class AppModel: ObservableObject {
    struct Photo { let data: Data; let image: UIImage; var path: String? }
    struct Ref { let url: URL; let seconds: Double; let thumb: UIImage?; var path: String? }

    @Published var config: AppConfig?
    @Published var key: String = UserDefaults.standard.string(forKey: "sd-key") ?? "" {
        didSet { API.shared.key = key; UserDefaults.standard.set(key, forKey: "sd-key") }
    }
    @Published var credits = 0
    @Published var jobs: [Job] = []

    @Published var photos: [Photo?] = [nil, nil, nil]
    @Published var ref: Ref?
    /// Где танцует (как на фото, улица, комната…) и очки — запоминаются между запусками.
    @Published var place = UserDefaults.standard.string(forKey: "sd-place") ?? "photo" {
        didSet { UserDefaults.standard.set(place, forKey: "sd-place") }
    }
    @Published var glasses = UserDefaults.standard.string(forKey: "sd-glasses") ?? "none" {
        didSet { UserDefaults.standard.set(glasses, forKey: "sd-glasses") }
    }
    @Published var consent = UserDefaults.standard.bool(forKey: "sd-consent") {
        didSet { UserDefaults.standard.set(consent, forKey: "sd-consent") }
    }

    @Published var busyText: String?
    @Published var error: String?
    @Published var toast: String?
    @Published var activeJobID: String?
    @Published var showWallet = false
    @Published var walletReason: String?

    private var pollTask: Task<Void, Never>?

    init() { API.shared.key = key }

    var price: Int? { config?.price(seconds: ref?.seconds ?? 10) }
    var activeJob: Job? { jobs.first { $0.id == activeJobID } }

    // MARK: старт

    func start() async {
        if config == nil {
            do { config = try await API.shared.config() } catch { self.error = L("err.net") }
        }
        if !key.isEmpty {
            do { credits = try await API.shared.me().credits } catch let e as APIError where e.status == 401 || e.status == 400 { key = "" } catch {}
        }
        await loadJobs()
    }

    func loadJobs() async {
        guard !key.isEmpty else { jobs = []; return }
        do {
            let r = try await API.shared.jobs()
            credits = r.credits
            jobs = r.jobs
            if jobs.contains(where: \.isWorking) { startPolling() }
        } catch let e as APIError where e.status == 401 { key = "" } catch {}
    }

    private func startPolling() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                guard let self else { return }
                await self.loadJobs()
                if !self.jobs.contains(where: \.isWorking) { break }
            }
            self?.pollTask = nil
        }
    }

    // MARK: вход / покупки

    func credited(key newKey: String, credits: Int, added: Int) {
        let isNew = newKey != key
        key = newKey
        self.credits = credits
        toast = L("buy.ok", ["n": String(added)])
        if isNew { Task { await loadJobs() } }
    }

    func login(code: String) async -> Bool {
        let k = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !k.isEmpty else { return false }
        let old = key
        key = k
        do {
            credits = try await API.shared.me().credits
            await loadJobs()
            return true
        } catch {
            key = old
            return false
        }
    }

    func logout() {
        key = ""; credits = 0; jobs = []
    }

    // MARK: выбор фото и ролика

    func setPhoto(_ data: Data, slot: Int) {
        guard let (jpg, img) = Media.jpeg(from: data) else { error = L("err.photo"); return }
        photos[slot] = Photo(data: jpg, image: img, path: nil)
    }

    func setReference(_ url: URL) async {
        busyText = L("busy.ref")
        defer { busyText = nil }
        let original = await Media.duration(of: url)
        do {
            let (file, secs) = try await Media.prepareReference(url, maxSeconds: SDConfig.maxRefSeconds)
            let thumb = await Media.thumbnail(of: file)
            ref = Ref(url: file, seconds: secs, thumb: thumb, path: nil)
            if original > SDConfig.maxRefSeconds + 0.3 { toast = L("ref.cut", ["s": String(Int(SDConfig.maxRefSeconds))]) }
        } catch {
            self.error = L("err.video")
        }
    }

    // MARK: создание видео

    func generate() async {
        error = nil
        guard photos[0] != nil else { error = L("err.photo"); return }
        guard ref != nil else { error = L("err.ref"); return }
        guard consent else { error = L("err.consent"); return }
        guard let price else { error = L("err.net"); return }
        if key.isEmpty || credits < price {
            walletReason = key.isEmpty ? nil : L("buy.need", ["n": String(price), "m": String(credits)])
            showWallet = true
            return
        }
        do {
            for i in 0..<3 {
                if let p = photos[i], p.path == nil {
                    busyText = L("busy.photo", ["n": String(i + 1)])
                    photos[i]?.path = try await API.shared.upload(p.data, kind: "photo", contentType: "image/jpeg").path
                }
            }
            if let r = ref, r.path == nil {
                busyText = L("busy.ref")
                let data = try Data(contentsOf: r.url)
                let up = try await API.shared.upload(data, kind: "video", contentType: "video/mp4")
                ref?.path = up.path
                if let d = up.duration { ref = Ref(url: r.url, seconds: d, thumb: r.thumb, path: up.path) }
            }
            busyText = L("busy.start")
            let res = try await API.shared.create(photos: photos.map { $0?.path }, refPath: ref?.path ?? "", seconds: ref?.seconds ?? 10, place: place, glasses: glasses)
            credits = res.credits
            jobs.insert(res.job, at: 0)
            activeJobID = res.job.id
            busyText = nil
            startPolling()
        } catch let e as APIError {
            busyText = nil
            if e.status == 402 { walletReason = e.message; showWallet = true }
            else if e.status == 401 { key = ""; showWallet = true }
            else { error = e.message }
        } catch {
            busyText = nil
            self.error = error.localizedDescription
        }
    }

    func delete(_ job: Job) async {
        do {
            try await API.shared.delete(job: job.id)
            jobs.removeAll { $0.id == job.id }
            if activeJobID == job.id { activeJobID = nil }
        } catch { self.error = error.localizedDescription }
    }

    func resetCreate() {
        activeJobID = nil
        ref = nil
        photos = [nil, nil, nil]
    }
}
