import SwiftUI
import AVFoundation

// MARK: - Примеры «до / после» — те же, что на сайте (GET /api/config → examples)

struct Example: Decodable, Identifiable, Equatable {
    let id: String
    let before: String
    let after: String
    let poster: String?
    let caption: String?

    var beforeURL: URL? { URL(string: before, relativeTo: SDConfig.api)?.absoluteURL }
    var afterURL: URL? { URL(string: after, relativeTo: SDConfig.api)?.absoluteURL }
}

struct ExamplesSection: View {
    let examples: [Example]
    @State private var soundOn: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            (Text(L("ex.h2a")) + Text(L("ex.before.w")).italic().foregroundColor(SDConfig.lime) + Text(L("ex.and")) + Text(L("ex.after.w")).italic().foregroundColor(SDConfig.lime))
                .font(.system(size: 20, weight: .heavy))
            Text(L("ex.hint")).font(.footnote).foregroundStyle(SDConfig.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(Array(examples.enumerated()), id: \.element.id) { i, ex in
                        ExampleCard(example: ex, index: i, soundOn: $soundOn)
                            .frame(width: 220)
                    }
                }
                .padding(.bottom, 6)
            }
        }
    }
}

/// Одна карточка: видео «после», фото «до» в углу, стрелка, лента как в TikTok с растущими цифрами.
struct ExampleCard: View {
    let example: Example
    let index: Int
    @Binding var soundOn: String?
    @State private var started: Date?

    private var goal: (views: Double, likes: Double, comments: Double, shares: Double) {
        // те же формулы, что на сайте: просмотры растут с 1 примерно до 10–25 тысяч
        let v = Double(10400 + ((index * 7919) % 14600))
        return (v, (v * (0.11 + Double(index % 4) * 0.02)).rounded(), (v * 0.006).rounded() + 3, (v * 0.013).rounded() + 5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                ZStack(alignment: .topLeading) {
                    Color.black
                    if let url = example.afterURL {
                        LoopingPlayer(url: url, muted: soundOn != example.id)
                    }
                    // лёгкое затемнение снизу под подписями
                    LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                        .frame(height: h * 0.38).frame(maxHeight: .infinity, alignment: .bottom)

                    // ДО — фото в углу
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: example.beforeURL) { img in img.resizable().scaledToFill() } placeholder: { Color(white: 0.13) }
                        Text(L("ex.before")).font(.system(size: 10.5, weight: .heavy)).kerning(0.6)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Color.black.opacity(0.65), in: RoundedRectangle(cornerRadius: 6))
                            .foregroundStyle(.white).padding(4)
                    }
                    .frame(width: w * 0.34, height: w * 0.34 * 4 / 3)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.45), radius: 9, y: 6)
                    .offset(x: 10, y: 10)

                    // стрелка от фото к видео
                    TimelineView(.animation) { tl in
                        let t = started.map { tl.date.timeIntervalSince($0) } ?? 0
                        ArrowShape(head: false).trim(from: 0, to: min(1, max(0, (t - 0.3) / 1.1)))
                            .stroke(.white, style: StrokeStyle(lineWidth: 7 * w * 0.34 / 100, lineCap: .round, lineJoin: .round))
                            .overlay(ArrowShape(head: true).stroke(.white, style: StrokeStyle(lineWidth: 7 * w * 0.34 / 100, lineCap: .round, lineJoin: .round))
                                .opacity(t > 1.25 ? min(1, (t - 1.25) / 0.25) : 0))
                            .frame(width: w * 0.34, height: w * 0.34)
                            .shadow(color: .black.opacity(0.7), radius: 1.5, y: 2)
                    }
                    .offset(x: 10 + w * 0.31, y: h * 0.09)

                    // ПОСЛЕ
                    Text(L("ex.after")).font(.system(size: 10.5, weight: .heavy)).kerning(0.6)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(SDConfig.lime, in: RoundedRectangle(cornerRadius: 6))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .topTrailing).padding(10)

                    Text(soundOn == example.id ? "🔊" : "🔇").font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(Color.black.opacity(0.6), in: Capsule())
                        .frame(maxWidth: .infinity, alignment: .topTrailing).padding(.trailing, 10).padding(.top, 42)

                    FeedOverlay(started: started, goal: goal, user: L("ex.user"))
                }
                .frame(width: w, height: h)
            }
            .aspectRatio(9 / 16, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(SDConfig.line))
            .contentShape(Rectangle())
            .onTapGesture { soundOn = soundOn == example.id ? nil : example.id }
            .onAppear { if started == nil { started = Date() } }
            .onDisappear { started = nil; if soundOn == example.id { soundOn = nil } }

            if let c = example.caption, !c.isEmpty {
                Text(c).font(.system(size: 13.5)).foregroundStyle(SDConfig.muted).lineLimit(3)
            }
        }
    }
}

/// Правая колонка (аватар, лайки, комментарии, репосты), просмотры и ник — как в ленте TikTok.
private struct FeedOverlay: View {
    let started: Date?
    let goal: (views: Double, likes: Double, comments: Double, shares: Double)
    let user: String

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { tl in
            let t = started.map { tl.date.timeIntervalSince($0) } ?? 0
            let k = min(1, t / 6.5), e = k < 1 ? pow(k, 2.6) : 1   // медленный старт и быстрый рост — как у ролика, который «залетел»
            ZStack(alignment: .bottomLeading) {
                // летящие сердечки
                ForEach(0..<26, id: \.self) { i in
                    let born = Double(i + 1) * 0.38, age = t - born
                    if age > 0 && age < 1.8 {
                        let p = age / 1.8
                        HeartShape().fill(Color(red: 1, green: 0.18, blue: 0.33))
                            .frame(width: 22, height: 22)
                            .scaleEffect(0.6 + 0.65 * p)
                            .rotationEffect(.degrees(-25 + Double((i * 37) % 30) * p))
                            .opacity(p < 0.15 ? p / 0.15 : 1 - (p - 0.15) / 0.85)
                            .offset(x: -(10 + Double((i * 53) % 40)) * p, y: -150 * p)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .padding(.trailing, 16).padding(.bottom, 150)
                    }
                }

                VStack(spacing: 12) {
                    ZStack(alignment: .bottom) {
                        Circle().fill(LinearGradient(colors: [Color(red: 0.55, green: 0.36, blue: 1), SDConfig.lime], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay(Circle().stroke(.white, lineWidth: 2)).frame(width: 34, height: 34)
                        Text("+").font(.system(size: 13, weight: .heavy)).frame(width: 16, height: 16)
                            .background(Color(red: 1, green: 0.18, blue: 0.33), in: Circle()).offset(y: 8)
                    }
                    .padding(.bottom, 4)
                    item(HeartShape().fill(t > 1.4 ? Color(red: 1, green: 0.18, blue: 0.33) : .white).scaleEffect(t > 1.4 ? 1.12 : 1).animation(.easeOut(duration: 0.2), value: t > 1.4), n: goal.likes * e)
                    item(Image(systemName: "ellipsis.bubble.fill").resizable().scaledToFit(), n: goal.comments * e)
                    item(Image(systemName: "arrowshape.turn.up.right.fill").resizable().scaledToFit(), n: goal.shares * e)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 8).padding(.bottom, 54)

                HStack(spacing: 4) {
                    Image(systemName: "play.fill").font(.system(size: 10))
                    Text(compact(1 + (goal.views - 1) * e)).font(.system(size: 13, weight: .heavy)).monospacedDigit()
                }
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Color.black.opacity(0.35), in: Capsule())
                .padding(.leading, 10).padding(.bottom, 40)

                (Text("@\(user) ").fontWeight(.bold) + Text("#baile #fyp #ai").fontWeight(.medium))
                    .font(.system(size: 12.5)).lineLimit(1)
                    .padding(.leading, 10).padding(.trailing, 92).padding(.bottom, 12)
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.6), radius: 1.5, y: 1)
        }
        .allowsHitTesting(false)
    }

    private func item<V: View>(_ icon: V, n: Double) -> some View {
        VStack(spacing: 2) {
            icon.frame(width: 28, height: 28)
            Text(compact(n)).font(.system(size: 11, weight: .bold)).monospacedDigit()
        }
    }

    private func compact(_ v: Double) -> String {
        Int(v.rounded()).formatted(.number.notation(.compactName).precision(.fractionLength(0...1)).locale(Locale(identifier: appLang == .ru ? "ru_RU" : appLang == .es ? "es_ES" : "en_US")))
    }
}

/// Изогнутая стрелка (тот же путь, что на сайте: viewBox 0 0 100 100).
private struct ArrowShape: Shape {
    let head: Bool
    func path(in r: CGRect) -> Path {
        let s = r.width / 100
        var p = Path()
        if head {
            p.move(to: CGPoint(x: 66 * s, y: 70 * s)); p.addLine(to: CGPoint(x: 80 * s, y: 86 * s)); p.addLine(to: CGPoint(x: 92 * s, y: 68 * s))
        } else {
            p.move(to: CGPoint(x: 8 * s, y: 14 * s))
            p.addCurve(to: CGPoint(x: 80 * s, y: 82 * s), control1: CGPoint(x: 52 * s, y: 6 * s), control2: CGPoint(x: 84 * s, y: 30 * s))
        }
        return p
    }
}

/// Сердечко (тот же контур, что на сайте: viewBox 0 0 24 24).
struct HeartShape: Shape {
    func path(in r: CGRect) -> Path {
        let s = min(r.width, r.height) / 24
        func pt(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: r.minX + x * s, y: r.minY + y * s) }
        var p = Path()
        p.move(to: pt(12, 21))
        p.addCurve(to: pt(2.4, 11.9), control1: pt(12, 21), control2: pt(4.5, 16.4))
        p.addCurve(to: pt(6.7, 4.5), control1: pt(0.9, 8.6), control2: pt(2.9, 4.5))
        p.addCurve(to: pt(11, 6.9), control1: pt(8.8, 4.5), control2: pt(10.3, 5.7))
        p.addCurve(to: pt(15.3, 4.5), control1: pt(11.7, 5.7), control2: pt(13.2, 4.5))
        p.addCurve(to: pt(19.6, 11.9), control1: pt(19.1, 4.5), control2: pt(21.1, 8.6))
        p.addCurve(to: pt(12, 21), control1: pt(19.5, 16.4), control2: pt(12, 21))
        p.closeSubpath()
        return p
    }
}

// MARK: - Плеер без элементов управления (заполняет карточку, по кругу, звук по нажатию)

struct LoopingPlayer: UIViewRepresentable {
    let url: URL
    let muted: Bool

    final class PlayerView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        var looper: AVPlayerLooper?
    }

    func makeUIView(context: Context) -> PlayerView {
        let v = PlayerView()
        let player = AVQueuePlayer()
        v.looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        v.playerLayer.player = player
        v.playerLayer.videoGravity = .resizeAspectFill
        v.backgroundColor = .black
        player.isMuted = muted
        player.play()
        return v
    }

    func updateUIView(_ v: PlayerView, context: Context) {
        v.playerLayer.player?.isMuted = muted
        if !muted { try? AVAudioSession.sharedInstance().setCategory(.playback) }
        v.playerLayer.player?.play()
    }

    static func dismantleUIView(_ v: PlayerView, coordinator: ()) {
        v.playerLayer.player?.pause()
    }
}
