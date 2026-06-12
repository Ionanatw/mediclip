import SwiftUI

/// 畫面 7：藥品識別卡
struct MedicationCardView: View {
    let med: Medication
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CD.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                FlowTopBar(title: "藥品識別卡") { dismiss() }
                CDScroll {
                    VStack(alignment: .leading, spacing: 14) {
                        PageHeader(kicker: med.purpose, title: "\(med.name) \(med.dose)")

                        // 藥品插畫（真實外觀）
                        PillArtView(med: med, large: true)
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [CD.accent.opacity(0.14), CD.info.opacity(0.07)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: CD.rCard, style: .continuous)
                            )

                        // 外觀與服法標籤
                        FlowLayout(spacing: 6) {
                            TagView(text: med.appearanceText, color: CD.accent)
                            TagView(text: "刻痕 \(med.imprint)", color: CD.text2)
                            TagView(text: med.purpose, color: CD.text2)
                            TagView(text: med.timing, color: Color(hex: 0xC8D432))
                        }

                        // 禁忌紅卡
                        if let warning = med.warning {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(CD.danger)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(warning).font(.cdTitle(14)).foregroundStyle(CD.danger)
                                    if let detail = med.warningDetail {
                                        Text(detail).font(.cdBody(12, weight: .medium))
                                            .foregroundStyle(CD.text2).lineSpacing(2)
                                    }
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(CD.danger.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: CD.rCard, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: CD.rCard, style: .continuous)
                                    .stroke(CD.danger.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // 專業版（免費）
                        HStack {
                            SectionHeader(title: "注意事項（仿單原文）")
                            TagView(text: "免費", color: CD.success)
                        }
                        Text(med.professionalNote)
                            .font(.cdBody(12.5, weight: .medium))
                            .foregroundStyle(CD.text2)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .card(padding: 14)

                        // 白話版（鎖定）
                        SectionHeader(title: "白話版")
                        BlurLock(cta: "白話版 — 月費解鎖") {
                            Text(med.plainNote)
                                .font(.cdBody(13, weight: .medium))
                                .foregroundStyle(CD.text)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .card(padding: 14)
                        }

                        DisclaimerFooter()
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

/// 簡易流式排版（標籤換行用）
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 320
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
