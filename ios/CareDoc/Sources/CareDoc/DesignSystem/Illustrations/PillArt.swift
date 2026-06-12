import SwiftUI

/// 藥品插畫（A 風格描邊＋錯位高光），但形狀、顏色、刻痕照真實藥品外觀。
struct PillArtView: View {
    let med: Medication
    var large: Bool = false

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let cx = w / 2, cy = h / 2
            let scale = min(w, h) / 120

            // 陰影
            let shadow = Path(ellipseIn: CGRect(x: cx - 42 * scale, y: cy + 30 * scale,
                                                width: 84 * scale, height: 10 * scale))
            ctx.fill(shadow, with: .color(.black.opacity(0.15)))

            var body = ctx
            body.translateBy(x: cx, y: cy)
            body.rotate(by: .degrees(-16))
            body.scaleBy(x: scale, y: scale)

            switch med.form {
            case .capsule: drawCapsule(in: &body)
            case .tablet: drawTablet(in: &body)
            case .oblong: drawOblong(in: &body)
            }
        }
        .accessibilityLabel("\(med.name)外觀：\(med.appearanceText)")
    }

    private func drawCapsule(in ctx: inout GraphicsContext) {
        let rect = CGRect(x: -50, y: -16, width: 100, height: 32)
        let capsule = Path(roundedRect: rect, cornerRadius: 16)
        // 左半（主色）右半（次色）
        ctx.fill(capsule, with: .color(Color(hex: med.colorHexA)))
        var right = Path()
        right.addPath(Path(roundedRect: CGRect(x: 1, y: -14.5, width: 47.5, height: 29),
                           cornerRadius: 14.5))
        ctx.fill(right, with: .color(Color(hex: med.colorHexB)))
        // 中線 + 輪廓
        var mid = Path()
        mid.move(to: CGPoint(x: 0, y: -16))
        mid.addLine(to: CGPoint(x: 0, y: 16))
        ctx.stroke(mid, with: .color(CD.plum), lineWidth: 3)
        ctx.stroke(capsule, with: .color(CD.plum),
                   style: StrokeStyle(lineWidth: 3.4, lineJoin: .round))
        // 錯位高光
        let gloss = Path(ellipseIn: CGRect(x: -38, y: -11, width: 20, height: 8))
        ctx.fill(gloss, with: .color(.white.opacity(0.85)))
        // 刻痕
        ctx.draw(Text(med.imprint).font(.system(size: 8, weight: .heavy, design: .rounded))
            .foregroundColor(CD.plum.opacity(0.55)),
                 at: CGPoint(x: -24, y: 0))
    }

    private func drawTablet(in ctx: inout GraphicsContext) {
        let circle = Path(ellipseIn: CGRect(x: -30, y: -30, width: 60, height: 60))
        ctx.fill(circle, with: .color(Color(hex: med.colorHexA)))
        ctx.stroke(circle, with: .color(CD.plum), lineWidth: 3.4)
        // 切線刻痕
        var score = Path()
        score.move(to: CGPoint(x: -18, y: 0))
        score.addLine(to: CGPoint(x: 18, y: 0))
        ctx.stroke(score, with: .color(CD.plum.opacity(0.5)), lineWidth: 2.4)
        let gloss = Path(ellipseIn: CGRect(x: -18, y: -22, width: 16, height: 7))
        ctx.fill(gloss, with: .color(.white.opacity(0.8)))
        ctx.draw(Text(med.imprint).font(.system(size: 8, weight: .heavy, design: .rounded))
            .foregroundColor(CD.plum.opacity(0.55)),
                 at: CGPoint(x: 0, y: 12))
    }

    private func drawOblong(in ctx: inout GraphicsContext) {
        let rect = CGRect(x: -46, y: -19, width: 92, height: 38)
        let oblong = Path(roundedRect: rect, cornerRadius: 19)
        ctx.fill(oblong, with: .color(Color(hex: med.colorHexA)))
        ctx.stroke(oblong, with: .color(CD.plum), lineWidth: 3.4)
        let gloss = Path(ellipseIn: CGRect(x: -34, y: -13, width: 22, height: 8))
        ctx.fill(gloss, with: .color(.white.opacity(0.8)))
        ctx.draw(Text(med.imprint).font(.system(size: 8, weight: .heavy, design: .rounded))
            .foregroundColor(CD.plum.opacity(0.55)),
                 at: CGPoint(x: 0, y: 0))
    }
}

/// 上傳空狀態相機插畫（A 風格）
struct CameraArtView: View {
    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width, size.height) / 50
            var c = ctx
            c.translateBy(x: size.width / 2, y: size.height / 2)
            c.scaleBy(x: s, y: s)

            let bodyRect = Path(roundedRect: CGRect(x: -17, y: -9, width: 34, height: 24),
                                cornerRadius: 7)
            c.fill(bodyRect.applying(.init(translationX: 1.4, y: -1.2)),
                   with: .color(CD.accentSoft))
            c.stroke(bodyRect, with: .color(CD.accent),
                     style: StrokeStyle(lineWidth: 2.4, lineJoin: .round))
            var top = Path()
            top.move(to: CGPoint(x: -8, y: -9))
            top.addLine(to: CGPoint(x: -5, y: -14))
            top.addLine(to: CGPoint(x: 5, y: -14))
            top.addLine(to: CGPoint(x: 8, y: -9))
            c.stroke(top, with: .color(CD.accent),
                     style: StrokeStyle(lineWidth: 2.4, lineJoin: .round))
            let lens = Path(ellipseIn: CGRect(x: -7, y: -4, width: 14, height: 14))
            c.stroke(lens, with: .color(CD.accent), lineWidth: 2.4)
            let dot = Path(ellipseIn: CGRect(x: -2, y: 1, width: 4, height: 4))
            c.fill(dot, with: .color(CD.lemon))
        }
    }
}
