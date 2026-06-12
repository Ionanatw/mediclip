import SwiftUI

/// 畫面 2：首頁照護儀表板
struct HomeView: View {
    @Bindable var state: AppState
    @SwiftUI.State private var showChecklist = false
    @SwiftUI.State private var showSettings = false

    private var takenCount: Int { state.session.medications.filter(\.takenToday).count }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    PageHeader(kicker: "6 月 13 日 星期六", title: "午安，今天也辛苦了")
                    Button {
                        Haptics.shared.light()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(CD.text2)
                            .frame(width: 38, height: 38)
                            .background(CD.surface, in: Circle())
                    }
                    .buttonStyle(.plain)
                }

                // 統計卡
                HStack(spacing: 10) {
                    statCard("\(state.careDays)", "照護天數", CD.accent)
                    statCard("\(takenCount)/\(state.session.medications.count)", "今日用藥", CD.text)
                    statCard("3", "天後回診", CD.info)
                }

                SectionHeader(title: "即將到來", trailing: "全部") {
                    withAnimation(CD.ease) { state.tab = .calendar }
                }
                ForEach(state.session.events.prefix(2)) { event in
                    EventRow(event: event)
                }

                SectionHeader(title: "今日用藥", trailing: "識別卡")
                ForEach(state.session.medications.prefix(3)) { med in
                    MedicationRow(med: med) { state.toggleMedication(med) }
                }

                // 今日快樂卡
                Button {
                    Haptics.shared.light()
                    withAnimation(CD.ease) { state.tab = .garden }
                } label: {
                    HStack(spacing: 12) {
                        SunBurstIcon()
                            .frame(width: 34, height: 34)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("今日快樂 +\(state.sunToday)")
                                .font(.cdTitle(13.5)).foregroundStyle(CD.cream)
                            Text("完成呼吸練習，櫻花樹又長大了一點")
                                .font(.cdBody(11.5, weight: .medium))
                                .foregroundStyle(CD.accentSoft)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(CD.accentSoft)
                    }
                    .padding(14)
                    .background(
                        LinearGradient(colors: [CD.plumDeep, CD.plum],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: CD.rCard, style: .continuous)
                    )
                }
                .buttonStyle(PressScaleStyle())

                // 每日待辦入口
                Button {
                    Haptics.shared.light()
                    showChecklist = true
                } label: {
                    HStack {
                        Image(systemName: "checklist")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(CD.accent)
                        Text("每日照護待辦")
                            .font(.cdTitle(13.5)).foregroundStyle(CD.text)
                        Spacer()
                        let done = state.session.checklist.filter(\.done).count
                        Text("\(done)/\(state.session.checklist.count)")
                            .font(.cdBody(12, weight: .heavy)).foregroundStyle(CD.text2)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold)).foregroundStyle(CD.text3)
                    }
                    .card()
                }
                .buttonStyle(PressScaleStyle())

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .sheet(isPresented: $showChecklist) { ChecklistView(state: state) }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private func statCard(_ num: String, _ label: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(num).font(.cdDisplay(24)).foregroundStyle(color).tracking(-0.8)
            Text(label).font(.cdBody(11, weight: .bold)).foregroundStyle(CD.text2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

// MARK: - 共用列

struct EventRow: View {
    let event: ScheduleEvent

    var color: Color {
        switch event.kind {
        case .appointment: CD.info
        case .lab: CD.caution
        case .medication: CD.accent
        case .dressing: CD.success
        }
    }
    var icon: String {
        switch event.kind {
        case .appointment: "stethoscope"
        case .lab: "testtube.2"
        case .medication: "pills"
        case .dressing: "bandage"
        }
    }

    var body: some View {
        ListRow(
            iconBackground: color.opacity(0.16),
            title: event.title,
            subtitle: "\(event.date.month ?? 0)/\(event.date.day ?? 0) \(event.time) · \(event.detail)"
        ) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
        } trailing: {
            if let note = event.note {
                TagView(text: note, color: color)
                    .lineLimit(1)
            }
        }
    }
}

struct MedicationRow: View {
    let med: Medication
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            ListRow(
                iconBackground: CD.accent.opacity(0.16),
                title: "\(med.name) \(med.dose)",
                subtitle: med.timing
            ) {
                PillArtView(med: med)
                    .frame(width: 30, height: 30)
            } trailing: {
                if med.takenToday {
                    TagView(text: "已服用", color: CD.success)
                } else {
                    TagView(text: med.scheduledTime, color: CD.text2)
                }
            }
        }
        .buttonStyle(PressScaleStyle())
    }
}

/// 太陽 icon（檸檬色，手繪感）
struct SunBurstIcon: View {
    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) / 2
            let core = Path(ellipseIn: CGRect(x: c.x - r * 0.52, y: c.y - r * 0.52,
                                              width: r * 1.04, height: r * 1.04))
            ctx.fill(core, with: .color(CD.lemon))
            var rays = Path()
            for i in 0..<8 {
                let a = Double(i) / 8 * 2 * .pi
                rays.move(to: CGPoint(x: c.x + cos(a) * r * 0.68, y: c.y + sin(a) * r * 0.68))
                rays.addLine(to: CGPoint(x: c.x + cos(a) * r * 0.98, y: c.y + sin(a) * r * 0.98))
            }
            ctx.stroke(rays, with: .color(CD.lemon),
                       style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        }
    }
}
