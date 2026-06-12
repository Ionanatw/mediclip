import SwiftUI

/// 畫面 1：歡迎頁
struct WelcomeView: View {
    @Bindable var state: AppState
    @SwiftUI.State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            SakuraTreeView(stage: .bloom)
                .frame(width: 240, height: 220)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)

            VStack(spacing: 10) {
                Text("Carrius")
                    .font(.cdDisplay(38)).tracking(-1)
                    .foregroundStyle(CD.text)
                Text("拍照上傳醫療單\nAI 幫你秒懂、秒整理、秒提醒")
                    .font(.cdBody(16, weight: .medium))
                    .foregroundStyle(CD.text2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
            .padding(.top, 18)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)

            Spacer()

            VStack(spacing: 14) {
                PillButton(title: "開始使用", style: .lemon) {
                    withAnimation(CD.ease) { state.hasOnboarded = true }
                }
                Text("醫療資料只存在你的手機，伺服器不碰、不存、不看")
                    .font(.cdBody(11.5, weight: .medium))
                    .foregroundStyle(CD.text3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 44)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(CD.easeSlow.delay(0.1)) { appeared = true }
        }
    }
}
