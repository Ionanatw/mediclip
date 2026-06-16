import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/pill_art.dart';
import '../design/illustrations/backgrounds.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'home_screen.dart' show EventRow;

class ResultsScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onClose;
  final void Function(Medication) onOpenMed;
  final VoidCallback onOpenPoster;
  final VoidCallback onFinish;
  const ResultsScreen({
    super.key,
    required this.state,
    required this.onClose,
    required this.onOpenMed,
    required this.onOpenPoster,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final s = state.session;
    return Column(
      children: [
        FlowTopBar(title: '整理結果', onClose: onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              PageHeader(kicker: '照護懶人包完成', title: '${s.familyName}的照護重點'),
              const SizedBox(height: 14),
              CDCard(
                padding: const EdgeInsets.all(16),
                child: Text(s.summary, style: CDText.body(13.5, weight: FontWeight.w500, color: p.text, height: 1.45)),
              ),
              const SizedBox(height: 14),
              SectionHeader(title: '用藥（${s.medications.length}）'),
              const SizedBox(height: 10),
              for (final med in s.medications.take(2)) ...[
                ListRowCard(
                  onTap: () => onOpenMed(med),
                  iconBg: CD.accent.withValues(alpha: 0.16),
                  icon: SizedBox(width: 30, height: 30, child: PillArt(med: med)),
                  title: '${med.name} ${med.dose}',
                  subtitle: med.timing,
                  trailing: Icon(Icons.chevron_right, size: 16, color: p.text3),
                ),
                const SizedBox(height: 10),
              ],
              SectionHeader(title: '行程（${s.events.length}）'),
              const SizedBox(height: 10),
              for (final e in s.events.take(2)) ...[EventRow(event: e), const SizedBox(height: 10)],
              SectionHeader(title: '注意事項'),
              const SizedBox(height: 10),
              for (final note in s.notes.take(3)) ...[NoteRow(note: note), const SizedBox(height: 10)],
              GestureDetector(
                onTap: () {
                  Haptics.light();
                  onOpenPoster();
                },
                child: CDCard(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(CD.rIcon),
                        child: const SizedBox(width: 44, height: 44, child: MoodBlobBackground()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('照護海報', style: CDText.title(13.5, color: p.text)),
                            const SizedBox(height: 2),
                            Text('圖解風格，可列印 A3/A4 貼牆上', style: CDText.body(11.5, weight: FontWeight.w500, color: p.text2)),
                          ],
                        ),
                      ),
                      const TagView(text: '加購', color: CD.accent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              PillButton(title: '完成，回到首頁', onTap: onFinish),
              const SizedBox(height: 4),
              const DisclaimerFooter(),
            ],
          ),
        ),
      ],
    );
  }
}

class NoteRow extends StatelessWidget {
  final CareNote note;
  const NoteRow({super.key, required this.note});

  Color get color => switch (note.severity) {
        Severity.high => CD.danger,
        Severity.medium => CD.caution,
        Severity.low => CD.success,
      };

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final high = note.severity == Severity.high;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: high ? CD.danger.withValues(alpha: 0.08) : p.surface,
        borderRadius: BorderRadius.circular(CD.rRow),
        border: Border.all(color: high ? CD.danger.withValues(alpha: 0.3) : p.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(high ? Icons.warning_amber_rounded : Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: CDText.title(13.5, color: high ? color : p.text)),
                const SizedBox(height: 3),
                Text(note.detail, style: CDText.body(12, weight: FontWeight.w500, color: p.text2, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
