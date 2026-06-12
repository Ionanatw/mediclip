import SwiftUI

/// 畫面 13：快樂花園
struct GardenView: View {
    @Bindable var state: AppState
    @SwiftUI.State private var showBreathing = false
    @SwiftUI.State private var showGratitude = false
    @SwiftUI.State private var showMoodCard = false

    var body: some View {
        CDScroll {
            VStack(alignment: .leading, spacing: 14) {
                PageHeader(kicker: "快樂花園 · 第 1 棵", title: "你的櫻花樹")

                // 樹
                SakuraTreeView(stage: state.stage)
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)

                // 陽光進度
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(state.stage.name)期 · 陽光 \(state.sunTotal)")
                            .font(.cdTitle(14)).foregroundStyle(CD.text)
                        Spacer()
                        Text("距離\(nextStageName) \(max(0, state.nextThreshold - state.sunTotal))")
                            .font(.cdBody(11.5, weight: .bold)).foregroundStyle(CD.text2)
                    }
                    SunProgressBar(value: progress)
                    Text("今日陽光 \(state.sunToday) / 15 · 連續 \(state.streak) 天")
                        .font(.cdBody(11.5, weight: .medium)).foregroundStyle(CD.text2)
                }
                .card(padding: 14)

                SectionHeader(title: "今天的快樂任務")
                ForEach(state.happyTasks) { task in
                    taskRow(task)
                }

                // 心情小卡（C 風格）
                Button {
                    Haptics.shared.light()
                    showMoodCard = true
                } label: {
                    ZStack {
                        MoodBlobBackground()
                        VStack(spacing: 5) {
                            Text("今日心情小卡")
                                .font(.cdBody(11, weight: .heavy))
                                .foregroundStyle(CD.cream.opacity(0.8))
                            Text(MockData.moodCards[0].text)
                                .font(.cdTitle(14)).foregroundStyle(CD.cream)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 26)
                        }
                    }
                    .frame(height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: CD.rCard, style: .continuous))
                }
                .buttonStyle(PressScaleStyle())

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .sheet(isPresented: $showBreathing) {
            BreathingView { completed in
                showBreathing = false
                if completed, let task = state.happyTasks.first(where: { $0.kind == .breathing && !$0.done }) {
                    state.completeTask(task)
                }
            }
        }
        .sheet(isPresented: $showGratitude) { GratitudeView(state: state) }
        .sheet(isPresented: $showMoodCard) { MoodCardSheet() }
    }

    private var nextStageName: String {
        TreeStage(rawValue: state.stage.rawValue + 1)?.name ?? "大樹"
    }
    private var progress: Double {
        let prev = Double(state.stage.threshold)
        let next = Double(state.nextThreshold)
        guard next > prev else { return 1 }
        return (Double(state.sunTotal) - prev) / (next - prev)
    }

    private func taskRow(_ task: HappyTask) -> some View {
        Button {
            switch task.kind {
            case .breathing:
                Haptics.shared.light()
                showBreathing = true
            case .gratitude:
                Haptics.shared.light()
                showGratitude = true
            default:
                withAnimation(CD.ease) { state.completeTask(task) }
            }
        } label: {
            ListRow(
                iconBackground: taskColor(task.kind).opacity(0.15),
                title: task.title,
                subtitle: task.done ? "\(task.subtitle) · 已完成" : task.subtitle
            ) {
                Image(systemName: taskIcon(task.kind))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(taskColor(task.kind))
            } trailing: {
                TagView(text: "+\(task.sun) 陽光",
                        color: task.done ? CD.success : CD.text2)
            }
        }
        .buttonStyle(PressScaleStyle())
        .opacity(task.done ? 0.66 : 1)
    }

    private func taskIcon(_ kind: HappyTaskKind) -> String {
        switch kind {
        case .breathing: "wind"
        case .gratitude: "heart.text.square"
        case .exercise: "figure.flexibility"
        case .challenge: "flame"
        case .share: "paperplane"
        }
    }
    private func taskColor(_ kind: HappyTaskKind) -> Color {
        switch kind {
        case .breathing: CD.info
        case .gratitude: Color(hex: 0xC8D432)
        case .exercise: CD.success
        case .challenge: CD.danger
        case .share: CD.accent
        }
    }
}

// MARK: - 感恩日記

struct GratitudeView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.snapshotMode) private var snapshotMode

    var body: some View {
        ZStack {
            CD.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                FlowTopBar(title: "感恩日記") { dismiss() }
                VStack(alignment: .leading, spacing: 14) {
                    PageHeader(kicker: MockData.gratitudePrompts[0], title: "寫下一件感恩的事")
                    Group {
                        if snapshotMode {
                            Text("今天…")
                                .font(.cdBody(15)).foregroundStyle(CD.text3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            TextField("今天…", text: $state.gratitudeText, axis: .vertical)
                                .font(.cdBody(15))
                                .foregroundStyle(CD.text)
                                .lineLimit(4...8)
                                .textFieldStyle(.plain)
                        }
                    }
                    .card(padding: 16)
                    PillButton(title: "存下來", icon: "heart", style: .lemon) {
                        guard !state.gratitudeText.isEmpty else {
                            Haptics.shared.warning()
                            return
                        }
                        if let task = state.happyTasks.first(where: { $0.kind == .gratitude && !$0.done }) {
                            state.completeTask(task)
                        }
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
            }
        }
    }
}

// MARK: - 心情小卡（C 風格全幅）

struct MoodCardSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            MoodBlobBackground().ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button {
                        Haptics.shared.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(CD.cream)
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.15), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(18)
                Spacer()
                VStack(spacing: 14) {
                    Text(MockData.moodCards[0].text)
                        .font(.cdDisplay(22))
                        .foregroundStyle(CD.cream)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 36)
                    Text("— \(MockData.moodCards[0].author)")
                        .font(.cdBody(13, weight: .bold))
                        .foregroundStyle(CD.cream.opacity(0.7))
                }
                Spacer()
                PillButton(title: "分享給家人", icon: "paperplane", style: .lemon) {}
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
    }
}
