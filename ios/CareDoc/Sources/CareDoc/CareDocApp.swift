import SwiftUI

@main
struct CareDocApp: App {
    @SwiftUI.State private var state = AppState()

    var body: some Scene {
        WindowGroup("Carrius") {
            RootView(state: state)
                #if os(macOS)
                .frame(width: 393, height: 852)   // iPhone 15 Pro 尺寸，CLT 驗證模式
                #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif
    }
}

struct RootView: View {
    @Bindable var state: AppState

    var body: some View {
        ZStack {
            CD.bg.ignoresSafeArea()

            if !state.hasOnboarded {
                WelcomeView(state: state)
                    .transition(.opacity)
            } else {
                mainContent
            }

            // 上傳 modal 流程（覆蓋全部）
            if state.uploadStep != .none {
                UploadFlowView(state: state)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .animation(CD.ease, value: state.hasOnboarded)
        .animation(CD.ease, value: state.uploadStep != .none)
        .preferredColorScheme(nil)   // 跟隨系統深淺色
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch state.tab {
                case .home: HomeView(state: state)
                case .calendar: CalendarScreen(state: state)
                case .documents: DocumentsView(state: state)
                case .garden: GardenView(state: state)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBarView(state: state)
                .padding(.bottom, 8)
        }
    }
}
