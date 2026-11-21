import SwiftUI
import UIKit
import AVFoundation
import Photos
import PhotosUI
import CoreTransferable
import UniformTypeIdentifiers

// MARK: - Видео из галереи (PhotosPicker → файл)

struct PickedMovie: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let dest = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + (received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension))
            try FileManager.default.copyItem(at: received.file, to: dest)
            return PickedMovie(url: dest)
        }
    }
}

enum Media {
    /// Фото → JPEG до 2048 px по длинной стороне (меньше трафика, сервер всё равно ужимает).
    static func jpeg(from data: Data) -> (Data, UIImage)? {
        guard let img = UIImage(data: data) else { return nil }
        let maxSide: CGFloat = 2048
        let size = img.size
        let scale = min(1, maxSide / max(size.width, size.height))
        let target = CGSize(width: floor(size.width * scale), height: floor(size.height * scale))
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let out = UIGraphicsImageRenderer(size: target, format: format).image { _ in img.draw(in: CGRect(origin: .zero, size: target)) }
        guard let jpg = out.jpegData(compressionQuality: 0.88) else { return nil }
        return (jpg, out)
    }

    /// Длительность ролика в секундах.
    static func duration(of url: URL) async -> Double {
        let asset = AVURLAsset(url: url)
        if let d = try? await asset.load(.duration) { return d.seconds.isFinite ? d.seconds : 0 }
        return 0
    }

    /// Обрезаем ролик до первых `maxSeconds` секунд и приводим к MP4 (меньше грузить, сервер всё равно режет до 15 с).
    static func prepareReference(_ url: URL, maxSeconds: Double) async throws -> (URL, Double) {
        let asset = AVURLAsset(url: url)
        let total = (try? await asset.load(.duration).seconds) ?? 0
        let length = total > 0 ? min(total, maxSeconds) : maxSeconds
        let presets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let preset = presets.contains(AVAssetExportPreset1920x1080) ? AVAssetExportPreset1920x1080 : AVAssetExportPresetHighestQuality
        guard let export = AVAssetExportSession(asset: asset, presetName: preset) else { return (url, total) }
        let out = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        export.outputURL = out
        export.outputFileType = .mp4
        export.shouldOptimizeForNetworkUse = true
        export.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: length, preferredTimescale: 600))
        await export.export()
        guard export.status == .completed else {
            if total > 0 && total <= maxSeconds { return (url, total) }   // короткий ролик — отправим как есть
            throw export.error ?? APIError(message: L("err.video"), status: 0)
        }
        return (out, length)
    }

    /// Первый кадр для превью ролика.
    static func thumbnail(of url: URL) async -> UIImage? {
        let gen = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = CGSize(width: 600, height: 600)
        return await withCheckedContinuation { cont in
            gen.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime(seconds: 0.5, preferredTimescale: 600))]) { _, cg, _, _, _ in
                cont.resume(returning: cg.map { UIImage(cgImage: $0) })
            }
        }
    }

    /// Скачивает готовое видео во временный файл (для «Сохранить» и «Поделиться»).
    static func download(_ remote: URL, id: String) async throws -> URL {
        let dest = FileManager.default.temporaryDirectory.appendingPathComponent("snapdance-\(id).mp4")
        if FileManager.default.fileExists(atPath: dest.path) { return dest }
        let (tmp, resp) = try await URLSession.shared.download(from: remote)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw APIError(message: L("err.net"), status: 0) }
        try? FileManager.default.removeItem(at: dest)
        try FileManager.default.moveItem(at: tmp, to: dest)
        return dest
    }

    /// Сохраняет видео в «Фото» (просит доступ только на добавление).
    static func saveToPhotos(_ file: URL) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { throw APIError(message: "Photos access denied", status: 0) }
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: file)
        }
    }
}

// MARK: - Системное меню «Поделиться»

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

/// Обёртка, чтобы показывать меню «Поделиться» через .sheet(item:).
struct ShareItem: Identifiable {
    let id = UUID()
    let items: [Any]
}
