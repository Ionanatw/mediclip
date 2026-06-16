import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/pill_art.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final s = state.session;
    final taken = s.medications.where((m) => m.takenToday).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: PageHeader(kicker: '6 月 13 日 星期六', title: '午安，今天也辛苦了')),
            GestureDetector(
              onTap: () {
                Haptics.light();
                onOpenSettings();
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: p.surface, shape: BoxShape.circle),
                child: Icon(Icons.settings_outlined, size: 17, color: p.text2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _stat(p, '${state.careDays}', '照護天數', CD.accent),
            const SizedBox(width: 10),
            _stat(p, '$taken/${s.medications.length}', '今日用藥', p.text),
            const SizedBox(width: 10),
            _stat(p, '3', '天後回診', CD.info),
          ],
        ),
        const SizedBox(height: 14),
        SectionHeader(title: '即將到來', trailing: '全部', onTap: () => state.setTab(AppTab.calendar)),
        const SizedBox(height: 10),
        for (final e in s.events.take(2)) ...[EventRow(event: e), const SizedBox(height: 10)],
        SectionHeader(title: '今日用藥', trailing: '識別卡', onTap: () => state.setTab(AppTab.documents)),
        const SizedBox(height: 10),
        for (final m in s.medications.take(3)) ...[
          MedicationRow(med: m, onTap: () => state.toggleMedication(m)),
          const SizedBox(height: 10),
        ],
        _happyCard(),
        const SizedBox(height: 10),
        _checklistEntry(p, s),
      ],
    );
  }

  Widget _stat(Palette p, String num, String label, Color color) {
    return Expanded(
      child: CDCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(num, style: CDText.display(24, color: color)),
            const SizedBox(height: 2),
            Text(label, style: CDText.body(11, weight: FontWeight.w700, color: p.text2)),
          ],
        ),
      ),
    );
  }

  Widget _happyCard() {
    return GestureDetector(
      onTap: () {
        Haptics.light();
        onOpenGarden();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [CD.plumDeep, CD.plum], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(CD.rCard),
        ),
        child: Row(
          children: [
            const SizedBox(width: 34, height: 34, child: SunBurst()),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('今日快樂 +${state.sunToday}', style: CDText.title(13.5, color: CD.cream)),
                  const SizedBox(height: 2),
                  Text('完成呼吸練習，今天又前進了一點', style: CDText.body(11.5, weight: FontWeight.w500, color: CD.accentSoft)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: CD.accentSoft),
          ],
        ),
      ),
    );
  }

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
            Text('每日照護待辦', style: CDText.title(13.5, color: p.text)),
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

// ---- 共用列 ----

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
