import SwiftUI

/// 478 呼吸練習 — 純觀看＋震動節奏（B 風格光暈背景）。
/// 吸氣 4 秒（圓放大＋震動漸強）→ 屏息 7 秒（心跳輕點）→ 吐氣 8 秒（圓縮小＋震動漸弱）
struct BreathingView: View {
    var onFinish: (Bool) -> Void

    private enum Phase: String {
        case ready = "準備"
        case inhale = "吸氣"
        case hold = "屏息"
        case exhale = "吐氣"
        case done = "完成"

        var seconds: Double {
            switch self {
            case .inhale: 4
            case .hold: 7
            case .exhale: 8
            default: 0
            }
        }
    }

    @SwiftUI.State private var phase: Phase = .ready
    @SwiftUI.State private var round = 0
    @SwiftUI.State private var orbScale: CGFloat = 0.55
    @SwiftUI.State private var countdown = 0
    @SwiftUI.State private var timer: Timer?

    private let totalRounds = 3

    var body: some View {
        ZStack {
            BreathBackground()

            VStack {
                HStack {
                    Text("478 呼吸法 · 第 \(min(round + 1, totalRounds)) / \(totalRounds) 輪")
                        .font(.cdBody(13, weight: .heavy))
                        .foregroundStyle(CD.cream.opacity(0.85))
                    Spacer()
                    Button {
                        Haptics.shared.light()
                        stop(completed: false)
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

                // 呼吸圓
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.14))
                        .frame(width: 250, height: 250)
                        .scaleEffect(orbScale * 1.18)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: 0xFFE9F2).opacity(0.95),
                                         Color(hex: 0xFFC9DF).opacity(0.55)],
                                center: .center, startRadius: 8, endRadius: 120)
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(orbScale)
                    VStack(spacing: 6) {
                        Text(phase.rawValue)
                            .font(.cdDisplay(26)).foregroundStyle(CD.plumDeep)
                        if phase != .ready && phase != .done {
                            Text("\(countdown)")
                                .font(.cdDisplay(20)).foregroundStyle(CD.plumDeep.opacity(0.6))
                                .contentTransition(.numericText())
                        }
                    }
                }

                Spacer()

                VStack(spacing: 14) {
                    if phase == .ready {
                        Text("找個舒服的姿勢，手機放手心\n震動會帶著你呼吸，可以閉上眼睛")
                            .font(.cdBody(14, weight: .medium))
                            .foregroundStyle(CD.cream.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        PillButton(title: "開始", style: .lemon) { startRound() }
                            .padding(.horizontal, 60)
                    } else if phase == .done {
                        Text("做得很好，把這份平靜帶回去")
                            .font(.cdBody(14, weight: .medium))
                            .foregroundStyle(CD.cream.opacity(0.9))
                        PillButton(title: "收下 +2 陽光", style: .lemon) { stop(completed: true) }
                            .padding(.horizontal, 60)
                    } else {
                        Text("跟著震動的節奏就好")
                            .font(.cdBody(13, weight: .medium))
                            .foregroundStyle(CD.cream.opacity(0.7))
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onDisappear {
            timer?.invalidate()
            Haptics.shared.stopBreathing()
        }
    }

    // MARK: - 節奏控制

    private func startRound() {
        Haptics.shared.light()
        runPhase(.inhale)
    }

    private func runPhase(_ p: Phase) {
        phase = p
        countdown = Int(p.seconds)

        switch p {
        case .inhale:
            Haptics.shared.breatheIn(duration: p.seconds)
            withAnimation(.easeInOut(duration: p.seconds)) { orbScale = 1.0 }
        case .hold:
            Haptics.shared.breatheHold(duration: p.seconds)
        case .exhale:
            Haptics.shared.breatheOut(duration: p.seconds)
            withAnimation(.easeInOut(duration: p.seconds)) { orbScale = 0.55 }
        default: break
        }

        // 倒數
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            DispatchQueue.main.async {
                if countdown > 1 {
                    withAnimation { countdown -= 1 }
                } else {
                    t.invalidate()
                    nextPhase()
                }
            }
        }
    }

    private func nextPhase() {
        switch phase {
        case .inhale: runPhase(.hold)
        case .hold: runPhase(.exhale)
        case .exhale:
            round += 1
            if round >= totalRounds {
                phase = .done
                Haptics.shared.success()
            } else {
                runPhase(.inhale)
            }
        default: break
        }
    }

    private func stop(completed: Bool) {
        timer?.invalidate()
        Haptics.shared.stopBreathing()
        onFinish(completed)
    }
}
