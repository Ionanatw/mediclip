import SwiftUI

// MARK: - 卡片

struct CardModifier: ViewModifier {
    var padding: CGFloat = 14
    var radius: CGFloat = CD.rCard
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(CD.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(CD.cardBorder, lineWidth: 1)
            )
    }
}

extension View {
    func card(padding: CGFloat = 14, radius: CGFloat = CD.rCard) -> some View {
        modifier(CardModifier(padding: padding, radius: radius))
    }
}

// MARK: - 膠囊按鈕

struct PillButton: View {
    enum Style { case accent, lemon, ghost }
    let title: String
    var icon: String? = nil
    var style: Style = .accent
    var action: () -> Void

    @SwiftUI.State private var pressed = false

    var body: some View {
        Button {
            Haptics.shared.light()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: 15, weight: .bold)) }
                Text(title).font(.cdTitle(15.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(Capsule())
        }
        .buttonStyle(PressScaleStyle())
    }

    private var background: Color {
        switch style {
        case .accent: CD.accent
        case .lemon: CD.lemon
        case .ghost: CD.surface2
        }
    }
    private var foreground: Color {
        switch style {
        case .accent, .lemon: CD.plumDeep
        case .ghost: CD.text
        }
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(CD.ease, value: configuration.isPressed)
    }
}

// MARK: - 標籤

struct TagView: View {
    let text: String
    var color: Color = CD.accent
    var filled: Bool = false

    var body: some View {
        Text(text)
            .font(.cdBody(11, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(filled ? color : color.opacity(0.16))
            .foregroundStyle(filled ? CD.plumDeep : color)
            .clipShape(Capsule())
    }
}

// MARK: - 區塊標題

struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.cdTitle(15)).foregroundStyle(CD.text)
            Spacer()
            if let trailing {
                Button { onTap?() } label: {
                    Text(trailing).font(.cdBody(12, weight: .bold)).foregroundStyle(CD.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - 列表項

struct ListRow<Icon: View, Trailing: View>: View {
    let iconBackground: Color
    let title: String
    let subtitle: String
    @ViewBuilder var icon: Icon
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: CD.rIcon, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 36, height: 36)
                icon
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.cdTitle(13.5)).foregroundStyle(CD.text)
                    .lineLimit(1)
                Text(subtitle).font(.cdBody(11.5, weight: .medium)).foregroundStyle(CD.text2)
                    .lineLimit(2)
            }
            Spacer(minLength: 6)
            trailing
        }
        .padding(11)
        .background(CD.surface)
        .clipShape(RoundedRectangle(cornerRadius: CD.rRow, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CD.rRow, style: .continuous)
                .stroke(CD.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - 進度條

struct SunProgressBar: View {
    let value: Double   // 0...1
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(CD.surface3)
                Capsule().fill(CD.lemon)
                    .frame(width: max(8, geo.size.width * value))
            }
        }
        .frame(height: 8)
        .animation(CD.easeSlow, value: value)
    }
}

// MARK: - 鎖定模糊遮罩（付費導流）

struct BlurLock<Content: View>: View {
    let cta: String
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            content
                .blur(radius: 5)
                .opacity(0.7)
                .accessibilityHidden(true)
            Button {
                Haptics.shared.soft()   // 鎖定功能：soft 警示
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill").font(.system(size: 11, weight: .bold))
                    Text(cta).font(.cdBody(12, weight: .heavy))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(CD.accent)
                .foregroundStyle(CD.plumDeep)
                .clipShape(Capsule())
            }
            .buttonStyle(PressScaleStyle())
        }
    }
}

// MARK: - 頁面標題

struct PageHeader: View {
    let kicker: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(kicker).font(.cdBody(12, weight: .bold)).foregroundStyle(CD.text2)
            Text(title).font(.cdDisplay(24)).foregroundStyle(CD.text)
                .tracking(-0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 免責聲明

struct DisclaimerFooter: View {
    var body: some View {
        Text("此內容由 AI 輔助整理，請與原始醫療文件核對")
            .font(.cdBody(10.5, weight: .medium))
            .foregroundStyle(CD.text3)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
    }
}
