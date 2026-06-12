import SwiftUI
#if os(iOS)
import CoreHaptics
import UIKit
#endif

/// 全 App 震動引擎。
/// 設計原則（spec §震動三類）：
/// 1. 節奏引導型 — 呼吸練習的吸/屏/吐連續曲線
/// 2. 拉回注意力型 — 久坐提醒、用藥時間、AI 完成
/// 3. 回饋確認型 — 勾選、升級、tab 切換、鎖定功能
/// macOS（swift run 驗證模式）下全部 no-op。
final class Haptics {
    static let shared = Haptics()

    #if os(iOS)
    private var engine: CHHapticEngine?
    #endif

    private init() {
        #if os(iOS)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        engine?.resetHandler = { [weak self] in try? self?.engine?.start() }
        try? engine?.start()
        #endif
    }

    // MARK: 回饋確認型

    func light() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    func soft() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }

    func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    func warning() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }

    func selectionTick() {
        #if os(iOS)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    /// 樹升級：漸強三連震
    func levelUp() {
        #if os(iOS)
        guard let engine else { success(); return }
        var events: [CHHapticEvent] = []
        for i in 0..<3 {
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4 + Float(i) * 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: Double(i) * 0.18
            ))
        }
        play(events, on: engine)
        #endif
    }

    /// 拉回注意力：兩短一長（久坐提醒、AI 完成）
    func attention() {
        #if os(iOS)
        guard let engine else { warning(); return }
        var events: [CHHapticEvent] = []
        for t in [0.0, 0.22] {
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)],
                relativeTime: t
            ))
        }
        events.append(CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0.5,
            duration: 0.45
        ))
        play(events, on: engine)
        #endif
    }

    // MARK: 節奏引導型 — 呼吸

    /// 吸氣：由弱漸強的連續震動
    func breatheIn(duration: Double) {
        continuousRamp(duration: duration, from: 0.15, to: 0.8, sharpness: 0.25)
    }

    /// 屏息：每秒一個極輕的心跳點
    func breatheHold(duration: Double) {
        #if os(iOS)
        guard let engine else { return }
        var events: [CHHapticEvent] = []
        var t = 0.0
        while t < duration - 0.05 {
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: t
            ))
            t += 1.0
        }
        play(events, on: engine)
        #endif
    }

    /// 吐氣：由強漸弱的連續震動
    func breatheOut(duration: Double) {
        continuousRamp(duration: duration, from: 0.8, to: 0.05, sharpness: 0.15)
    }

    func stopBreathing() {
        #if os(iOS)
        try? engine?.stop()
        try? engine?.start()
        #endif
    }

    private func continuousRamp(duration: Double, from: Float, to: Float, sharpness: Float) {
        #if os(iOS)
        guard let engine else { return }
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: from),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )
        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0, value: from),
                .init(relativeTime: duration, value: to)
            ],
            relativeTime: 0
        )
        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [curve])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {}
        #endif
    }

    #if os(iOS)
    private func play(_ events: [CHHapticEvent], on engine: CHHapticEngine) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {}
    }
    #endif
}
