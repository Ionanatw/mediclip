import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/illustrations/pill_art.dart';
import '../models/models.dart';

class MedCardScreen extends StatelessWidget {
  final Medication med;
  final VoidCallback onClose;
  const MedCardScreen({super.key, required this.med, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      children: [
        FlowTopBar(title: '藥品識別卡', onClose: onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              PageHeader(kicker: med.purpose, title: '${med.name} ${med.dose}'),
              const SizedBox(height: 14),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CD.accent.withValues(alpha: 0.14), CD.info.withValues(alpha: 0.07)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(CD.rCard),
                ),
                child: PillArt(med: med),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  TagView(text: med.appearanceText, color: CD.accent),
                  TagView(text: '刻痕 ${med.imprint}', color: p.text2),
                  TagView(text: med.purpose, color: p.text2),
                  TagView(text: med.timing, color: const Color(0xFFC8D432)),
                ],
              ),
              const SizedBox(height: 14),
              if (med.warning != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CD.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(CD.rCard),
                    border: Border.all(color: CD.danger.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: CD.danger),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.warning!, style: CDText.title(14, color: CD.danger)),
                            if (med.warningDetail != null) ...[
                              const SizedBox(height: 3),
                              Text(med.warningDetail!, style: CDText.body(12, weight: FontWeight.w500, color: p.text2, height: 1.4)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Expanded(child: SectionHeader(title: '注意事項（仿單原文）')),
                  const TagView(text: '免費', color: CD.success),
                ],
              ),
              const SizedBox(height: 10),
              CDCard(
                padding: const EdgeInsets.all(14),
                child: Text(med.professionalNote, style: CDText.body(12.5, weight: FontWeight.w500, color: p.text2, height: 1.5)),
              ),
              const SizedBox(height: 14),
              SectionHeader(title: '白話版'),
              const SizedBox(height: 10),
              BlurLock(
                cta: '白話版 — 月費解鎖',
                child: CDCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(med.plainNote, style: CDText.body(13, weight: FontWeight.w500, color: p.text, height: 1.5)),
                ),
              ),
              const SizedBox(height: 8),
              const DisclaimerFooter(),
            ],
          ),
        ),
      ],
    );
  }
}
