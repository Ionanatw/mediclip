import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../models/drug_atlas.dart';
import '../models/drug_atlas_data.dart';
import '../state/app_state.dart';

/// 藥品圖鑑：四種常見病分組。預設收合（乾淨），可一鍵展開全部或單列展開，
/// 展開顯示實拍外觀圖 + 完整說明（對齊鴿王參考卡的 label/value）。
/// ⚠️ POC：內容版權屬食藥署/各醫院，未授權不得用於正式 App。
class DrugAtlasScreen extends StatelessWidget {
  final AppState state;
  const DrugAtlasScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      children: [
        PageHeader(kicker: '藥品圖鑑 · 四種常見病', title: '常見藥物外觀與說明'),
        const SizedBox(height: 14),
        _expandAllBar(p),
        const SizedBox(height: 8),
        Text('資料來源：食藥署藥品外觀 ＋ 各醫院藥品頁（藥台灣彙整）。POC 示意，內容版權屬原始來源，未授權前請勿用於正式 App。',
            style: CDText.body(11, weight: FontWeight.w500, color: p.text3, height: 1.45)),
        const SizedBox(height: 14),
        for (final g in drugAtlasGroups) ...[
          _diseaseHeader(p, g),
          const SizedBox(height: 10),
          for (final d in g.drugs) ...[_DrugTile(state: state, drug: d), const SizedBox(height: 10)],
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _expandAllBar(Palette p) {
    return CDCard(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      child: Row(
        children: [
          Icon(state.atlasExpandAll ? Icons.unfold_less : Icons.unfold_more, size: 18, color: CD.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('展開所有藥物外觀與說明', style: CDText.title(13.5, color: p.text)),
                Text(state.atlasExpandAll ? '目前：全部展開' : '預設收合，保持頁面整潔',
                    style: CDText.body(10.5, weight: FontWeight.w500, color: p.text3)),
              ],
            ),
          ),
          Switch(
            value: state.atlasExpandAll,
            onChanged: (_) => state.atlasToggleAll(),
            activeColor: Colors.white,
            activeTrackColor: CD.accent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: p.surface3,
          ),
        ],
      ),
    );
  }

  Widget _diseaseHeader(Palette p, DiseaseGroup g) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: CD.accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(g.name, style: CDText.title(15.5, color: p.text)),
        const SizedBox(width: 8),
        Text('${g.drugs.length} 種', style: CDText.body(11.5, weight: FontWeight.w700, color: p.text3)),
      ],
    );
  }
}

class _DrugTile extends StatelessWidget {
  final AppState state;
  final DrugFull drug;
  const _DrugTile({required this.state, required this.drug});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final open = state.atlasIsOpen(drug.slug);
    return GestureDetector(
      onTap: () => state.atlasToggleOne(drug.slug),
      child: AnimatedContainer(
        duration: CD.easeDur,
        curve: CD.ease,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(CD.rCard),
          border: Border.all(color: open ? CD.accent.withValues(alpha: 0.45) : p.cardBorder, width: 1),
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(p, open),
            if (open) ...[
              const SizedBox(height: 12),
              _photo(p),
              const SizedBox(height: 12),
              _table(p),
              const SizedBox(height: 10),
              _footer(p),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(Palette p, bool open) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: CD.accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(9)),
          child: const Icon(Icons.medication_outlined, size: 16, color: CD.accent),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(drug.chiName, style: CDText.title(13.5, color: p.text), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 1),
              Text(drug.drugClass.isNotEmpty ? drug.drugClass : drug.ingredient,
                  style: CDText.body(11, weight: FontWeight.w500, color: p.text2), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 6),
        AnimatedRotation(
          turns: open ? 0.5 : 0,
          duration: CD.easeDur,
          curve: CD.ease,
          child: Icon(Icons.expand_more, size: 20, color: p.text3),
        ),
      ],
    );
  }

  Widget _photo(Palette p) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CD.rRow),
      child: Container(
        height: 150,
        width: double.infinity,
        color: const Color(0xFFF4F2F8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(drug.photoAsset, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                      child: Text('外觀圖載入失敗', style: CDText.body(11, color: p.text3)))),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (drug.fdaImage ? CD.success : CD.accent).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(drug.fdaImage ? '食藥署官方圖' : '醫院/藥師公會圖',
                    style: CDText.body(9.5, weight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(Palette p) {
    final rows = drug.rows;
    return Container(
      decoration: BoxDecoration(
        color: p.surface2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(CD.rRow),
        border: Border.all(color: p.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i == 0 ? null : Border(top: BorderSide(color: p.cardBorder, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(rows[i].key, style: CDText.body(11.5, weight: FontWeight.w800, color: p.text3, height: 1.35)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(rows[i].value, style: CDText.body(12, weight: FontWeight.w500, color: p.text, height: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _footer(Palette p) {
    final src = drug.hasDeep && drug.deepSource.isNotEmpty ? '說明來源：${drug.deepSource}' : '說明：基本資料（深度仿單內容待授權）';
    return Row(
      children: [
        Icon(Icons.info_outline, size: 12, color: p.text3),
        const SizedBox(width: 5),
        Expanded(child: Text('$src · 請以仿單與醫囑為準', style: CDText.body(10, weight: FontWeight.w500, color: p.text3))),
        GestureDetector(
          onTap: Haptics.light,
          child: Text('仿單 PDF', style: CDText.body(10.5, weight: FontWeight.w800, color: CD.accent)),
        ),
      ],
    );
  }
}
