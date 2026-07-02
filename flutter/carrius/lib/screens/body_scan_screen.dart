import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';

/// 身體掃描（MBSR 正念）— 一團柔光沿軸線由上往下移動，光點經過某部位時該部位名稱亮起。
/// 過去的部位留淡、未到的更淡；到位輕震動。不畫身體、不用方框，與無臉抽象樹同一套視覺語言。
class BodyScanScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const BodyScanScreen({super.key, required this.onClose, this.onComplete});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

const _regions = ['頭頂', '肩膀', '胸口', '腹部', '雙腿', '腳底'];
const _dwell = Duration(seconds: 8);

// 光暈軌道版面
const double _stageH = 460;
const double _padTop = 52;
const double _padBot = 52;

class _BodyScanScreenState extends State<BodyScanScreen> {
  int _region = -1; // -1=準備, >=len=完成
  Timer? _timer;
  bool get _ready => _region < 0;
  bool get _done => _region >= _regions.length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    Haptics.light();
    _advance();
  }

  void _advance() {
    setState(() => _region++);
    if (_done) {
      Haptics.success();
      return;
    }
    Haptics.soft(); // 光點到位輕點
    _timer = Timer(_dwell, _advance);
  }

  double _regionY(int i) => _padTop + i * ((_stageH - _padTop - _padBot) / (_regions.length - 1));

  @override
  Widget build(BuildContext context) {
    final idx = _region.clamp(0, _regions.length - 1);
    final orbY = _regionY(idx);
    final orbOpacity = _ready ? 0.4 : (_done ? 0.85 : 0.98);

    return Stack(fit: StackFit.expand, children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAE3FB), Color(0xFFD6CBF3), Color(0xFFE0D6F7)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      ),
      // 沿軌道的柔光（讓光點有舞台，不是死白）
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, 0),
            radius: 0.85,
            colors: [
              const Color(0xFFF3EEFE).withValues(alpha: 0.55),
              const Color(0xFFF3EEFE).withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
      SafeArea(
        child: Column(
          children: [
            _topBar(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: _stageH,
              child: Stack(
                children: [
                  // 淡軌道線
                  const Positioned.fill(child: CustomPaint(painter: _AxisPainter())),
                  // 柔光點（沿軌道滑行）
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    top: orbY - 70,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: orbOpacity,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              Color(0xFFFFFFFF),
                              Color(0xCCC9C0F8),
                              Color(0x00C9C0F8),
                            ], stops: [0.0, 0.45, 1.0]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 六個部位名稱（光點經過才亮）
                  for (int i = 0; i < _regions.length; i++) _name(i),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(height: 34, child: _caption()),
            const Spacer(),
            Padding(padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40), child: _bottom()),
          ],
        ),
      ),
    ]);
  }

  Widget _name(int i) {
    final current = i == _region;
    final passed = i < _region;
    final color = current ? CD.plumDeep : CD.plum.withValues(alpha: passed ? 0.5 : 0.24);
    return Positioned(
      top: _regionY(i) - 30,
      left: 0,
      right: 0,
      height: 60,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOut,
          style: CDText.body(current ? 26 : 15, weight: current ? FontWeight.w900 : FontWeight.w700, color: color),
          child: Text(_regions[i]),
        ),
      ),
    );
  }

  Widget _topBar() => Padding(
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
              decoration: BoxDecoration(color: CD.accent.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, size: 18, color: CD.plum),
            ),
          ),
          const SizedBox(width: 12),
          Text('身體掃描', style: CDText.body(13, weight: FontWeight.w900, color: CD.plum.withValues(alpha: 0.85))),
        ]),
      );

  Widget _caption() {
    final String t;
    if (_ready) {
      t = '找個舒服的姿勢，放鬆躺好或坐著';
    } else if (_done) {
      t = '掃描完成，整個身體都鬆了';
    } else {
      t = '把注意力放到${_regions[_region]}，讓它鬆下來';
    }
    return Text(t, textAlign: TextAlign.center, style: CDText.body(14, weight: FontWeight.w600, color: CD.plum));
  }

  Widget _bottom() {
    if (_ready) return PillButton(title: '開始', style: PillStyle.lemon, onTap: _start);
    if (_done) {
      return PillButton(
        title: '收下 +2 陽光',
        style: PillStyle.lemon,
        onTap: () {
          widget.onComplete?.call();
          widget.onClose();
        },
      );
    }
    return Text('跟著光，一個部位一個部位放鬆',
        textAlign: TextAlign.center, style: CDText.body(13, weight: FontWeight.w500, color: CD.plum.withValues(alpha: 0.6)));
  }
}

/// 淡淡的垂直軌道線（光點沿此下行）。
class _AxisPainter extends CustomPainter {
  const _AxisPainter();
  @override
  void paint(Canvas c, Size s) {
    final x = s.width / 2;
    final p = Paint()
      ..color = const Color(0xFFAB9FF2).withValues(alpha: 0.16)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(x, _padTop), Offset(x, s.height - _padBot), p);
  }

  @override
  bool shouldRepaint(_AxisPainter old) => false;
}
