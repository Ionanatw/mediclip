import SwiftUI

/// 畫面 10：照護海報（C 風格插圖 + 加購鎖定）
struct PosterView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss
    @SwiftUI.State private var sizeA3 = true

    var body: some View {
        ZStack {
            CD.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                FlowTopBar(title: "照護海報") { dismiss() }
                CDScroll {
                    VStack(alignment: .leading, spacing: 14) {
                        PageHeader(kicker: "貼在冰箱上，全家都看得懂", title: "圖解照護海報")

                        // 海報預覽（鎖定模糊）
                        BlurLock(cta: "加購 $49 解鎖列印") {
                            posterPreview
                        }

                        // 尺寸切換
                        HStack(spacing: 8) {
                            sizeChip("A3", selected: sizeA3) { sizeA3 = true }
                            sizeChip("A4", selected: !sizeA3) { sizeA3 = false }
                            Spacer()
                            TagView(text: "一次買斷", color: CD.accent)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(["圖解風格，長輩一看就懂",
                                     "可到超商列印 A3/A4",
                                     "內容隨整理結果自動更新"], id: \.self) { line in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(CD.success)
                                    Text(line).font(.cdBody(13, weight: .medium)).foregroundStyle(CD.text)
                                }
                            }
                        }
                        .card(padding: 16)

                        PillButton(title: "加購海報 $49", icon: "printer", style: .lemon) {
                            Haptics.shared.soft()   // POC：付費入口示意
                        }
                        DisclaimerFooter()
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var posterPreview: some View {
        ZStack {
            MoodBlobBackground()
            VStack(spacing: 10) {
                Text("\(state.session.familyName)的照護重點")
                    .font(.cdDisplay(19)).foregroundStyle(CD.cream)
                Text("用藥 4 種 · 回診 6/16 · 注意事項 5 條")
                    .font(.cdBody(12, weight: .bold)).foregroundStyle(CD.cream.opacity(0.85))
            }
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: CD.rCardLarge, style: .continuous))
    }

    private func sizeChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.shared.selectionTick()
            withAnimation(CD.ease, action)
        } label: {
            Text(label)
                .font(.cdBody(13, weight: .heavy))
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(selected ? CD.accent : CD.surface2)
                .foregroundStyle(selected ? CD.plumDeep : CD.text)
                .clipShape(Capsule())
        }
        .buttonStyle(PressScaleStyle())
    }
}
