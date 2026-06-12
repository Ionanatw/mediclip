import SwiftUI

/// 畫面 3-6：上傳 → AI 處理中 → AI 追問 → 結果總覽（modal 流程）
struct UploadFlowView: View {
    @Bindable var state: AppState

    var body: some View {
        ZStack {
            CD.bg.ignoresSafeArea()
            switch state.uploadStep {
            case .upload: UploadView(state: state)
            case .processing: ProcessingView(state: state)
            case .followUp: FollowUpView(state: state)
            case .results: ResultsView(state: state)
            case .none: EmptyView()
            }
        }
        .animation(CD.ease, value: state.uploadStep)
    }
}

// MARK: - 流程頂欄

struct FlowTopBar: View {
    let title: String
    var onClose: () -> Void

    var body: some View {
        HStack {
            Text(title).font(.cdTitle(16)).foregroundStyle(CD.text)
            Spacer()
            Button {
                Haptics.shared.light()
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(CD.text2)
                    .frame(width: 34, height: 34)
                    .background(CD.surface2, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
    }
}

// MARK: - 畫面 3：上傳

struct UploadView: View {
    @Bindable var state: AppState
    @Environment(\.snapshotMode) private var snapshotMode

    var body: some View {
        VStack(spacing: 0) {
            FlowTopBar(title: "") { state.uploadStep = .none }
            CDScroll {
                VStack(alignment: .leading, spacing: 14) {
                    PageHeader(kicker: "新的照護時段", title: "上傳醫療文件")

                    // 拍照虛線區
                    Button {
                        Haptics.shared.light()
                        withAnimation(CD.ease) { state.pickedCount = min(3, state.pickedCount + 1) }
                    } label: {
                        VStack(spacing: 8) {
                            CameraArtView().frame(width: 64, height: 56)
                            Text("拍照或從相簿選擇")
                                .font(.cdTitle(15)).foregroundStyle(CD.text)
                            Text("衛教單、處方箋、回診單、檢驗單\n同一時段不限張數、不另扣次")
                                .font(.cdBody(11.5, weight: .medium))
                                .foregroundStyle(CD.text2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(CD.accent.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: CD.rCard, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: CD.rCard, style: .continuous)
                                .stroke(CD.accent, style: StrokeStyle(lineWidth: 1.6, dash: [6, 5]))
                        )
                    }
                    .buttonStyle(PressScaleStyle())

                    // 其他輸入源
                    HStack(spacing: 8) {
                        sourceChip("doc.text", "PDF", enabled: true)
                        sourceChip("globe", "網頁", enabled: true)
                        sourceChip("mic", "語音 soon", enabled: false)
                    }

                    if state.pickedCount > 0 {
                        SectionHeader(title: "已選擇 \(state.pickedCount) 張", trailing: "清空") {
                            withAnimation(CD.ease) { state.pickedCount = 0 }
                        }
                        HStack(spacing: 8) {
                            ForEach(0..<state.pickedCount, id: \.self) { i in
                                ZStack {
                                    RoundedRectangle(cornerRadius: CD.rRow, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [CD.info.opacity(0.2), CD.accent.opacity(0.2)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                    Text(["衛教單 P.1", "衛教單 P.2", "處方箋"][i])
                                        .font(.cdBody(10, weight: .heavy))
                                        .foregroundStyle(CD.text2)
                                }
                                .frame(height: 56)
                            }
                        }
                        .transition(.opacity)
                    }

                    // 補充說明
                    VStack(alignment: .leading, spacing: 6) {
                        Text("補充說明（選填）")
                            .font(.cdBody(11.5, weight: .bold)).foregroundStyle(CD.text3)
                        if snapshotMode {
                            Text("護理師說傷口要保持乾燥，洗澡用…")
                                .font(.cdBody(14)).foregroundStyle(CD.text2)
                        } else {
                            TextField("護理師口頭交代的事…", text: $state.noteText, axis: .vertical)
                                .font(.cdBody(14))
                                .foregroundStyle(CD.text)
                                .lineLimit(2...4)
                                .textFieldStyle(.plain)
                        }
                    }
                    .card()

                    Spacer(minLength: 8)

                    PillButton(title: "開始 AI 整理", icon: "sparkles", style: .lemon) {
                        guard state.pickedCount > 0 else {
                            Haptics.shared.warning()
                            return
                        }
                        state.uploadStep = .processing
                    }
                    .opacity(state.pickedCount > 0 ? 1 : 0.5)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
    }

    private func sourceChip(_ icon: String, _ label: String, enabled: Bool) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon).font(.system(size: 13, weight: .semibold))
            Text(label).font(.cdBody(12, weight: .heavy))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(CD.surface)
        .foregroundStyle(CD.text)
        .clipShape(RoundedRectangle(cornerRadius: CD.rRow, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CD.rRow, style: .continuous)
                .stroke(CD.cardBorder, lineWidth: 1)
        )
        .opacity(enabled ? 1 : 0.45)
    }
}

// MARK: - 畫面 4：AI 處理中

struct ProcessingView: View {
    @Bindable var state: AppState
    @SwiftUI.State private var step = 0
    @SwiftUI.State private var pulse = false

    private let steps = ["辨識文件內容", "結構化整理", "比對藥品資料庫", "產出照護懶人包"]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .fill(CD.accent.opacity(0.14))
                    .frame(width: 150, height: 150)
                    .scaleEffect(pulse ? 1.12 : 0.94)
                Circle()
                    .fill(CD.accent.opacity(0.2))
                    .frame(width: 110, height: 110)
                    .scaleEffect(pulse ? 1.06 : 0.96)
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(CD.accent)
            }
            .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: pulse)

            Text("AI 整理中")
                .font(.cdDisplay(22)).foregroundStyle(CD.text)
                .padding(.top, 26)

            VStack(alignment: .leading, spacing: 13) {
                ForEach(Array(steps.enumerated()), id: \.offset) { i, label in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(i <= step ? CD.success.opacity(0.16) : CD.surface2)
                                .frame(width: 26, height: 26)
                            if i < step {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundStyle(CD.success)
                            } else if i == step {
                                ProgressView().controlSize(.small).tint(CD.accent)
                            }
                        }
                        Text(label)
                            .font(.cdBody(14, weight: i == step ? .heavy : .medium))
                            .foregroundStyle(i <= step ? CD.text : CD.text3)
                    }
                }
            }
            .padding(.top, 26)

            Spacer()
            Text("照片只在這台手機與 AI 處理過程中存在，處理完即刪除")
                .font(.cdBody(11, weight: .medium)).foregroundStyle(CD.text3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 36)
        }
        .onAppear {
            pulse = true
            advance()
        }
    }

    private func advance() {
        guard step < steps.count else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            Haptics.shared.selectionTick()
            if step >= steps.count - 1 {
                state.finishProcessing()
            } else {
                withAnimation(CD.ease) { step += 1 }
                advance()
            }
        }
    }
}

// MARK: - 畫面 5：AI 追問

struct FollowUpView: View {
    @Bindable var state: AppState

    private var allAnswered: Bool {
        state.followUps.allSatisfy { $0.selected != nil }
    }

    var body: some View {
        VStack(spacing: 0) {
            FlowTopBar(title: "AI 追問") { state.uploadStep = .none }
            CDScroll {
                VStack(alignment: .leading, spacing: 16) {
                    PageHeader(kicker: "差一步就好", title: "幫我確認 2 件事")

                    ForEach($state.followUps) { $q in
                        VStack(alignment: .leading, spacing: 11) {
                            Text(q.question)
                                .font(.cdBody(14, weight: .bold))
                                .foregroundStyle(CD.text)
                                .lineSpacing(3)
                            ForEach(q.options, id: \.self) { option in
                                Button {
                                    Haptics.shared.selectionTick()
                                    withAnimation(CD.ease) { q.selected = option }
                                } label: {
                                    HStack {
                                        Text(option).font(.cdBody(13.5, weight: .bold))
                                        Spacer()
                                        if q.selected == option {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(CD.plumDeep)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(q.selected == option ? CD.accent : CD.surface2)
                                    .foregroundStyle(q.selected == option ? CD.plumDeep : CD.text)
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(PressScaleStyle())
                            }
                        }
                        .card(padding: 16)
                    }

                    PillButton(title: "完成整理", icon: "checkmark", style: .lemon) {
                        guard allAnswered else {
                            Haptics.shared.warning()
                            return
                        }
                        state.uploadStep = .results
                    }
                    .opacity(allAnswered ? 1 : 0.5)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
    }
}
