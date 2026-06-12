import SwiftUI

@main
enum Main {
    static func main() {
        MainActor.assumeIsolated {
            if SnapshotRunner.runIfRequested() { return }
            CareDocApp.main()
        }
    }
}

/// 驗證用：`Carrius --snapshot <輸出資料夾>` 離屏渲染各畫面 PNG 後退出。
/// 只在 macOS 驗證版使用，不影響 iOS App。
enum SnapshotRunner {
    @MainActor
    static func runIfRequested() -> Bool {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--snapshot"), args.count > i + 1 else { return false }
        let dir = URL(fileURLWithPath: args[i + 1], isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        renderAll(to: dir)
        exit(0)
    }

    @MainActor
    private static func renderAll(to dir: URL) {
        let size = CGSize(width: 393, height: 852)

        func snap<V: View>(_ name: String, _ view: V) {
            let wrapped = view
                .environment(\.snapshotMode, true)
                .frame(width: size.width, height: size.height)
                .background(CD.bg)
                .environment(\.colorScheme, .dark)
            render(wrapped, name: "\(name)-dark", size: size, dir: dir)
            let light = view
                .environment(\.snapshotMode, true)
                .frame(width: size.width, height: size.height)
                .background(CD.bg)
                .environment(\.colorScheme, .light)
            render(light, name: "\(name)-light", size: size, dir: dir)
        }

        // 各畫面狀態
        let welcome = AppState()

        let home = AppState(); home.hasOnboarded = true

        let upload = AppState(); upload.hasOnboarded = true
        upload.uploadStep = .upload; upload.pickedCount = 3

        let followUp = AppState(); followUp.hasOnboarded = true
        followUp.uploadStep = .followUp

        let results = AppState(); results.hasOnboarded = true
        results.uploadStep = .results

        let calendar = AppState(); calendar.hasOnboarded = true; calendar.tab = .calendar
        let documents = AppState(); documents.hasOnboarded = true; documents.tab = .documents
        let garden = AppState(); garden.hasOnboarded = true; garden.tab = .garden

        snap("01-welcome", RootView(state: welcome))
        snap("02-home", RootView(state: home))
        snap("03-upload", RootView(state: upload))
        snap("05-followup", RootView(state: followUp))
        snap("06-results", RootView(state: results))
        snap("07-medcard", MedicationCardView(med: MockData.medications[0]))
        snap("08-calendar", RootView(state: calendar))
        snap("09-checklist", ChecklistView(state: home))
        snap("10-poster", PosterView(state: home))
        snap("11-documents", RootView(state: documents))
        snap("12-settings", SettingsView())
        snap("13-garden", RootView(state: garden))
        snap("14-breathing", BreathingView { _ in })

        // 樹的 5 個成長階段（淺色即可）
        for stage in TreeStage.allCases {
            let tree = SakuraTreeView(stage: stage, animate: false)
                .frame(width: 300, height: 300)
                .background(CD.bg)
                .environment(\.colorScheme, .light)
            render(tree, name: "tree-\(stage.rawValue)-\(stage.name)",
                   size: CGSize(width: 300, height: 300), dir: dir)
        }
    }

    @MainActor
    private static func render<V: View>(_ view: V, name: String, size: CGSize, dir: URL) {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = 2
        #if os(macOS)
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            print("snapshot FAILED: \(name)")
            return
        }
        try? png.write(to: dir.appendingPathComponent("\(name).png"))
        print("snapshot ok: \(name).png")
        #endif
    }
}
