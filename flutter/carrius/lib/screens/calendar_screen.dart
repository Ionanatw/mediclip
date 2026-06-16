import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'home_screen.dart' show EventRow;

class CalendarScreen extends StatefulWidget {
  final AppState state;
  const CalendarScreen({super.key, required this.state});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _weekdays = ['日', '一', '二', '三', '四', '五', '六'];
  static const _today = 13;
  static const _leadingBlanks = 1; // 2026/6/1 = 週一
  static const _daysInMonth = 30;
  int _selected = 13;

  Set<int> get _eventDays =>
      widget.state.session.events.where((e) => e.kind != EventKind.medication).map((e) => e.day).toSet();
  Set<int> get _medDays =>
      widget.state.session.events.where((e) => e.kind == EventKind.medication).map((e) => e.day).toSet();
  List<ScheduleEvent> get _dayEvents =>
      widget.state.session.events.where((e) => e.day == _selected || e.kind == EventKind.medication).toList();

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: [
        PageHeader(kicker: '2026 年', title: '6 月'),
        const SizedBox(height: 14),
        CDCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  for (final d in _weekdays)
                    Expanded(child: Center(child: Text(d, style: CDText.body(10, weight: FontWeight.w900, color: p.text3)))),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
                children: [
                  for (var i = 0; i < _leadingBlanks; i++) const SizedBox.shrink(),
                  for (var day = 1; day <= _daysInMonth; day++) _dayCell(p, day),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionHeader(title: '6/$_selected ${_weekdayName(_selected)}', trailing: '今天', onTap: () {
          Haptics.selectionTick();
          setState(() => _selected = _today);
        }),
        const SizedBox(height: 10),
        if (_dayEvents.isEmpty)
          CDCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text('這天沒有安排，休息也是照護的一部分', style: CDText.body(13, weight: FontWeight.w500, color: p.text2)),
              ),
            ),
          )
        else
          for (final e in _dayEvents) ...[EventRow(event: e), const SizedBox(height: 10)],
        const SizedBox(height: 4),
        PillButton(
            title: '加入手機行事曆 (.ics)',
            icon: Icons.ios_share,
            onTap: () => showComingSoon(context, '.ics 匯出')),
        const SizedBox(height: 8),
        Center(child: Text('.ics 匯出永遠免費，正式版開放', style: CDText.body(11, weight: FontWeight.w500, color: p.text3))),
      ],
    );
  }

  Widget _dayCell(Palette p, int day) {
    final selected = day == _selected;
    Color dot = Colors.transparent;
    if (_eventDays.contains(day)) dot = CD.info;
    if (_medDays.contains(day)) dot = CD.accent;
    return GestureDetector(
      onTap: () {
        Haptics.selectionTick();
        setState(() => _selected = day);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? CD.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day',
                style: CDText.body(12.5, weight: selected ? FontWeight.w900 : FontWeight.w700, color: selected ? CD.plumDeep : p.text)),
            const SizedBox(height: 2),
            Container(width: 4, height: 4, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int day) => '週${_weekdays[day % 7]}';
}
