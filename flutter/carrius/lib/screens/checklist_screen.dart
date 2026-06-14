import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class ChecklistScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onClose;
  const ChecklistScreen({super.key, required this.state, required this.onClose});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<String> get _categories {
    final seen = <String>{};
    return [for (final c in widget.state.session.checklist) if (seen.add(c.category)) c.category];
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final list = widget.state.session.checklist;
    final done = list.where((c) => c.done).length;
    return Column(
      children: [
        FlowTopBar(title: '每日照護待辦', onClose: widget.onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              PageHeader(kicker: '6 月 13 日', title: '今天的照護清單'),
              const SizedBox(height: 14),
              CDCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$done', style: CDText.display(26, color: CD.accent)),
                        const SizedBox(width: 4),
                        Text('/ ${list.length} 完成', style: CDText.body(13, weight: FontWeight.w700, color: p.text2)),
                        const Spacer(),
                        if (done == list.length) const TagView(text: '全部完成，了不起', color: CD.success),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SunProgressBar(value: list.isEmpty ? 0 : done / list.length),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final cat in _categories) ...[
                SectionHeader(title: cat),
                const SizedBox(height: 10),
                for (final item in list.where((c) => c.category == cat)) ...[
                  _row(p, item),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(Palette p, ChecklistItem item) {
    return GestureDetector(
      onTap: () => setState(() => widget.state.toggleChecklist(item)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(CD.rRow),
          border: Border.all(color: p.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: item.done ? CD.success : p.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.done ? const Icon(Icons.check, size: 12, color: CD.plumDeep) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: CDText.title(13.5, color: item.done ? p.text3 : p.text).copyWith(
                          decoration: item.done ? TextDecoration.lineThrough : null,
                          decorationColor: p.text3)),
                  if (item.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(item.detail!, style: CDText.body(11.5, weight: FontWeight.w500, color: p.text3)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
