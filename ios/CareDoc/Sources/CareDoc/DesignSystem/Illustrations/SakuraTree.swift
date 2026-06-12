import SwiftUI

/// 櫻花樹（A 描邊錯位塗鴉風）— 5 個成長階段。
/// 規則：plum 粗描邊、粉色填色往右上錯位、檸檬花蕊、星芒點綴。
struct SakuraTreeView: View {
    let stage: TreeStage
    var animate: Bool = true

    @SwiftUI.State private var sway = false

    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width, size.height)
            let unit = s / 300
            var t = CGAffineTransform(translationX: (size.width - s) / 2,
                                      y: (size.height - s) / 2)
            t = t.scaledBy(x: unit, y: unit)
            draw(in: &ctx, transform: t)
        }
        .rotationEffect(.degrees(sway ? 0.8 : -0.8), anchor: .bottom)
        .animation(animate ? .easeInOut(duration: 3.2).repeatForever(autoreverses: true) : nil,
                   value: sway)
        .onAppear { if animate { sway = true } }
        .accessibilityLabel("你的櫻花樹，目前是\(stage.name)階段")
    }

    private func draw(in ctx: inout GraphicsContext, transform t: CGAffineTransform) {
        let plum = GraphicsContext.Shading.color(CD.plum)
        let lineWidth: CGFloat = 9

        func strokePath(_ p: Path, width: CGFloat = lineWidth) {
            ctx.stroke(p.applying(t), with: plum,
                       style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        }
        func fillOffset(_ p: Path, color: Color, dx: CGFloat = 9, dy: CGFloat = -8) {
            let offset = t.translatedBy(x: dx, y: dy)
            ctx.fill(p.applying(offset), with: .color(color))
        }

        // 地面（所有階段共用）
        var ground = Path()
        ground.move(to: CGPoint(x: 80, y: 252))
        ground.addQuadCurve(to: CGPoint(x: 220, y: 252), control: CGPoint(x: 150, y: 262))
        strokePath(ground, width: 4.5)

        // 星芒（茁壯以上才出現）
        if stage.rawValue >= TreeStage.growing.rawValue {
            sparkle(at: CGPoint(x: 52, y: 70), r: 11, in: &ctx, transform: t)
            sparkle(at: CGPoint(x: 252, y: 46), r: 8, in: &ctx, transform: t)
        }

        switch stage {
        case .seed:
            // 土堆 + 種子
            var mound = Path()
            mound.move(to: CGPoint(x: 110, y: 252))
            mound.addQuadCurve(to: CGPoint(x: 190, y: 252), control: CGPoint(x: 150, y: 222))
            fillOffset(mound, color: CD.accentSoft, dx: 5, dy: -4)
            strokePath(mound, width: 5)
            let seed = Path(ellipseIn: CGRect(x: 138, y: 196, width: 26, height: 32))
            fillOffset(seed, color: CD.pink, dx: 4, dy: -4)
            strokePath(seed, width: 5)

        case .sprout:
            var stem = Path()
            stem.move(to: CGPoint(x: 150, y: 250))
            stem.addLine(to: CGPoint(x: 150, y: 192))
            strokePath(stem, width: 7)
            leaf(from: CGPoint(x: 150, y: 210), dir: -1, len: 42, in: &ctx, transform: t)
            leaf(from: CGPoint(x: 150, y: 196), dir: 1, len: 50, in: &ctx, transform: t)

        case .sapling:
            var trunk = Path()
            trunk.move(to: CGPoint(x: 150, y: 250))
            trunk.addCurve(to: CGPoint(x: 147, y: 150),
                           control1: CGPoint(x: 151, y: 220),
                           control2: CGPoint(x: 145, y: 185))
            strokePath(trunk, width: 8)
            leaf(from: CGPoint(x: 148, y: 190), dir: -1, len: 46, in: &ctx, transform: t)
            leaf(from: CGPoint(x: 148, y: 168), dir: 1, len: 52, in: &ctx, transform: t)
            // 頂端一小簇粉
            let bud = cloudPath(cx: 148, cy: 132, rx: 34, ry: 26)
            fillOffset(bud, color: CD.pinkLight, dx: 6, dy: -6)
            strokePath(bud, width: 5)

        case .growing, .bloom:
            // 樹幹＋分枝
            var trunk = Path()
            trunk.move(to: CGPoint(x: 150, y: 250))
            trunk.addCurve(to: CGPoint(x: 144, y: 128),
                           control1: CGPoint(x: 152, y: 215),
                           control2: CGPoint(x: 142, y: 165))
            strokePath(trunk, width: 11)
            var b1 = Path()
            b1.move(to: CGPoint(x: 146, y: 188))
            b1.addCurve(to: CGPoint(x: 102, y: 162),
                        control1: CGPoint(x: 132, y: 176),
                        control2: CGPoint(x: 118, y: 166))
            strokePath(b1, width: 7)
            var b2 = Path()
            b2.move(to: CGPoint(x: 147, y: 170))
            b2.addCurve(to: CGPoint(x: 196, y: 146),
                        control1: CGPoint(x: 163, y: 156),
                        control2: CGPoint(x: 180, y: 148))
            strokePath(b2, width: 7)

            // 樹冠雲朵
            let canopy = cloudPath(cx: 150, cy: 96, rx: 86, ry: 56)
            fillOffset(canopy, color: CD.pink)
            strokePath(canopy, width: 5.5)
            let inner = cloudPath(cx: 158, cy: 88, rx: 44, ry: 28)
            fillOffset(inner, color: CD.pinkLight, dx: 6, dy: -6)

            // 花朵點
            for pt in [CGPoint(x: 116, y: 102), CGPoint(x: 184, y: 76), CGPoint(x: 150, y: 118)] {
                let dot = Path(ellipseIn: CGRect(x: pt.x - 3.5, y: pt.y - 3.5, width: 7, height: 7))
                ctx.fill(dot.applying(t), with: .color(CD.pinkHot))
            }

            if stage == .bloom {
                // 大樹：輪廓白花＋飄落花瓣
                for pt in [CGPoint(x: 104, y: 88), CGPoint(x: 170, y: 60), CGPoint(x: 196, y: 104)] {
                    blossom(at: pt, in: &ctx, transform: t)
                }
                for (pt, rot) in [(CGPoint(x: 232, y: 176), 0.4), (CGPoint(x: 70, y: 196), -0.5)] {
                    petal(at: pt, rotation: rot, in: &ctx, transform: t)
                }
            }
        }
    }

    // 雲朵樹冠：橢圓近似的波浪輪廓
    private func cloudPath(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat) -> Path {
        var p = Path()
        let bumps = 7
        var points: [CGPoint] = []
        for i in 0..<bumps {
            let a = Double(i) / Double(bumps) * 2 * .pi
            let wobble: CGFloat = i % 2 == 0 ? 1.0 : 0.82
            points.append(CGPoint(x: cx + cos(a) * rx * wobble,
                                  y: cy + sin(a) * ry * wobble))
        }
        p.move(to: points[0])
        for i in 0..<bumps {
            let next = points[(i + 1) % bumps]
            let cur = points[i]
            let mid = CGPoint(x: (cur.x + next.x) / 2, y: (cur.y + next.y) / 2)
            let dx = next.x - cur.x, dy = next.y - cur.y
            // 往外凸的控制點
            let ctrl = CGPoint(x: mid.x + dy * 0.22, y: mid.y - dx * 0.22)
            p.addQuadCurve(to: next, control: ctrl)
        }
        p.closeSubpath()
        return p
    }

    private func leaf(from: CGPoint, dir: CGFloat, len: CGFloat,
                      in ctx: inout GraphicsContext, transform t: CGAffineTransform) {
        var p = Path()
        let tip = CGPoint(x: from.x + dir * len, y: from.y - len * 0.62)
        p.move(to: from)
        p.addQuadCurve(to: tip, control: CGPoint(x: from.x + dir * len * 0.15, y: from.y - len * 0.72))
        p.addQuadCurve(to: from, control: CGPoint(x: from.x + dir * len * 0.78, y: from.y - len * 0.05))
        p.closeSubpath()
        let offset = t.translatedBy(x: 4 * dir, y: -4)
        ctx.fill(p.applying(offset), with: .color(CD.success.opacity(0.85)))
        ctx.stroke(p.applying(t), with: .color(CD.plum),
                   style: StrokeStyle(lineWidth: 4.5, lineCap: .round, lineJoin: .round))
    }

    private func blossom(at c: CGPoint, in ctx: inout GraphicsContext, transform t: CGAffineTransform) {
        for i in 0..<5 {
            let a = Double(i) / 5 * 2 * .pi - .pi / 2
            let p = Path(ellipseIn: CGRect(x: c.x + cos(a) * 6 - 4.6,
                                           y: c.y + sin(a) * 6 - 4.6,
                                           width: 9.2, height: 9.2))
            ctx.fill(p.applying(t), with: .color(CD.cream))
            ctx.stroke(p.applying(t), with: .color(CD.plum), lineWidth: 2.4)
        }
        let core = Path(ellipseIn: CGRect(x: c.x - 2.4, y: c.y - 2.4, width: 4.8, height: 4.8))
        ctx.fill(core.applying(t), with: .color(CD.lemon))
    }

    private func petal(at c: CGPoint, rotation: Double,
                       in ctx: inout GraphicsContext, transform t: CGAffineTransform) {
        var p = Path()
        p.move(to: .zero)
        p.addQuadCurve(to: CGPoint(x: 9, y: 9), control: CGPoint(x: 11, y: -2))
        p.addQuadCurve(to: .zero, control: CGPoint(x: -2, y: 11))
        let m = t.translatedBy(x: c.x, y: c.y).rotated(by: rotation)
        ctx.fill(p.applying(m), with: .color(CD.pink))
    }

    private func sparkle(at c: CGPoint, r: CGFloat,
                         in ctx: inout GraphicsContext, transform t: CGAffineTransform) {
        var p = Path()
        for i in 0..<4 {
            let a = Double(i) / 4 * .pi
            p.move(to: CGPoint(x: c.x + cos(a) * r * 0.45, y: c.y + sin(a) * r * 0.45))
            p.addLine(to: CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r))
            p.move(to: CGPoint(x: c.x - cos(a) * r * 0.45, y: c.y - sin(a) * r * 0.45))
            p.addLine(to: CGPoint(x: c.x - cos(a) * r, y: c.y - sin(a) * r))
        }
        ctx.stroke(p.applying(t), with: .color(CD.accent),
                   style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
    }
}
