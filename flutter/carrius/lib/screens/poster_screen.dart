import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/backgrounds.dart';
import '../state/app_state.dart';

class PosterScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onClose;
  const PosterScreen({super.key, required this.state, required this.onClose});

  @override
  State<PosterScreen> createState() => _PosterScreenState();
}

class _PosterScreenState extends State<PosterScreen> {
  bool _a3 = true;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      children: [
        FlowTopBar(title: '照護海報', onClose: widget.onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              PageHeader(kicker: '貼在冰箱上，全家都看得懂', title: '圖解照護海報'),
              const SizedBox(height: 14),
              BlurLock(
                cta: '加購 \$49 解鎖列印',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CD.rCardLarge),
                  child: SizedBox(
                    height: 230,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const MoodBlobBackground(),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${widget.state.session.familyName}的照護重點', style: CDText.display(19, color: CD.cream)),
                              const SizedBox(height: 10),
                              Text('用藥 4 種 · 回診 6/16 · 注意事項 5 條',
                                  style: CDText.body(12, weight: FontWeight.w700, color: CD.cream.withValues(alpha: 0.85))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _sizeChip(p, 'A3', _a3, () => setState(() => _a3 = true)),
                  const SizedBox(width: 8),
                  _sizeChip(p, 'A4', !_a3, () => setState(() => _a3 = false)),
                  const Spacer(),
                  const TagView(text: '一次買斷', color: CD.accent),
                ],
              ),
              const SizedBox(height: 14),
              CDCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in ['圖解風格，長輩一看就懂', '可到超商列印 A3/A4', '內容隨整理結果自動更新']) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 13, color: CD.success),
                          const SizedBox(width: 8),
                          Text(line, style: CDText.body(13, weight: FontWeight.w500, color: p.text)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PillButton(title: '加購海報 \$49', icon: Icons.print_outlined, style: PillStyle.lemon, onTap: Haptics.soft),
              const SizedBox(height: 4),
              const DisclaimerFooter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sizeChip(Palette p, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Haptics.selectionTick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? CD.accent : p.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: CDText.body(13, weight: FontWeight.w900, color: selected ? CD.plumDeep : p.text)),
      ),
    );
  }
}
