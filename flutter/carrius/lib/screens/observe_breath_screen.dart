import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/backgrounds.dart';

/// 觀呼吸：不數息，只是看著呼吸自然起伏（圓緩慢脹縮），每次吸↔吐轉換輕震動。約 1 分鐘。
class ObserveBreathScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const ObserveBreathScreen({super.key, required this.onClose, this.onComplete});

  @override
  State<ObserveBreathScreen> createState() => _ObserveBreathScreenState();
}

class _ObserveBreathScreenState extends State<ObserveBreathScreen> with SingleTickerProviderStateMixin {
  static const _inhale = Duration(seconds: 4);
  static const _exhale = Duration(seconds: 6);
  static const _total = Duration(seconds: 60);

  late final AnimationController _orb =
      AnimationController(vsync: this, lowerBound: 0.5, upperBound: 1.0, duration: _inhale)..value = 0.5;
  bool _running = false, _done = false, _inhaling = true;
  Timer? _endTimer;

  @override
  void dispose() {
    _orb.removeStatusListener(_onStatus);
    _orb.dispose();
    _endTimer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _inhaling = true;
    });
    Haptics.light();
    _orb.addStatusListener(_onStatus);
    _orb.duration = _inhale;
    _orb.forward();
    _endTimer = Timer(_total, _finish);
  }

  void _onStatus(AnimationStatus s) {
    if (!mounted || _done) return;
    if (s == AnimationStatus.completed) {
      setState(() => _inhaling = false);
      Haptics.soft();
      _orb.duration = _exhale;
      _orb.reverse();
    } else if (s == AnimationStatus.dismissed) {
      setState(() => _inhaling = true);
      Haptics.soft();
      _orb.duration = _inhale;
      _orb.forward();
    }
  }

  void _finish() {
    _orb.removeStatusListener(_onStatus);
    _orb.stop();
    setState(() {
      _running = false;
      _done = true;
    });
    Haptics.success();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      const BreathBackground(),
      SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    Haptics.light();
                    widget.onClose();
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, size: 18, color: CD.cream),
                  ),
                ),
                const SizedBox(width: 12),
                Text('觀呼吸', style: CDText.body(13, weight: FontWeight.w900, color: CD.cream.withValues(alpha: 0.85))),
              ]),
            ),
            const Spacer(),
            // 階段字在上、呼吸圓在下（不疊在圓上）
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 44,
                  child: _running
                      ? Text(_inhaling ? '吸氣' : '吐氣', style: CDText.display(30, color: CD.plumDeep))
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _orb,
                  builder: (context, _) {
                    return SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(alignment: Alignment.center, children: [
                        Transform.scale(
                          scale: _orb.value * 1.16,
                          child: Container(width: 250, height: 250, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.13), shape: BoxShape.circle)),
                        ),
                        Transform.scale(
                          scale: _orb.value,
                          child: Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                const Color(0xFFFFE9F2).withValues(alpha: 0.95),
                                const Color(0xFFFFC9DF).withValues(alpha: 0.55),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Padding(padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40), child: _bottom()),
          ],
        ),
      ),
    ]);
  }

  Widget _bottom() {
    if (!_running && !_done) {
      return Column(children: [
        Text('不用控制呼吸，只是看著它自然起伏',
            textAlign: TextAlign.center,
            style: CDText.body(14, weight: FontWeight.w500, color: CD.cream.withValues(alpha: 0.9), height: 1.4)),
        const SizedBox(height: 14),
        PillButton(title: '開始', style: PillStyle.lemon, onTap: _start),
      ]);
    }
    if (_done) {
      return Column(children: [
        Text('做得很好，把這份安定帶回去', style: CDText.body(14, weight: FontWeight.w500, color: CD.cream.withValues(alpha: 0.9))),
        const SizedBox(height: 14),
        PillButton(
          title: '收下 +2 陽光',
          style: PillStyle.lemon,
          onTap: () {
            widget.onComplete?.call();
            widget.onClose();
          },
        ),
      ]);
    }
    return Text('圓變大時吸氣，變小時吐氣',
        textAlign: TextAlign.center, style: CDText.body(13, weight: FontWeight.w500, color: CD.cream.withValues(alpha: 0.7)));
  }
}
