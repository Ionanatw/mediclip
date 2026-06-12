import SwiftUI

/// 畫面 8：行事曆
struct CalendarScreen: View {
    @Bindable var state: AppState
    @SwiftUI.State private var selectedDay = 13

    private let today = 13
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    // 2026 年 6 月：6/1 是週一
    private let leadingBlanks = 1
    private let daysInMonth = 30

    private var eventDays: Set<Int> {
        Set(state.session.events.compactMap { $0.kind == .medication ? nil : $0.date.day })
    }
    private var medDays: Set<Int> {
        Set(state.session.events.compactMap { $0.kind == .medication ? $0.date.day : nil })
    }
    private var dayEvents: [ScheduleEvent] {
        state.session.events.filter { $0.date.day == selectedDay || $0.kind == .medication }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                PageHeader(kicker: "2026 年", title: "6 月")

                // 月曆
                VStack(spacing: 6) {
                    HStack {
                        ForEach(weekdays, id: \.self) { d in
                            Text(d).font(.cdBody(10, weight: .heavy))
                                .foregroundStyle(CD.text3)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(0..<leadingBlanks, id: \.self) { _ in Color.clear.frame(height: 34) }
                        ForEach(1...daysInMonth, id: \.self) { day in
                            dayCell(day)
                        }
                    }
                }
                .card(padding: 12)

                SectionHeader(title: "6/\(selectedDay) \(weekdayName(selectedDay))",
                              trailing: "今天") {
                    Haptics.shared.selectionTick()
                    withAnimation(CD.ease) { selectedDay = today }
                }

                if dayEvents.isEmpty {
                    Text("這天沒有安排，休息也是照護的一部分")
                        .font(.cdBody(13, weight: .medium)).foregroundStyle(CD.text2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 26)
                        .card()
                } else {
                    ForEach(dayEvents) { event in
                        EventRow(event: event)
                    }
                }

                PillButton(title: "加入手機行事曆 (.ics)", icon: "square.and.arrow.down", style: .accent) {
                    // POC：永遠免費的功能，真實版產出 .ics
                }
                Text(".ics 匯出永遠免費")
                    .font(.cdBody(11, weight: .medium)).foregroundStyle(CD.text3)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
    }

    private func dayCell(_ day: Int) -> some View {
        Button {
            Haptics.shared.selectionTick()
            withAnimation(CD.ease) { selectedDay = day }
        } label: {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.cdBody(12.5, weight: day == selectedDay ? .heavy : .bold))
                Circle()
                    .fill(dotColor(day))
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(
                day == selectedDay ? CD.accent : .clear,
                in: RoundedRectangle(cornerRadius: 9, style: .continuous)
            )
            .foregroundStyle(day == selectedDay ? CD.plumDeep : CD.text)
        }
        .buttonStyle(.plain)
    }

    private func dotColor(_ day: Int) -> Color {
        if eventDays.contains(day) { return CD.info }
        if medDays.contains(day) { return CD.accent }
        return .clear
    }

    private func weekdayName(_ day: Int) -> String {
        // 2026/6/1 週一 → index = day % 7
        weekdays[(day % 7 + 0) % 7].isEmpty ? "" : "週" + weekdays[(day + 0) % 7]
    }
}
