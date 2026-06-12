import SwiftUI

/// B 風格：呼吸練習頁的霧面光暈漸層背景（黃昏紫粉、無輪廓）
struct BreathBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0xA99BE8), location: 0),
                    .init(color: Color(hex: 0xD8A8C8), location: 0.45),
                    .init(color: Color(hex: 0xF8C9B8), location: 0.78),
                    .init(color: Color(hex: 0x2C2250), location: 0.98)
                ],
                startPoint: .top, endPoint: .bottom
            )
            // 落日光暈
            RadialGradient(
                colors: [Color(hex: 0xFFE9D8).opacity(0.9),
                         Color(hex: 0xFFD3B8).opacity(0.4),
                         .clear],
                center: .init(x: 0.5, y: 0.74), startRadius: 10, endRadius: 240
            )
            // 漂浮花瓣微粒
            GeometryReader { geo in
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: 0xFFDCEA).opacity(0.5 + Double(i % 3) * 0.15))
                        .frame(width: CGFloat(4 + i % 3 * 2))
                        .position(
                            x: geo.size.width * [0.18, 0.82, 0.32, 0.7, 0.12, 0.9][i],
                            y: geo.size.height * [0.3, 0.22, 0.6, 0.52, 0.74, 0.66][i]
                        )
                }
            }
        }
        .ignoresSafeArea()
    }
}

/// C 風格：有機色塊（心情小卡、照護海報用）
struct MoodBlobBackground: View {
    var base: Color = Color(hex: 0x4D4474)

    var body: some View {
        ZStack {
            base
            Canvas { ctx, size in
                let u = min(size.width, size.height) / 300
                func blob(cx: CGFloat, cy: CGFloat, r: CGFloat, wobble: CGFloat,
                          color: Color, opacity: Double) {
                    var p = Path()
                    let n = 8
                    var pts: [CGPoint] = []
                    for i in 0..<n {
                        let a = Double(i) / Double(n) * 2 * .pi
                        let rr = r * (i % 2 == 0 ? 1 : wobble)
                        pts.append(CGPoint(x: cx + cos(a) * rr, y: cy + sin(a) * rr * 0.86))
                    }
                    p.move(to: pts[0])
                    for i in 0..<n {
                        let next = pts[(i + 1) % n]
                        let cur = pts[i]
                        let mid = CGPoint(x: (cur.x + next.x) / 2, y: (cur.y + next.y) / 2)
                        let ctrl = CGPoint(x: mid.x + (next.y - cur.y) * 0.2,
                                           y: mid.y - (next.x - cur.x) * 0.2)
                        p.addQuadCurve(to: next, control: ctrl)
                    }
                    p.closeSubpath()
                    ctx.fill(p.applying(.init(scaleX: u, y: u)), with: .color(color.opacity(opacity)))
                }
                blob(cx: 150, cy: 120, r: 95, wobble: 0.8, color: Color(hex: 0xE8AFC4), opacity: 0.9)
                blob(cx: 175, cy: 95, r: 55, wobble: 0.84, color: Color(hex: 0xF2C9D6), opacity: 0.85)
                blob(cx: 95, cy: 100, r: 45, wobble: 0.78, color: Color(hex: 0xD89BB8), opacity: 0.8)
                blob(cx: 230, cy: 175, r: 26, wobble: 0.8, color: Color(hex: 0xE8C96A), opacity: 0.9)
                blob(cx: 62, cy: 185, r: 20, wobble: 0.82, color: CD.accent, opacity: 0.75)
                // 點點紋理
                for row in 0..<5 {
                    for col in 0..<6 {
                        let dot = Path(ellipseIn: CGRect(
                            x: (190 + CGFloat(col) * 13) * u,
                            y: (28 + CGFloat(row) * 13) * u,
                            width: 4.4 * u, height: 4.4 * u))
                        ctx.fill(dot, with: .color(CD.plumDeep.opacity(0.45)))
                    }
                }
            }
        }
    }
}
