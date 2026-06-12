import SwiftUI

/// 畫面 11：文件紀錄（時間軸 + 版本標記）
struct DocumentsView: View {
    @Bindable var state: AppState

    private var phases: [String] {
        var seen: Set<String> = []
        return state.session.documents.compactMap {
            seen.insert($0.phase).inserted ? $0.phase : nil
        }
    }

    var body: some View {
        CDScroll {
            VStack(alignment: .leading, spacing: 14) {
                PageHeader(kicker: "時間軸", title: "文件紀錄")

                ForEach(phases, id: \.self) { phase in
                    HStack(spacing: 8) {
                        Circle().fill(CD.accent).frame(width: 8, height: 8)
                        Text(phase).font(.cdTitle(14)).foregroundStyle(CD.text)
                        Rectangle().fill(CD.cardBorder).frame(height: 1)
                    }
                    ForEach(state.session.documents.filter { $0.phase == phase }) { doc in
                        ListRow(
                            iconBackground: CD.info.opacity(0.14),
                            title: doc.title,
                            subtitle: "\(doc.dateText) · \(doc.pages) 頁 · \(doc.kinds.joined(separator: "、"))"
                        ) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(CD.info)
                        } trailing: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(CD.text3)
                        }
                    }
                }

                // 隱私提示
                HStack(spacing: 10) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CD.success)
                    Text("所有文件與整理結果只存在這台手機，不上傳雲端")
                        .font(.cdBody(12, weight: .medium)).foregroundStyle(CD.text2)
                }
                .card(padding: 14)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
    }
}
