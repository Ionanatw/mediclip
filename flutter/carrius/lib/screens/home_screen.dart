import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/pill_art.dart';
import '../design/illustrations/sakura_tree.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// 首頁（2026-07-02 改版定案）：H3 順序（頂部 T3 → 回診 hero → 花園 →
/// 「今天要做的」餐錨點任務流 → 今天隨時 → 注意 → 陪伴泡泡）。
/// 任務流＝版 3 聚焦現在：過完的時段自動灰收合、「現在」聚焦卡套時段色、
/// 未到的收合待辦；藥名大字＋藥單正確全名小字；單顆勾＋「全部吃了」。
class HomeScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onOpenGarden;
  final VoidCallback onOpenSettings;

  /// 測試用固定時段（null＝跟隨系統時鐘）。決定「現在」聚焦哪個時段。
  final int? nowHour;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onOpenGarden,
    required this.onOpenSettings,
    this.nowHour,
  });

  // 倒數參考日：以衛教單給藥起始日為「今天」，讓行程倒數穩定可預期（不依系統時鐘）。
  static const int _refMonth = 6;
  static const int _refDay = 13;

  // 下一個重要行程：優先回診，其次任何非用藥行程；以參考日往後算天數。
  ScheduleEvent? get _nextEvent {
    final upcoming = state.session.events
        .where((e) => e.kind != EventKind.medication && _daysUntil(e) >= 0)
        .toList()
      ..sort((a, b) => _daysUntil(a).compareTo(_daysUntil(b)));
    if (upcoming.isEmpty) return null;
    return upcoming.firstWhere(
      (e) => e.kind == EventKind.appointment,
      orElse: () => upcoming.first,
    );
  }

  int _daysUntil(ScheduleEvent e) => (e.month - _refMonth) * 30 + (e.day - _refDay);

  /// 現在時段（餐錨點）：深夜歸睡前；用餐時間未來可在設定調整。
  int get _currentSlot {
    final h = nowHour ?? DateTime.now().hour;
    if (h < 5) return 4; // 深夜 → 睡前
    if (h < 10) return 0; // 早餐
    if (h < 14) return 1; // 午餐
    if (h < 16) return 2; // 中午照護
    if (h < 21) return 3; // 晚餐
    return 4; // 睡前
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final s = state.session;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 150),
      children: [
        _topBar(p),
        const SizedBox(height: 16),
        if (_nextEvent != null) ...[
          _heroEventCard(_nextEvent!),
          const SizedBox(height: 12),
        ],
        _gardenPeek(p),
        const SizedBox(height: 20),
        SectionHeader(title: '今天要做的', trailing: '識別卡', onTap: () {
          state.setDocumentsTab(1);
          state.setTab(AppTab.documents);
        }),
        const SizedBox(height: 10),
        ..._taskFlow(p),
        const SizedBox(height: 12),
        _anytimeCard(p),
        const SizedBox(height: 20),
        _highNote(p, s),
        _companionBubble(p),
      ],
    );
  }

  // ---- 時段色 ----
  static (Color, Color, Color) _tint(SlotTint t) => switch (t) {
        SlotTint.breakfast => (const Color(0xFFC2872E), const Color(0xFFFFF3DA), const Color(0xFFFFE9C4)),
        SlotTint.lunch => (const Color(0xFFD2691E), const Color(0xFFFFEAD8), const Color(0xFFFFDDBE)),
        SlotTint.care => (const Color(0xFF2E8B72), const Color(0xFFE2F4E9), const Color(0xFFD2EDDD)),
        SlotTint.dinner => (const Color(0xFF3F7BC4), const Color(0xFFE2EEFC), const Color(0xFFD0E2F8)),
        SlotTint.night => (const Color(0xFF6B5FC0), const Color(0xFFEBE4FC), const Color(0xFFDED4F8)),
      };

  static const _warnText = Color(0xFFB3552E);

  /// 完成態＝無色相：整塊去飽和＋降不透明（含勾勾，對齊 mockup）。
  static const _grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  Widget _fade(bool done, Widget child) =>
      done ? Opacity(opacity: 0.55, child: ColorFiltered(colorFilter: _grayscale, child: child)) : child;

  // ---- ① 頂部 T3：今日進度環 + 日期/照護天數 + ☀ ----
  Widget _topBar(Palette p) {
    final done = state.todayDone, total = state.todayTotal;
    final frac = total == 0 ? 0.0 : done / total;
    return Row(
      children: [
        SizedBox(
          width: 46,
          height: 46,
          child: CustomPaint(
            painter: _RingPainter(frac, track: p.surface3),
            child: Center(child: Text('$done/$total', style: CDText.display(9.5, color: p.text))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_refMonth/$_refDay（五）· 第 ${state.careDays} 天',
                  style: CDText.body(12, weight: FontWeight.w600, color: p.text2)),
              const SizedBox(height: 2),
              Text('今天完成 $done / $total', style: CDText.display(19, color: p.text)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 16, color: CD.accent),
              const SizedBox(width: 5),
              Text('${state.sunToday}', style: CDText.title(14, color: p.text)),
            ],
          ),
        ),
      ],
    );
  }

  // ---- ② 下一個重要行程 hero 卡（藍色、倒數大數字） ----
  Widget _heroEventCard(ScheduleEvent e) {
    final days = _daysUntil(e);
    final countdown = days <= 0 ? '今天' : '$days';
    return GestureDetector(
      onTap: () {
        Haptics.light();
        state.setTab(AppTab.calendar);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CD.info, Color(0xFF8FB8FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(CD.rCardLarge),
          boxShadow: [
            BoxShadow(
              color: CD.info.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CD.cream.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('下一個重要行程',
                        style: CDText.body(11, weight: FontWeight.w700, color: CD.cream)),
                  ),
                  const SizedBox(height: 10),
                  Text(e.title, style: CDText.display(18, color: CD.cream)),
                  const SizedBox(height: 4),
                  Text('${e.month}/${e.day} ${e.time} · ${e.detail}',
                      style: CDText.body(12, weight: FontWeight.w500, color: CD.cream.withValues(alpha: 0.92))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(countdown, style: CDText.display(34, color: CD.cream)),
                Text(days <= 0 ? '就是今天' : '天後',
                    style: CDText.body(11, weight: FontWeight.w700, color: CD.cream.withValues(alpha: 0.92))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- ③ 花園一角（移到行程卡正下方） ----
  Widget _gardenPeek(Palette p) {
    final species = state.currentSpecies;
    final stage = state.stage;
    final sun = state.currentSun;
    final frac = (sun / TreeStage.bloom.threshold).clamp(0.02, 1.0);
    const green = Color(0xFF2E8B72);
    return GestureDetector(
      onTap: () {
        Haptics.light();
        onOpenGarden();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF8FD3A6).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(CD.rCardLarge),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: GardenTree(species: species, stage: stage),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('你的${species.nameZh} · ${stage.label}期',
                      style: CDText.title(13.5, color: p.text)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 7,
                      color: CD.cream.withValues(alpha: 0.7),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: frac,
                        child: Container(color: green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text('$sun / ${TreeStage.bloom.threshold} ',
                          style: CDText.body(11, weight: FontWeight.w600, color: green)),
                      Icon(Icons.wb_sunny_outlined, size: 12, color: green),
                      Flexible(
                        child: Text(' · ${species.tagline}',
                            style: CDText.body(11, weight: FontWeight.w600, color: green),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- ④ 餐錨點任務流：過去→灰收合、現在→聚焦卡、未來→收合待辦 ----
  List<Widget> _taskFlow(Palette p) {
    final cur = _currentSlot;
    final widgets = <Widget>[];
    for (var i = 0; i < state.daySlots.length; i++) {
      final slot = state.daySlots[i];
      if (i == cur && slot.groups.length == 2) {
        // 現在是某一餐：餐前聚焦、餐後獨立收合欄
        widgets
          ..add(_nowCard(p, slot, slot.groups[0].tasks))
          ..add(const SizedBox(height: 7))
          ..add(_slotBar(p, slot, tasks: slot.groups[1].tasks, label: '${slot.title}後', openKey: '${slot.id}-post'));
      } else if (i == cur) {
        widgets.add(_nowCard(p, slot, slot.tasks.toList()));
      } else {
        widgets.add(_slotBar(p, slot, tasks: slot.tasks.toList(), label: _barLabel(slot), openKey: slot.id));
      }
      widgets.add(const SizedBox(height: 7));
    }
    widgets.removeLast();
    return widgets;
  }

  String _barLabel(DaySlot slot) =>
      slot.groups.length == 2 ? '${slot.title}（餐前 3＋餐後 1）' : slot.title;

  /// 「現在」聚焦卡：時段色漸層＋live 點＋任務列＋全部吃了
  Widget _nowCard(Palette p, DaySlot slot, List<CareTask> tasks) {
    final (_, bg1, bg2) = _tint(slot.tint);
    final allDone = tasks.every((t) => t.done);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [bg1, bg2]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: _warnText, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text('現在 · ${slot.nowLabel}',
                  style: CDText.body(10.5, weight: FontWeight.w900, color: _warnText).copyWith(letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 4),
          Text(slot.nowTitle, style: CDText.display(16, color: CD.plumDeep)),
          const SizedBox(height: 8),
          for (final t in tasks) ...[
            _taskRow(t),
            const SizedBox(height: 6),
          ],
          if (!allDone && tasks.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => state.completeCareGroup(tasks),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: CD.plumDeep.withValues(alpha: 0.10), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Text(slot.tint == SlotTint.care ? '都做完了' : '全部吃了',
                      style: CDText.body(10.5, weight: FontWeight.w900, color: CD.plumDeep)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 收合時段欄：標題＋進度＋箭頭，點開展開任務列；全完成整欄無色相。
  Widget _slotBar(Palette p, DaySlot slot,
      {required List<CareTask> tasks, required String label, required String openKey}) {
    final (_, bg1, bg2) = _tint(slot.tint);
    final done = tasks.where((t) => t.done).length;
    final open = state.openSlots.contains(openKey);
    return _fade(
      done == tasks.length,
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [bg1, bg2]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => state.toggleSlotOpen(openKey),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    Text(label, style: CDText.title(13, color: CD.plumDeep)),
                    const SizedBox(width: 8),
                    Text('$done / ${tasks.length}',
                        style: CDText.body(10.5, weight: FontWeight.w900, color: CD.plumDeep.withValues(alpha: 0.55))),
                    const Spacer(),
                    AnimatedRotation(
                      turns: open ? 0.25 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.chevron_right, size: 17, color: CD.plumDeep.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),
            ),
            if (open)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  children: [
                    for (final t in tasks) ...[
                      _taskRow(t),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 任務列：藥名大字＋正確全名小字＋注意事項（紅字警告／灰字提醒）＋勾框。
  Widget _taskRow(CareTask t) {
    return GestureDetector(
      onTap: () => state.toggleCareTask(t),
      child: _fade(
        t.done,
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title, style: CDText.title(13, color: CD.plumDeep)),
                    if (t.fullName != null) ...[
                      const SizedBox(height: 1),
                      Text(t.fullName!,
                          style: CDText.body(9, weight: FontWeight.w600, color: CD.plumDeep.withValues(alpha: 0.45))),
                    ],
                    const SizedBox(height: 2),
                    Text(t.note,
                        style: CDText.body(10.5,
                            weight: FontWeight.w700,
                            color: t.warn ? _warnText : const Color(0xFF5D5478))),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: t.done ? CD.success : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(9),
                  border: t.done ? null : Border.all(color: CD.plumDeep.withValues(alpha: 0.25), width: 2.5),
                ),
                child: t.done ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- ⑤ 今天隨時（不綁時段；承接原 checklist 的飲食／活動） ----
  Widget _anytimeCard(Palette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDEBF2), Color(0xFFF8DCE8)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('今天隨時', style: CDText.title(13, color: CD.plumDeep)),
              const SizedBox(width: 7),
              Text('不綁時段，做到就勾',
                  style: CDText.body(10, weight: FontWeight.w800, color: CD.plumDeep.withValues(alpha: 0.5))),
            ],
          ),
          const SizedBox(height: 7),
          for (final t in state.anytimeTasks) ...[
            _taskRow(t),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  // ---- ⑥ 今天要注意（珊瑚色警示帶；取第一則高嚴重度） ----
  Widget _highNote(Palette p, CareSession s) {
    CareNote? note;
    for (final n in s.notes) {
      if (n.severity == Severity.high) {
        note = n;
        break;
      }
    }
    if (note == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CD.danger.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(CD.rCard),
          border: Border.all(color: CD.danger.withValues(alpha: 0.18), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CD.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.priority_high, size: 18, color: CD.cream),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: CDText.title(13.5, color: p.text)),
                  const SizedBox(height: 3),
                  Text(note.detail,
                      style: CDText.body(11.5, weight: FontWeight.w500, color: p.text2, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- ⑦ 陪伴小語泡泡 ----
  Widget _companionBubble(Palette p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(CD.rCard),
          topRight: Radius.circular(CD.rCard),
          bottomRight: Radius.circular(CD.rCard),
          bottomLeft: Radius.circular(6),
        ),
        border: Border.all(color: p.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: CD.accentSoft, shape: BoxShape.circle),
            child: const Icon(Icons.eco_outlined, size: 17, color: CD.plumDeep),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text('記得喝口水、深呼吸三次。我陪你一起顧${state.session.familyName}。',
                style: CDText.body(12.5, weight: FontWeight.w500, color: p.text2, height: 1.5)),
          ),
          // 右側留白給浮動 FAB：泡泡保持滿版背景，但文字不延伸到 FAB 區（FAB 浮在空白上、不碰字）。
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}

// 今日進度環（頂部 T3）
class _RingPainter extends CustomPainter {
  final double value;
  final Color track;
  _RingPainter(this.value, {required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 6) / 2;
    const stroke = 6.0;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);
    if (value <= 0) return;
    final progPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = CD.accent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // 12 點鐘起算
      6.28318 * value.clamp(0, 1),
      false,
      progPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.track != track;
}

// ---- 共用列（calendar/results 仍 import：簽名與行為維持不變）----

class EventRow extends StatelessWidget {
  final ScheduleEvent event;
  const EventRow({super.key, required this.event});

  Color get color => switch (event.kind) {
        EventKind.appointment => CD.info,
        EventKind.lab => CD.caution,
        EventKind.medication => CD.accent,
        EventKind.dressing => CD.success,
      };
  IconData get icon => switch (event.kind) {
        EventKind.appointment => Icons.medical_services_outlined,
        EventKind.lab => Icons.science_outlined,
        EventKind.medication => Icons.medication_outlined,
        EventKind.dressing => Icons.healing_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return ListRowCard(
      iconBg: color.withValues(alpha: 0.16),
      icon: Icon(icon, size: 15, color: color),
      title: event.title,
      subtitle: '${event.month}/${event.day} ${event.time} · ${event.detail}',
      trailing: event.note != null ? TagView(text: event.note!, color: color) : null,
    );
  }
}

class MedicationRow extends StatelessWidget {
  final Medication med;
  final VoidCallback onTap;
  const MedicationRow({super.key, required this.med, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListRowCard(
      onTap: onTap,
      iconBg: CD.accent.withValues(alpha: 0.16),
      icon: SizedBox(width: 30, height: 30, child: PillArt(med: med)),
      title: '${med.name} ${med.dose}',
      subtitle: med.timing,
      trailing: med.takenToday
          ? const TagView(text: '已服用', color: CD.success)
          : TagView(text: med.scheduledTime, color: PaletteScope.of(context).text2),
    );
  }
}
