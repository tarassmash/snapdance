import SwiftUI
import PhotosUI

// MARK: - Главный экран

@MainActor
struct ContentView: View {
    @EnvironmentObject var model: AppModel
    @EnvironmentObject var store: Store
    @State private var showMine = false

    var body: some View {
        NavigationStack {
            ZStack {
                SDConfig.bg.ignoresSafeArea()
                if let job = model.activeJob {
                    JobView(job: job)
                } else {
                    CreateView()
                }
            }
            .navigationTitle("SnapDance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showMine = true } label: { Image(systemName: "square.stack") }
                        .accessibilityLabel(L("mine"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { model.walletReason = nil; model.showWallet = true } label: {
                        Text("💎 \(model.credits)").font(.subheadline.weight(.bold)).monospacedDigit()
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(SDConfig.panel2, in: Capsule())
                    }
                    .accessibilityLabel(L("wallet"))
                }
            }
            .toolbarBackground(SDConfig.bg, for: .navigationBar)
            .sheet(isPresented: $showMine) { MyVideosView(close: { showMine = false }) }
            .sheet(isPresented: $model.showWallet) { WalletView() }
            .overlay(alignment: .bottom) { ToastView() }
        }
        .tint(SDConfig.lime)
        .preferredColorScheme(.dark)
        .task { await model.start() }
    }
}

// MARK: - Создание

@MainActor
struct CreateView: View {
    @EnvironmentObject var model: AppModel
    @State private var photoItems: [PhotosPickerItem?] = [nil, nil, nil]
    @State private var movieItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(L("tagline")).font(.system(size: 28, weight: .heavy)).padding(.top, 6)

                Card(step: "1", title: L("step1"), subtitle: L("step1s")) {
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { i in photoSlot(i) }
                    }
                }

                Card(step: "2", title: L("step2"), subtitle: L("step2s")) {
                    let thumb = model.ref?.thumb, refSecs = model.ref?.seconds
                    VStack(alignment: .leading, spacing: 10) {
                        PhotosPicker(selection: $movieItem, matching: .videos, photoLibrary: .shared()) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(SDConfig.panel2)
                                    if let t = thumb {
                                        Image(uiImage: t).resizable().scaledToFill()
                                    } else {
                                        Image(systemName: "film").font(.title2).foregroundStyle(SDConfig.muted)
                                    }
                                }
                                .frame(width: 64, height: 96).clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(refSecs == nil ? L("ref.pick") : L("ref.change")).font(.headline)
                                    if let secs = refSecs { Text(L("secs", ["s": String(Int(secs.rounded()))])).font(.subheadline).foregroundStyle(SDConfig.muted) }
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(SDConfig.muted)
                            }
                            .padding(10)
                            .background(SDConfig.panel2.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        Link(destination: SDConfig.trendsURL) {
                            Label(L("ref.trends"), systemImage: "arrow.up.right.square").font(.subheadline.weight(.semibold))
                        }
                    }
                }

                Toggle(isOn: $model.consent) {
                    Text(L("consent")).font(.footnote).foregroundStyle(SDConfig.muted)
                }
                .toggleStyle(CheckToggle())

                if let e = model.error {
                    Text(e).font(.subheadline.weight(.semibold)).foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 8) {
                    Button { Task { await model.generate() } } label: {
                        HStack(spacing: 10) {
                            if model.busyText != nil { ProgressView().tint(.black) }
                            Text(model.busyText ?? L("go"))
                            if model.busyText == nil, let p = model.price {
                                Text("💎 \(p)").font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 9).padding(.vertical, 4)
                                    .background(Color.black.opacity(0.1), in: Capsule())
                            }
                        }
                        .lineLimit(1)
                    }
                    .buttonStyle(PrimaryButton())
                    .disabled(model.busyText != nil)
                    Text(L("inc")).font(.caption).foregroundStyle(SDConfig.muted)
                }

                HStack(spacing: 16) {
                    Link(L("privacy"), destination: SDConfig.privacyURL)
                    Link(L("terms"), destination: SDConfig.termsURL)
                    Link(L("report"), destination: SDConfig.reportURL)
                }
                .font(.caption).foregroundStyle(SDConfig.muted).frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: movieItem) { item in
            guard let item else { return }
            Task {
                model.busyText = L("busy.ref")
                if let movie = try? await item.loadTransferable(type: PickedMovie.self) {
                    await model.setReference(movie.url)
                } else {
                    model.busyText = nil
                    model.error = L("err.video")
                }
                movieItem = nil
            }
        }
    }

    @ViewBuilder private func photoSlot(_ i: Int) -> some View {
        let binding = Binding<PhotosPickerItem?>(get: { photoItems[i] }, set: { photoItems[i] = $0 })
        let image = model.photos[i]?.image
        PhotosPicker(selection: binding, matching: .images, photoLibrary: .shared()) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(SDConfig.panel2)
                    if let image {
                        Image(uiImage: image).resizable().scaledToFill()
                    } else {
                        Image(systemName: i == 0 ? "person.fill" : "plus").font(.title2).foregroundStyle(i == 0 ? SDConfig.lime : SDConfig.muted)
                    }
                }
                .frame(maxWidth: .infinity).aspectRatio(3 / 4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(i == 0 && image == nil ? SDConfig.lime.opacity(0.6) : SDConfig.line, lineWidth: 1))
                Text(L("slot.\(i + 1)")).font(.caption.weight(.semibold)).lineLimit(1)
                Text(i == 0 ? L("slot.1s") : L("opt")).font(.caption2).foregroundStyle(SDConfig.muted)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            if model.photos[i] != nil { Button(role: .destructive) { model.photos[i] = nil } label: { Label(L("del"), systemImage: "trash") } }
        }
        .onChange(of: photoItems[i]) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) { model.setPhoto(data, slot: i) }
                photoItems[i] = nil
            }
        }
    }
}

// MARK: - Ход создания и результат

@MainActor
struct JobView: View {
    @EnvironmentObject var model: AppModel
    let job: Job

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if job.status == "done", let url = job.resultURL {
                    ResultView(job: job, url: url)
                } else if job.status == "failed" {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 44)).foregroundStyle(.orange)
                        Text(L("st.failed")).font(.title3.bold()).multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 18) {
                        ProgressView(value: job.progress).tint(SDConfig.lime).scaleEffect(x: 1, y: 2)
                        Text(L("work.title")).font(.title2.bold())
                        Text(L("work.sub")).font(.subheadline).foregroundStyle(SDConfig.muted).multilineTextAlignment(.center)
                    }
                    .padding(.top, 80).padding(.horizontal, 12)
                    .animation(.easeInOut, value: job.progress)
                }
                Button(L("again")) { model.resetCreate() }
                    .buttonStyle(SecondaryButton())
                    .padding(.top, 8)
            }
            .padding(16)
        }
    }
}

@MainActor
struct ResultView: View {
    @EnvironmentObject var model: AppModel
    let job: Job
    let url: URL
    @State private var working = false
    @State private var share: ShareItem?

    var body: some View {
        VStack(spacing: 14) {
            Text(L("done")).font(.title2.bold())
            LoopingVideo(url: url)
                .aspectRatio(9 / 16, contentMode: .fit)
                .frame(maxHeight: 460)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(SDConfig.line))

            Button { Task { await postToTikTok() } } label: {
                Label(L("tiktok"), systemImage: "music.note").lineLimit(1)
            }
            .buttonStyle(TikTokButton())
            .disabled(working)

            HStack(spacing: 10) {
                Button { Task { await save() } } label: { Label(L("save"), systemImage: "square.and.arrow.down") }
                    .buttonStyle(SecondaryButton())
                Button { Task { await shareFile() } } label: { Label(L("share"), systemImage: "square.and.arrow.up") }
                    .buttonStyle(SecondaryButton())
            }
            .disabled(working)
            Text(L("videos7")).font(.caption).foregroundStyle(SDConfig.muted)
        }
        .sheet(item: $share) { ShareSheet(items: $0.items).ignoresSafeArea() }
    }

    private func file() async -> URL? {
        working = true
        defer { working = false }
        do { return try await Media.download(url, id: job.id) } catch { model.toast = error.localizedDescription; return nil }
    }

    private func save() async {
        guard let f = await file() else { return }
        do { try await Media.saveToPhotos(f); model.toast = L("saved") } catch { model.toast = error.localizedDescription }
    }

    private func shareFile() async {
        guard let f = await file() else { return }
        share = ShareItem(items: [f])
    }

    /// TikTok: копируем подпись и открываем меню «Поделиться» с готовым файлом — пользователь выбирает TikTok.
    private func postToTikTok() async {
        guard let f = await file() else { return }
        let caption = (try? await API.shared.caption(for: job)) ?? "#dance #trend #fyp #AI"
        UIPasteboard.general.string = caption
        model.toast = L("tt.hint")
        share = ShareItem(items: [f])
    }
}

// MARK: - Мои видео

@MainActor
struct MyVideosView: View {
    @EnvironmentObject var model: AppModel
    let close: () -> Void
    @State private var toDelete: Job?

    var body: some View {
        NavigationStack {
            List {
                if model.jobs.isEmpty {
                    Text(L("mine.empty")).foregroundStyle(SDConfig.muted).listRowBackground(SDConfig.panel)
                }
                ForEach(model.jobs) { job in
                    Button {
                        model.activeJobID = job.id
                        close()
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: job.posterURL) { img in img.resizable().scaledToFill() } placeholder: { SDConfig.panel2 }
                                .frame(width: 48, height: 72).clipShape(RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Date(timeIntervalSince1970: job.created / 1000), style: .date).font(.subheadline.weight(.semibold))
                                Text(job.status == "done" ? L("st.done") : job.status == "failed" ? L("st.failed") : L("st.working"))
                                    .font(.caption).foregroundStyle(job.status == "failed" ? .orange : SDConfig.muted)
                            }
                            Spacer()
                            if job.isWorking { ProgressView() }
                        }
                    }
                    .listRowBackground(SDConfig.panel)
                    .swipeActions {
                        if !job.isWorking { Button(L("del"), role: .destructive) { toDelete = job } }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(SDConfig.bg)
            .navigationTitle(L("mine"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(L("close"), action: close) } }
            .refreshable { await model.loadJobs() }
            .confirmationDialog(L("del.q"), isPresented: Binding(get: { toDelete != nil }, set: { if !$0 { toDelete = nil } }), titleVisibility: .visible) {
                Button(L("del"), role: .destructive) { if let j = toDelete { Task { await model.delete(j) } } }
                Button(L("cancel"), role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
        .task { await model.loadJobs() }
    }
}

// MARK: - Рубины: покупка в App Store и код

@MainActor
struct WalletView: View {
    @EnvironmentObject var model: AppModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var codeError: String?
    @State private var showCodeEntry = false
    @State private var confirmLogout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(L("balance")).foregroundStyle(SDConfig.muted)
                        Spacer()
                        Text("💎 \(model.credits)").font(.title2.bold()).monospacedDigit()
                    }
                    .padding(14).background(SDConfig.panel, in: RoundedRectangle(cornerRadius: 16))

                    if let r = model.walletReason { Text(r).font(.subheadline.weight(.semibold)).foregroundStyle(.orange) }

                    Text(L("buy")).font(.headline)
                    if store.loading { HStack { ProgressView(); Text(L("buy.load")).foregroundStyle(SDConfig.muted) } }
                    if let e = store.loadError { Text(e).foregroundStyle(SDConfig.muted) }
                    ForEach(store.packs) { pack in
                        Button {
                            Task {
                                if let msg = await store.buy(pack) {
                                    model.toast = msg
                                    if msg == L("buy.ok", ["n": String(pack.credits)]) { dismiss() }
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("💎 \(pack.credits) \(L("rubies"))").font(.headline)
                                    Text(pack.product.displayName).font(.caption).foregroundStyle(SDConfig.muted)
                                }
                                Spacer()
                                if store.buying == pack.id { ProgressView() } else {
                                    Text(pack.product.displayPrice).font(.headline).foregroundStyle(.black)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(SDConfig.lime, in: Capsule())
                                }
                            }
                            .padding(14)
                            .background(SDConfig.panel, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(pack.popular ? SDConfig.lime : SDConfig.line, lineWidth: pack.popular ? 1.5 : 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(store.buying != nil)
                    }

                    if !model.key.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("code")).font(.headline)
                            Text(model.key).font(.system(.title3, design: .monospaced).weight(.bold)).textSelection(.enabled)
                            Text(L("code.hint")).font(.caption).foregroundStyle(SDConfig.muted)
                            HStack {
                                Button(L("code.copy")) { UIPasteboard.general.string = model.key; model.toast = L("code.copied") }
                                Spacer()
                                Button(L("logout"), role: .destructive) { confirmLogout = true }
                            }
                            .font(.subheadline.weight(.semibold))
                        }
                        .padding(14).background(SDConfig.panel, in: RoundedRectangle(cornerRadius: 16))
                    }

                    DisclosureGroup(L("code.enter"), isExpanded: $showCodeEntry) {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField(L("code.ph"), text: $code)
                                .textInputAutocapitalization(.characters).autocorrectionDisabled()
                                .font(.system(.body, design: .monospaced))
                                .padding(12).background(SDConfig.panel2, in: RoundedRectangle(cornerRadius: 12))
                            if let e = codeError { Text(e).font(.caption).foregroundStyle(.red) }
                            Button(L("code.login")) {
                                Task {
                                    if await model.login(code: code) { codeError = nil; dismiss() } else { codeError = L("code.bad") }
                                }
                            }
                            .buttonStyle(SecondaryButton())
                        }
                        .padding(.top, 8)
                    }
                    .tint(.white)

                    HStack(spacing: 16) {
                        Link(L("privacy"), destination: SDConfig.privacyURL)
                        Link(L("terms"), destination: SDConfig.termsURL)
                    }
                    .font(.caption).foregroundStyle(SDConfig.muted).frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .background(SDConfig.bg)
            .navigationTitle(L("wallet"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(L("close")) { dismiss() } } }
            .confirmationDialog(L("logout.q"), isPresented: $confirmLogout, titleVisibility: .visible) {
                Button(L("logout"), role: .destructive) { model.logout() }
                Button(L("cancel"), role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .task { await store.load() }
    }
}
