import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';

/// 微運動 — 跟做式：頸→肩→手臂→腳 4 個小動作各約 20 秒，換動作輕震動、結束成功震。
/// 抽象柔形隨節奏脹縮輕擺（不畫人），下方顯示動作名與提示。
class MicroMoveScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const MicroMoveScreen({super.key, required this.onClose, this.onComplete});

  @override
  State<MicroMoveScreen> createState() => _MicroMoveScreenState();
}

class _Move {
  final String name, cue;
  const _Move(this.name, this.cue);
}

const _moves = [
  _Move('轉動頸部', '慢慢轉動脖子，左右各畫幾個圈'),
  _Move('聳放肩膀', '聳起肩膀停一下，再放鬆落下'),
  _Move('伸展手臂', '雙手往上延伸，深深吸一口氣'),
  _Move('踮起腳尖', '踮起腳尖，再慢慢放回地面'),
];
const _perMove = 20; // 秒
const _green = Color(0xFF55A06A);

class _MicroMoveScreenState extends State<MicroMoveScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _motion =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..value = 0.3;
  int _move = -1;
  int _countdown = 0;
  Timer? _timer;
  bool get _ready => _move < 0;
  bool get _done => _move >= _moves.length;

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  void _start() {
    Haptics.light();
    _motion.repeat(reverse: true);
    _advance();
  }

  void _advance() {
    setState(() {
      _move++;
      _countdown = _perMove;
    });
    if (_done) {
      _motion.stop();
      Haptics.success();
      return;
    }
    Haptics.soft(); // 換動作輕點
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        _advance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBFFF6), Color(0xFFE3F1DC)],
          ),
        ),
      ),
      SafeArea(
        child: Column(
          children: [
            FlowTopBar(title: '微運動', onClose: widget.onClose),
            const Spacer(),
            SizedBox(
              height: 22,
              child: _ready
                  ? const SizedBox.shrink()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < _moves.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          _dot(i),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 18),
            // 抽象柔形：跟著節奏脹縮＋左右輕擺
            AnimatedBuilder(
              animation: _motion,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_motion.value);
                final scale = _ready ? 1.0 : 0.88 + t * 0.24;
                final dx = _ready ? 0.0 : (t - 0.5) * 28;
                return SizedBox(
                  width: 220,
                  height: 200,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFFB7E0A0), Color(0x00B7E0A0)],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(height: 80, child: _center()),
            const Spacer(),
            Padding(padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40), child: _bottom()),
          ],
        ),
      ),
    ]);
  }

  Widget _dot(int i) {
    final current = i == _move;
    final passed = i < _move || _done;
    final color = current ? _green : _green.withValues(alpha: passed ? 0.5 : 0.20);
    return Container(width: current ? 10 : 8, height: current ? 10 : 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget _center() {
    if (_ready) {
      return Text('坐著或站著都行，跟著做一輪',
          textAlign: TextAlign.center, style: CDText.body(14, weight: FontWeight.w600, color: CD.plum.withValues(alpha: 0.7)));
    }
    if (_done) {
      return Text('做得好，身體醒過來了', textAlign: TextAlign.center, style: CDText.body(16, weight: FontWeight.w800, color: CD.plum));
    }
    final m = _moves[_move];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(m.name, style: CDText.display(24, color: CD.plumDeep)),
        const SizedBox(height: 4),
        Text(m.cue, textAlign: TextAlign.center, style: CDText.body(14, weight: FontWeight.w600, color: CD.plum.withValues(alpha: 0.75))),
        const SizedBox(height: 4),
        Text('$_countdown', style: CDText.body(13, weight: FontWeight.w800, color: _green)),
      ],
    );
  }

  Widget _bottom() {
    if (_ready) return PillButton(title: '開始', style: PillStyle.lemon, onTap: _start);
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
    return Text('跟著做，時間到會自動換下一個',
        textAlign: TextAlign.center, style: CDText.body(13, weight: FontWeight.w500, color: CD.plum.withValues(alpha: 0.55)));
  }
}
