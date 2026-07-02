import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';

/// 曬太陽 — 沐浴式：暖陽光暈在 90 秒間緩緩漲大變亮，引導把臉轉向光、跟著光呼吸。
/// 過程每 3 秒慢暖脈動（震動），結束成功震。抽象暖光、不畫人。
class SunbatheScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const SunbatheScreen({super.key, required this.onClose, this.onComplete});

  @override
  State<SunbatheScreen> createState() => _SunbatheScreenState();
}

class _SunbatheScreenState extends State<SunbatheScreen> with SingleTickerProviderStateMixin {
  static const _total = Duration(seconds: 90);
  late final AnimationController _sun = AnimationController(vsync: this, duration: _total)..addStatusListener(_onStatus);
  Timer? _pulse;
  bool _running = false, _done = false;

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) _finish();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    _sun.removeStatusListener(_onStatus);
    _sun.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    Haptics.light();
    _sun.forward(from: 0);
    _pulse = Timer.periodic(const Duration(seconds: 3), (_) => Haptics.soft());
  }

  void _finish() {
    _pulse?.cancel();
    setState(() {
      _running = false;
      _done = true;
    });
    Haptics.success();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4E2), Color(0xFFFFE3C4), Color(0xFFFFD3A6)],
            stops: [0, 0.55, 1],
          ),
        ),
      ),
      SafeArea(
        child: Column(
          children: [
            FlowTopBar(title: '曬太陽', onClose: widget.onClose),
            const Spacer(),
            SizedBox(
              height: 300,
              child: Center(
                child: AnimatedBuilder(
                  animation: _sun,
                  builder: (context, _) {
                    final t = (_running || _done) ? Curves.easeInOut.transform(_sun.value) : 0.0;
                    final size = 150 + t * 140;
                    final op = 0.55 + t * 0.45;
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFFFFF).withValues(alpha: op),
                            const Color(0xFFFFD27F).withValues(alpha: op * 0.85),
                            const Color(0xFFE08A2B).withValues(alpha: op * 0.35),
                            const Color(0x00E08A2B),
                          ],
                          stops: const [0.0, 0.4, 0.72, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 52, child: _caption()),
            const Spacer(),
            Padding(padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40), child: _bottom()),
          ],
        ),
      ),
    ]);
  }

  Widget _caption() {
    final String t;
    if (!_running && !_done) {
      t = '找個有光的窗邊或戶外，坐下來';
    } else if (_done) {
      t = '暖暖的，把這份能量收著';
    } else {
      t = '把臉轉向光，閉上眼，跟著光慢慢呼吸';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Text(t, textAlign: TextAlign.center, style: CDText.body(15, weight: FontWeight.w700, color: const Color(0xFF8A5A1E))),
    );
  }

  Widget _bottom() {
    if (!_running && !_done) return PillButton(title: '開始曬', style: PillStyle.lemon, onTap: _start);
    if (_done) {
      return PillButton(
        title: '收下 +3 陽光',
        style: PillStyle.lemon,
        onTap: () {
          widget.onComplete?.call();
          widget.onClose();
        },
      );
    }
    return Text('感覺陽光落在臉上、肩上',
        textAlign: TextAlign.center, style: CDText.body(13, weight: FontWeight.w500, color: const Color(0xFF8A5A1E).withValues(alpha: 0.7)));
  }
}
