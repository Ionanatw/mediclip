import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'drug_atlas_screen.dart';

/// 文件分頁：頂部分段切換「文件」與「藥品圖鑑」（圖鑑併入文件）。
class DocumentsScreen extends StatefulWidget {
  final AppState state;
  const DocumentsScreen({super.key, required this.state});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  int _seg = 0;

  List<String> get _phases {
    final seen = <String>{};
    return [for (final d in widget.state.session.documents) if (seen.add(d.phase)) d.phase];
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
          child: Row(
            children: [
              _segPill(p, 0, '文件'),
              const SizedBox(width: 8),
              _segPill(p, 1, '藥品圖鑑'),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _seg,
            children: [
              _docsList(context, p),
              DrugAtlasScreen(state: widget.state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _segPill(Palette p, int i, String label) {
    final on = _seg == i;
    return GestureDetector(
      onTap: () {
        Haptics.light();
        setState(() => _seg = i);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: on ? CD.accent : p.surface2, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: CDText.body(13, weight: FontWeight.w900, color: on ? CD.plumDeep : p.text2)),
      ),
    );
  }

  Widget _docsList(BuildContext context, Palette p) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: [
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
          for (final doc in widget.state.session.documents.where((d) => d.phase == phase)) ...[
            ListRowCard(
              iconBg: CD.info.withValues(alpha: 0.14),
              icon: const Icon(Icons.description_outlined, size: 15, color: CD.info),
              title: doc.title,
              subtitle: '${doc.dateText} · ${doc.pages} 頁 · ${doc.kinds.join('、')}',
              trailing: Icon(Icons.chevron_right, size: 16, color: p.text3),
              onTap: () => showCDSheet(context, title: doc.title, body: _docBody(p, doc)),
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

  Widget _docBody(Palette p, DocumentRecord doc) {
    Widget meta(String k, String v) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 56, child: Text(k, style: CDText.body(12.5, weight: FontWeight.w800, color: p.text3))),
              const SizedBox(width: 10),
              Expanded(child: Text(v, style: CDText.body(13, weight: FontWeight.w500, color: p.text))),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        meta('階段', doc.phase),
        meta('日期', doc.dateText),
        meta('頁數', '${doc.pages} 頁'),
        meta('類型', doc.kinds.join('、')),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.lock_outline, size: 15, color: CD.success),
            const SizedBox(width: 9),
            Expanded(
              child: Text('這份文件只存在你的手機，未上傳雲端。完整內容可在原始醫療文件查看。',
                  style: CDText.body(12.5, weight: FontWeight.w500, color: p.text2, height: 1.5)),
            ),
          ],
        ),
      ],
    );
  }
}
