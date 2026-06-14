import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens.dart';

/// B 風格：呼吸練習頁的霧面光暈漸層背景（黃昏紫粉、無輪廓）
class BreathBackground extends StatelessWidget {
  const BreathBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFA99BE8), Color(0xFFD8A8C8), Color(0xFFF8C9B8), Color(0xFF2C2250)],
              stops: [0, 0.45, 0.78, 0.98],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.48),
              radius: 0.8,
              colors: [
                const Color(0xFFFFE9D8).withValues(alpha: 0.9),
                const Color(0xFFFFD3B8).withValues(alpha: 0.4),
                const Color(0xFFFFD3B8).withValues(alpha: 0),
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
      ],
    );
  }
}

/// C 風格：有機色塊拼貼（心情小卡、照護海報用）
class MoodBlobBackground extends StatelessWidget {
  final Color base;
  const MoodBlobBackground({super.key, this.base = const Color(0xFF4D4474)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BlobPainter(base), size: Size.infinite);
  }
}

class _BlobPainter extends CustomPainter {
  final Color base;
  _BlobPainter(this.base);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final u = math.min(size.width, size.height) / 300;
    canvas.save();
    canvas.scale(u);

    void blob(double cx, double cy, double r, double wobble, Color color, double opacity) {
      const n = 8;
      final pts = <Offset>[];
      for (var i = 0; i < n; i++) {
        final a = i / n * 2 * math.pi;
        final rr = r * (i.isEven ? 1.0 : wobble);
        pts.add(Offset(cx + math.cos(a) * rr, cy + math.sin(a) * rr * 0.86));
      }
      final p = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 0; i < n; i++) {
        final cur = pts[i];
        final next = pts[(i + 1) % n];
        final mid = Offset((cur.dx + next.dx) / 2, (cur.dy + next.dy) / 2);
        final ctrl = Offset(mid.dx + (next.dy - cur.dy) * 0.2, mid.dy - (next.dx - cur.dx) * 0.2);
        p.quadraticBezierTo(ctrl.dx, ctrl.dy, next.dx, next.dy);
      }
      p.close();
      canvas.drawPath(p, Paint()..color = color.withValues(alpha: opacity));
    }

    blob(150, 120, 95, 0.8, const Color(0xFFE8AFC4), 0.9);
    blob(175, 95, 55, 0.84, const Color(0xFFF2C9D6), 0.85);
    blob(95, 100, 45, 0.78, const Color(0xFFD89BB8), 0.8);
    blob(230, 175, 26, 0.8, const Color(0xFFE8C96A), 0.9);
    blob(62, 185, 20, 0.82, CD.accent, 0.75);

    // 點點紋理
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 6; col++) {
        canvas.drawCircle(
          Offset(190 + col * 13, 28 + row * 13),
          2.2,
          Paint()..color = CD.plumDeep.withValues(alpha: 0.45),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.base != base;
}
