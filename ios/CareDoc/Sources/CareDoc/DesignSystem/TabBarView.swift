import SwiftUI

/// 懸浮膠囊 Tab Bar：首頁／行事曆／中央上傳圓鈕／文件／花園
struct TabBarView: View {
    @Bindable var state: AppState

    var body: some View {
        HStack {
            tabItem(.home, system: "house")
            Spacer()
            tabItem(.calendar, system: "calendar")
            Spacer()
            centerButton
            Spacer()
            tabItem(.documents, system: "doc.text")
            Spacer()
            gardenItem
        }
        .padding(.horizontal, 22)
        .frame(height: 64)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(CD.cardBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
        .padding(.horizontal, 16)
    }

    private func tabItem(_ tab: Tab, system: String) -> some View {
        Button {
            guard state.tab != tab else { return }
            Haptics.shared.light()
            withAnimation(CD.ease) { state.tab = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: system)
                    .font(.system(size: 19, weight: .semibold))
                Text(tab.title).font(.cdBody(9.5, weight: .heavy))
                Capsule()
                    .fill(state.tab == tab ? CD.accent : .clear)
                    .frame(width: 14, height: 3)
            }
            .foregroundStyle(state.tab == tab ? CD.accent : CD.text3)
            .frame(width: 44)
        }
        .buttonStyle(.plain)
    }

    /// 花園用自訂小樹苗 icon
    private var gardenItem: some View {
        Button {
            guard state.tab != .garden else { return }
            Haptics.shared.light()
            withAnimation(CD.ease) { state.tab = .garden }
        } label: {
            VStack(spacing: 3) {
                SproutIcon()
                    .stroke(style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))
                    .frame(width: 20, height: 20)
                Text(Tab.garden.title).font(.cdBody(9.5, weight: .heavy))
                Capsule()
                    .fill(state.tab == .garden ? CD.accent : .clear)
                    .frame(width: 14, height: 3)
            }
            .foregroundStyle(state.tab == .garden ? CD.accent : CD.text3)
            .frame(width: 44)
        }
        .buttonStyle(.plain)
    }

    private var centerButton: some View {
        Button {
            state.startUpload()
        } label: {
            ZStack {
                Circle()
                    .fill(state.uploadStep == .none ? CD.accent : CD.lemon)
                    .frame(width: 54, height: 54)
                    .shadow(color: CD.accent.opacity(0.45), radius: 14, y: 4)
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(CD.plumDeep)
            }
        }
        .buttonStyle(PressScaleStyle())
        .offset(y: -14)
    }
}

/// 小樹苗：莖＋左右兩片葉＋地面線
struct SproutIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // 莖
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.88))
        p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.52))
        // 左葉
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.58))
        p.addCurve(to: CGPoint(x: w * 0.19, y: h * 0.27),
                   control1: CGPoint(x: w * 0.5, y: h * 0.40),
                   control2: CGPoint(x: w * 0.37, y: h * 0.27))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.58),
                   control1: CGPoint(x: w * 0.19, y: h * 0.45),
                   control2: CGPoint(x: w * 0.32, y: h * 0.58))
        // 右葉
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.48))
        p.addCurve(to: CGPoint(x: w * 0.83, y: h * 0.18),
                   control1: CGPoint(x: w * 0.5, y: h * 0.30),
                   control2: CGPoint(x: w * 0.64, y: h * 0.18))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.48),
                   control1: CGPoint(x: w * 0.83, y: h * 0.36),
                   control2: CGPoint(x: w * 0.68, y: h * 0.48))
        // 地面
        p.move(to: CGPoint(x: w * 0.30, y: h * 0.88))
        p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.88))
        return p
    }
}
