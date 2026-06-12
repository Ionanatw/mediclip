import SwiftUI

// MARK: - Phantom design tokens（取自 phantom.com production CSS）

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    /// 深淺色動態色
    init(light: UInt32, dark: UInt32) {
        #if os(iOS)
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
        #else
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(Color(hex: dark))
                : NSColor(Color(hex: light))
        })
        #endif
    }
}

enum CD {
    // 背景與表面
    static let bg = Color(light: 0xFFFDF8, dark: 0x1C1C1C)
    static let surface = Color(light: 0xFDFCFE, dark: 0x28282C)
    static let surface2 = Color(light: 0xF4F2F4, dark: 0x34343A)
    static let surface3 = Color(light: 0xEDEDEF, dark: 0x2E2E32)

    // 文字
    static let text = Color(light: 0x3C315B, dark: 0xFFFDF8)
    static let text2 = Color(light: 0x86848D, dark: 0xA09FA6)
    static let text3 = Color(light: 0xA09FA6, dark: 0x86848D)

    // 品牌
    static let accent = Color(hex: 0xAB9FF2)       // 薰衣草紫
    static let accentSoft = Color(hex: 0xE2DFFE)
    static let plum = Color(hex: 0x3C315B)
    static let plumDeep = Color(hex: 0x2C2250)
    static let lemon = Color(hex: 0xF1FF52)
    static let cream = Color(hex: 0xFFFDF8)

    // 機能色
    static let success = Color(hex: 0x45E863)
    static let danger = Color(hex: 0xFF0037)
    static let caution = Color(hex: 0xFFD600)
    static let info = Color(hex: 0x6CA0FB)

    // 插畫粉色系（櫻花）
    static let pink = Color(hex: 0xFFB7D5)
    static let pinkLight = Color(hex: 0xFFD9E8)
    static let pinkHot = Color(hex: 0xFF7EB0)

    // 卡片邊框
    static let cardBorder = Color(light: 0x3C315B, dark: 0xFFFDF8).opacity(0.08)

    // 圓角
    static let rCard: CGFloat = 18
    static let rCardLarge: CGFloat = 24
    static let rRow: CGFloat = 14
    static let rIcon: CGFloat = 11

    // 動效（Phantom cubic-bezier(.22,1,.36,1) 0.4s）
    static let ease = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.4)
    static let easeSlow = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.7)
}

// MARK: - 字體（SF Pro Rounded 標題 + 系統內文）

extension Font {
    static func cdDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static func cdTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func cdBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}
