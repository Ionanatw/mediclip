import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/pill_art.dart';
import '../design/illustrations/sakura_tree.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class HomeScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onOpenGarden;
  final VoidCallback onOpenChecklist;
  final VoidCallback onOpenSettings;
  const HomeScreen({
    super.key,
    required this.state,
    required this.onOpenGarden,
    required this.onOpenChecklist,
    required this.onOpenSettings,
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

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final s = state.session;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: [
        _greeting(p),
        const SizedBox(height: 16),
        if (_nextEvent != null) ...[
          _heroEventCard(_nextEvent!),
          const SizedBox(height: 20),
        ],
        SectionHeader(title: '今日用藥', trailing: '識別卡', onTap: () => state.setTab(AppTab.documents)),
        const SizedBox(height: 10),
        _medProgressCard(p, s),
        const SizedBox(height: 20),
        _highNote(p, s),
        SectionHeader(title: '你的快樂花園', trailing: '進花園', onTap: () {
          Haptics.light();
          onOpenGarden();
        }),
        const SizedBox(height: 10),
        _gardenPeek(p),
        const SizedBox(height: 14),
        _companionBubble(p),
        const SizedBox(height: 12),
        _checklistEntry(p, s),
      ],
    );
  }

  // ① 暖問候：頭像 + 早安 + 陪伴語 + 今日陽光小標
  Widget _greeting(Palette p) {
    final initial = state.session.familyName.characters.first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CD.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(initial, style: CDText.title(16, color: CD.cream)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('早安', style: CDText.body(13, weight: FontWeight.w600, color: p.text2)),
              const SizedBox(height: 2),
              Text('今天，和${state.session.familyName}一起',
                  style: CDText.display(21, color: p.text)),
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

  // ② 下一個重要行程 hero 卡（藍色、突出，倒數大數字）
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

  // ③ 今日用藥進度（環形 + 藥丸點點，形狀不同於 hero）
  Widget _medProgressCard(Palette p, CareSession s) {
    final meds = s.medications;
    final total = meds.length;
    final taken = meds.where((m) => m.takenToday).length;
    final remaining = total - taken;
    final frac = total == 0 ? 0.0 : taken / total;
    return GestureDetector(
      onTap: () {
        Haptics.light();
        state.setTab(AppTab.documents);
      },
      child: CDCard(
        radius: CD.rCardLarge,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CustomPaint(
                painter: _RingPainter(frac, track: p.surface3),
                child: Center(
                  child: Text('$taken/$total', style: CDText.display(14, color: p.text)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    remaining == 0 ? '今天的藥都吃完了' : '還有 $remaining 種要吃',
                    style: CDText.title(14, color: p.text),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final m in meds) ...[
                        _pillDot(m.takenToday),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: p.text3),
          ],
        ),
      ),
    );
  }

  Widget _pillDot(bool taken) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: taken ? CD.accentSoft : CD.lemon.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        taken ? Icons.check : Icons.medication_outlined,
        size: 13,
        color: CD.plumDeep,
      ),
    );
  }

  // ④ 今天要注意（珊瑚色警示帶；取第一則高嚴重度）
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '今天要注意'),
          const SizedBox(height: 10),
          Container(
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
        ],
      ),
    );
  }

  // ⑤ 花園一角（綠色 peek 卡）
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
                  Text('$sun / ${TreeStage.bloom.threshold} ☀ · ${species.tagline}',
                      style: CDText.body(11, weight: FontWeight.w600, color: green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⑥ 陪伴小語泡泡
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
        ],
      ),
    );
  }

  // 每日 checklist 入口（保留 onOpenChecklist）
  Widget _checklistEntry(Palette p, CareSession s) {
    final done = s.checklist.where((c) => c.done).length;
    return GestureDetector(
      onTap: () {
        Haptics.light();
        onOpenChecklist();
      },
      child: CDCard(
        child: Row(
          children: [
            const Icon(Icons.checklist, size: 15, color: CD.accent),
            const SizedBox(width: 8),
            Text('今日 checklist', style: CDText.title(13.5, color: p.text)),
            const Spacer(),
            Text('$done/${s.checklist.length}', style: CDText.body(12, weight: FontWeight.w900, color: p.text2)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: p.text3),
          ],
        ),
      ),
    );
  }
}

// 用藥進度環
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
