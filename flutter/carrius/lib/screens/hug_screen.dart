import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';

/// 給自己一個擁抱 — 雙光合攏：兩團柔光從左右緩緩合攏，把中間一小團暖光包起來
///（「抱住自己」的抽象化，同身體掃描的光暈語言）。20 秒，每 3 秒兩下輕震
/// 像拍撫的節奏，結束成功震。
class HugScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const HugScreen({super.key, required this.onClose, this.onComplete});

  @override
  State<HugScreen> createState() => _HugScreenState();
}

class _HugScreenState extends State<HugScreen> with SingleTickerProviderStateMixin {
  static const _total = Duration(seconds: 20);
  late final AnimationController _hug = AnimationController(vsync: this, duration: _total)..addStatusListener(_onStatus);
  Timer? _pat;
  bool _running = false, _done = false;

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) _finish();
  }

  @override
  void dispose() {
    _pat?.cancel();
    _hug.removeStatusListener(_onStatus);
    _hug.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    Haptics.light();
    _hug.forward(from: 0);
    // 拍撫節奏：每 3 秒兩下輕點（像輕拍孩子的背）
    _pat = Timer.periodic(const Duration(seconds: 3), (_) async {
      Haptics.soft();
      await Future.delayed(const Duration(milliseconds: 170));
      Haptics.soft();
    });
  }

  void _finish() {
    _pat?.cancel();
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
            colors: [Color(0xFFF5F1FD), Color(0xFFE7DFFA), Color(0xFFDDD2F5)],
            stops: [0, 0.55, 1],
          ),
        ),
      ),
      SafeArea(
        child: Column(
          children: [
            FlowTopBar(title: '給自己一個擁抱', onClose: widget.onClose),
            const Spacer(),
            SizedBox(
              height: 300,
              child: AnimatedBuilder(
                animation: _hug,
                builder: (context, _) {
                  final t = (_running || _done) ? Curves.easeInOut.transform(_hug.value) : 0.0;
                  final reach = 165 - t * 137; // 兩臂光暈從畫面兩緣向中心合攏（起點在緣外，避免讀成一張臉）
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // 中心的自己：一小團暖光，被抱著會更亮
                      Opacity(
                        opacity: 0.22 + t * 0.78,
                        child: Transform.scale(scale: 0.9 + t * 0.25, child: _glow(58, const [Color(0xFFFFF6E8), Color(0xAAFFD6A0)])),
                      ),
                      Transform.translate(offset: Offset(-reach, 0), child: _glow(140, const [Color(0xE6FFFFFF), Color(0x8CAB9FF2)])),
                      Transform.translate(offset: Offset(reach, 0), child: _glow(140, const [Color(0xE6FFFFFF), Color(0x8CAB9FF2)])),
                    ],
                  );
                },
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

  Widget _glow(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [colors[0], colors[1], colors[1].withValues(alpha: 0)], stops: const [0.0, 0.55, 1.0]),
      ),
    );
  }

  Widget _caption() {
    final String t;
    if (!_running && !_done) {
      t = '找個舒服的姿勢，坐著躺著都可以';
    } else if (_done) {
      t = '抱好了，這份暖留給自己';
    } else {
      t = '雙手環抱自己，跟著光慢慢收攏';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Text(t, textAlign: TextAlign.center, style: CDText.body(15, weight: FontWeight.w700, color: const Color(0xFF544A9E))),
    );
  }

  Widget _bottom() {
    if (!_running && !_done) return PillButton(title: '開始抱', style: PillStyle.lemon, onTap: _start);
    if (_done) {
      return PillButton(
        title: '收下 +1 陽光',
        style: PillStyle.lemon,
        onTap: () {
          widget.onComplete?.call();
          widget.onClose();
        },
      );
    }
    return Text('輕輕拍，像安撫一個累了的孩子',
        textAlign: TextAlign.center, style: CDText.body(13, weight: FontWeight.w500, color: const Color(0xFF544A9E).withValues(alpha: 0.7)));
  }
}
