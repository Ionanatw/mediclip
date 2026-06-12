import SwiftUI

/// 畫面 9：每日待辦
struct ChecklistView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss

    private var doneCount: Int { state.session.checklist.filter(\.done).count }
    private var categories: [String] {
        var seen: Set<String> = []
        return state.session.checklist.compactMap {
            seen.insert($0.category).inserted ? $0.category : nil
        }
    }

    var body: some View {
        ZStack {
            CD.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                FlowTopBar(title: "每日照護待辦") { dismiss() }
                CDScroll {
                    VStack(alignment: .leading, spacing: 14) {
                        PageHeader(kicker: "6 月 13 日", title: "今天的照護清單")

                        // 進度
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(doneCount)")
                                    .font(.cdDisplay(26)).foregroundStyle(CD.accent)
                                Text("/ \(state.session.checklist.count) 完成")
                                    .font(.cdBody(13, weight: .bold)).foregroundStyle(CD.text2)
                                Spacer()
                                if doneCount == state.session.checklist.count {
                                    TagView(text: "全部完成，了不起", color: CD.success)
                                }
                            }
                            SunProgressBar(value: Double(doneCount) / Double(max(1, state.session.checklist.count)))
                        }
                        .card(padding: 16)

                        ForEach(categories, id: \.self) { category in
                            SectionHeader(title: category)
                            ForEach(state.session.checklist.filter { $0.category == category }) { item in
                                checklistRow(item)
                            }
                        }
                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func checklistRow(_ item: ChecklistItem) -> some View {
        Button {
            withAnimation(CD.ease) { state.toggleChecklist(item) }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(item.done ? CD.success : CD.surface2)
                        .frame(width: 26, height: 26)
                    if item.done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(CD.plumDeep)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.cdTitle(13.5))
                        .foregroundStyle(item.done ? CD.text3 : CD.text)
                        .strikethrough(item.done, color: CD.text3)
                    if let detail = item.detail {
                        Text(detail).font(.cdBody(11.5, weight: .medium)).foregroundStyle(CD.text3)
                    }
                }
                Spacer()
            }
            .padding(12)
            .background(CD.surface)
            .clipShape(RoundedRectangle(cornerRadius: CD.rRow, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CD.rRow, style: .continuous)
                    .stroke(CD.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleStyle())
    }
}
