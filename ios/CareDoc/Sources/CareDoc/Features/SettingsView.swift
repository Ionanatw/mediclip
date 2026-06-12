import SwiftUI

/// 畫面 12：設定
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @SwiftUI.State private var medReminder = true
    @SwiftUI.State private var sitReminder = true
    @SwiftUI.State private var hapticsOn = true

    var body: some View {
        ZStack {
            CD.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                FlowTopBar(title: "設定") { dismiss() }
                CDScroll {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "提醒（App 內）")
                        VStack(spacing: 0) {
                            toggleRow("pills", "用藥時間輕震提醒", $medReminder)
                            Divider().overlay(CD.cardBorder)
                            toggleRow("figure.walk", "久坐提醒（等候時）", $sitReminder)
                            Divider().overlay(CD.cardBorder)
                            toggleRow("iphone.radiowaves.left.and.right", "震動回饋", $hapticsOn)
                        }
                        .card(padding: 6)

                        SectionHeader(title: "帳號")
                        VStack(spacing: 0) {
                            navRow("person", "ionachen@gamania.com")
                            Divider().overlay(CD.cardBorder)
                            navRow("creditcard", "方案：免費（剩 1 次照護時段）")
                        }
                        .card(padding: 6)

                        SectionHeader(title: "關於")
                        VStack(spacing: 0) {
                            navRow("lock.shield", "隱私政策")
                            Divider().overlay(CD.cardBorder)
                            navRow("doc.plaintext", "使用者同意書")
                            Divider().overlay(CD.cardBorder)
                            navRow("info.circle", "Carrius v0.1 POC")
                        }
                        .card(padding: 6)

                        Text("醫療資料只存在你的手機。伺服器只知道你的 email 和付費狀態。")
                            .font(.cdBody(11.5, weight: .medium)).foregroundStyle(CD.text3)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func toggleRow(_ icon: String, _ label: String, _ binding: Binding<Bool>) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(CD.accent)
                .frame(width: 26)
            Text(label).font(.cdBody(13.5, weight: .bold)).foregroundStyle(CD.text)
            Spacer()
            Toggle("", isOn: binding).labelsHidden().tint(CD.accent)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }

    private func navRow(_ icon: String, _ label: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(CD.text2)
                .frame(width: 26)
            Text(label).font(.cdBody(13.5, weight: .bold)).foregroundStyle(CD.text)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold)).foregroundStyle(CD.text3)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
    }
}
