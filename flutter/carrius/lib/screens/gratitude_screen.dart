import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../models/mock_data.dart';
import '../state/app_state.dart';
import '../design/illustrations/sakura_tree.dart';

/// 感謝自己 — 葉子回到樹上：畫面就是你花園裡正在養的那棵樹。
/// 寫一句感謝存下來，文字化成一片葉子飄上樹冠，樹輕輕一晃＋發光。
/// 感恩直接餵進「陽光值養樹」的世界觀。題目可換（3 句輪替）。
class GratitudeScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const GratitudeScreen({super.key, required this.state, required this.onClose, this.onComplete});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

const _greenD = Color(0xFF23705B);

class _GratitudeScreenState extends State<GratitudeScreen> with TickerProviderStateMixin {
  late final AnimationController _leaf = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  final _input = TextEditingController();
  int _prompt = 0;
  bool _saving = false, _done = false;

  @override
  void dispose() {
    _leaf.dispose();
    _pulse.dispose();
    _input.dispose();
    super.dispose();
  }

  void _nextPrompt() {
    Haptics.soft();
    setState(() => _prompt = (_prompt + 1) % MockData.gratitudePrompts.length);
  }

  void _save() {
    if (_saving) return;
    setState(() => _saving = true);
    FocusScope.of(context).unfocus();
    Haptics.light();
    _leaf.forward(from: 0).whenComplete(() async {
      setState(() => _done = true);
      await _pulse.forward(from: 0);
      await _pulse.reverse();
      widget.onComplete?.call(); // 加陽光（completeActivity 內含成功/升級震動）
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Stack(fit: StackFit.expand, children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FBF6), Color(0xFFE2F2E7), Color(0xFFD5EBDC)],
            stops: [0, 0.55, 1],
          ),
        ),
      ),
      SafeArea(
        child: Column(
          children: [
            FlowTopBar(title: '感謝自己', onClose: widget.onClose),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                children: [
                  // 引導題目（可換一題）
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(999)),
                          child: Text(MockData.gratitudePrompts[_prompt],
                              style: CDText.body(12.5, weight: FontWeight.w800, color: _greenD)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _saving ? null : _nextPrompt,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 13, color: _greenD.withValues(alpha: 0.8)),
                              const SizedBox(width: 3),
                              Text('換一題', style: CDText.body(11, weight: FontWeight.w800, color: _greenD.withValues(alpha: 0.8))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 你正在養的那棵樹（同花園）
                  SizedBox(
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) => Transform.scale(scale: 1 + _pulse.value * 0.06, child: child),
                      child: GardenTree(species: widget.state.currentSpecies, stage: widget.state.stage),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    child: Center(
                      child: Text(
                        _done ? '你的感恩，讓樹又綠了一點' : '寫一句就好，樹會替你記得',
                        style: _done
                            ? CDText.title(14, color: _greenD)
                            : CDText.body(12, weight: FontWeight.w600, color: _greenD.withValues(alpha: 0.65)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CDCard(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _input,
                      maxLines: 3,
                      enabled: !_saving,
                      style: CDText.body(15, color: p.text),
                      decoration: InputDecoration.collapsed(
                          hintText: '今天，我謝謝自己…', hintStyle: CDText.body(15, color: p.text3)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PillButton(
                    title: _saving ? '收進樹裡…' : '存下來 · +2 陽光',
                    icon: Icons.eco_outlined,
                    style: PillStyle.lemon,
                    onTap: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 葉子飛行（存下時：從輸入卡飄上樹冠）
      IgnorePointer(
        child: AnimatedBuilder(
          animation: _leaf,
          builder: (context, _) {
            if (!_leaf.isAnimating) return const SizedBox.shrink();
            final t = Curves.easeInOut.transform(_leaf.value);
            return Align(
              alignment: Alignment.lerp(const Alignment(0, 0.02), const Alignment(0.08, -0.56), t)!,
              child: Opacity(
                opacity: t < 0.9 ? 1 : (1 - t) * 10,
                child: Transform.rotate(
                  angle: t * 2.6,
                  child: Container(
                    width: 22,
                    height: 13,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E8B72),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(11),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
