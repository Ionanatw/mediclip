import SwiftUI

/// 畫面 6：結果總覽
struct ResultsView: View {
    @Bindable var state: AppState
    @SwiftUI.State private var selectedMed: Medication?
    @SwiftUI.State private var showPoster = false

    var body: some View {
        VStack(spacing: 0) {
            FlowTopBar(title: "整理結果") { state.uploadStep = .none }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    PageHeader(kicker: "照護懶人包完成", title: "\(state.session.familyName)的照護重點")

                    // 摘要卡
                    Text(state.session.summary)
                        .font(.cdBody(13.5, weight: .medium))
                        .foregroundStyle(CD.text)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .card(padding: 16)

                    SectionHeader(title: "用藥（\(state.session.medications.count)）", trailing: "全部識別卡")
                    ForEach(state.session.medications.prefix(2)) { med in
                        Button {
                            Haptics.shared.light()
                            selectedMed = med
                        } label: {
                            ListRow(
                                iconBackground: CD.accent.opacity(0.16),
                                title: "\(med.name) \(med.dose)",
                                subtitle: med.timing
                            ) {
                                PillArtView(med: med).frame(width: 30, height: 30)
                            } trailing: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(CD.text3)
                            }
                        }
                        .buttonStyle(PressScaleStyle())
                    }

                    SectionHeader(title: "行程（\(state.session.events.count)）")
                    ForEach(state.session.events.prefix(2)) { event in
                        EventRow(event: event)
                    }

                    SectionHeader(title: "注意事項")
                    ForEach(state.session.notes.prefix(3)) { note in
                        NoteRow(note: note)
                    }

                    // 海報入口
                    Button {
                        Haptics.shared.light()
                        showPoster = true
                    } label: {
                        HStack(spacing: 12) {
                            MoodBlobBackground()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: CD.rIcon, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("照護海報").font(.cdTitle(13.5)).foregroundStyle(CD.text)
                                Text("圖解風格，可列印 A3/A4 貼牆上").font(.cdBody(11.5, weight: .medium))
                                    .foregroundStyle(CD.text2)
                            }
                            Spacer()
                            TagView(text: "加購", color: CD.accent)
                        }
                        .card()
                    }
                    .buttonStyle(PressScaleStyle())

                    PillButton(title: "完成，回到首頁", style: .accent) {
                        state.uploadStep = .none
                        withAnimation(CD.ease) { state.tab = .home }
                    }
                    DisclaimerFooter()
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
        .sheet(item: $selectedMed) { med in
            MedicationCardView(med: med)
        }
        .sheet(isPresented: $showPoster) { PosterView(state: state) }
    }
}

struct NoteRow: View {
    let note: CareNote

    var color: Color {
        switch note.severity {
        case .high: CD.danger
        case .medium: CD.caution
        case .low: CD.success
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: note.severity == .high ? "exclamationmark.triangle" : "info.circle")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 3) {
                Text(note.title).font(.cdTitle(13.5))
                    .foregroundStyle(note.severity == .high ? color : CD.text)
                Text(note.detail).font(.cdBody(12, weight: .medium))
                    .foregroundStyle(CD.text2).lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(note.severity == .high ? CD.danger.opacity(0.08) : CD.surface)
        .clipShape(RoundedRectangle(cornerRadius: CD.rRow, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CD.rRow, style: .continuous)
                .stroke(note.severity == .high ? CD.danger.opacity(0.3) : CD.cardBorder, lineWidth: 1)
        )
    }
}
