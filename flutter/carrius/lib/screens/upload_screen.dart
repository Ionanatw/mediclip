import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/pill_art.dart';
import '../state/app_state.dart';

class UploadScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onClose;
  final VoidCallback onStart;
  const UploadScreen({super.key, required this.state, required this.onClose, required this.onStart});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final picked = widget.state.pickedCount;
    return Column(
      children: [
        FlowTopBar(title: '', onClose: widget.onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              PageHeader(kicker: '新的照護時段', title: '上傳醫療文件'),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Haptics.light();
                  setState(() => widget.state.pickedCount = (picked + 1).clamp(0, 3));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: CD.accent.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(CD.rCard),
                    border: Border.all(color: CD.accent, width: 1.6),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(width: 64, height: 56, child: CameraArt()),
                      const SizedBox(height: 8),
                      Text('拍照或從相簿選擇', style: CDText.title(15, color: p.text)),
                      const SizedBox(height: 4),
                      Text('衛教單、處方箋、回診單、檢驗單\n同一時段不限張數、不另扣次',
                          textAlign: TextAlign.center, style: CDText.body(11.5, weight: FontWeight.w500, color: p.text2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _source(p, Icons.description_outlined, 'PDF', true, 'PDF 上傳'),
                  const SizedBox(width: 8),
                  _source(p, Icons.public, '網頁', true, '網頁匯入'),
                  const SizedBox(width: 8),
                  _source(p, Icons.mic_none, '語音（即將）', false, '語音輸入'),
                ],
              ),
              if (picked > 0) ...[
                const SizedBox(height: 14),
                SectionHeader(title: '已選擇 $picked 張', trailing: '清空', onTap: () => setState(() => widget.state.pickedCount = 0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var i = 0; i < picked; i++) ...[
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [CD.info.withValues(alpha: 0.2), CD.accent.withValues(alpha: 0.2)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(CD.rRow),
                          ),
                          alignment: Alignment.center,
                          child: Text(['衛教單 P.1', '衛教單 P.2', '處方箋'][i],
                              style: CDText.body(10, weight: FontWeight.w900, color: p.text2)),
                        ),
                      ),
                      if (i < picked - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 14),
              CDCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('補充說明（選填）', style: CDText.body(11.5, weight: FontWeight.w700, color: p.text3)),
                    const SizedBox(height: 4),
                    Text('護理師說傷口要保持乾燥，洗澡用…', style: CDText.body(14, color: p.text2)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PillButton(
                title: '開始 AI 整理',
                icon: Icons.auto_awesome,
                style: PillStyle.lemon,
                dimmed: picked == 0,
                onTap: () {
                  if (picked == 0) {
                    Haptics.warning();
                    return;
                  }
                  widget.onStart();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _source(Palette p, IconData icon, String label, bool enabled, String feature) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Haptics.light();
          showComingSoon(context, feature);
        },
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(CD.rRow),
              border: Border.all(color: p.cardBorder, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: p.text),
                const SizedBox(width: 7),
                Text(label, style: CDText.body(12, weight: FontWeight.w900, color: p.text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
