import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../state/app_state.dart';

class DocumentsScreen extends StatelessWidget {
  final AppState state;
  const DocumentsScreen({super.key, required this.state});

  List<String> get _phases {
    final seen = <String>{};
    return [for (final d in state.session.documents) if (seen.add(d.phase)) d.phase];
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: [
        PageHeader(kicker: '時間軸', title: '文件紀錄'),
        const SizedBox(height: 14),
        for (final phase in _phases) ...[
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: CD.accent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(phase, style: CDText.title(14, color: p.text)),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: p.cardBorder)),
            ],
          ),
          const SizedBox(height: 10),
          for (final doc in state.session.documents.where((d) => d.phase == phase)) ...[
            ListRowCard(
              iconBg: CD.info.withValues(alpha: 0.14),
              icon: const Icon(Icons.description_outlined, size: 15, color: CD.info),
              title: doc.title,
              subtitle: '${doc.dateText} · ${doc.pages} 頁 · ${doc.kinds.join('、')}',
              trailing: Icon(Icons.chevron_right, size: 16, color: p.text3),
            ),
            const SizedBox(height: 10),
          ],
        ],
        CDCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 16, color: CD.success),
              const SizedBox(width: 10),
              Expanded(
                child: Text('所有文件與整理結果只存在這台手機，不上傳雲端',
                    style: CDText.body(12, weight: FontWeight.w500, color: p.text2)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
