import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens.dart';
import '../../models/models.dart';

/// 藥品插畫（A 風格描邊＋錯位高光），形狀／顏色／刻痕照真實藥品外觀欄位。
/// ⚠️ 外觀資料目前為示意，未經食藥署核實——見 docs/drug-appearance-check.html。
class PillArt extends StatelessWidget {
  final Medication med;
  const PillArt({super.key, required this.med});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PillPainter(med), size: Size.infinite);
  }
}

class _PillPainter extends CustomPainter {
  final Medication med;
  _PillPainter(this.med);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final scale = math.min(size.width, size.height) / 120;

    // 陰影
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 36 * scale), width: 84 * scale, height: 10 * scale),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-16 * math.pi / 180);
    canvas.scale(scale);

    switch (med.form) {
      case PillForm.capsule:
        _capsule(canvas);
      case PillForm.tablet:
        _tablet(canvas);
      case PillForm.oblong:
        _oblong(canvas);
    }
    canvas.restore();
  }

  Paint get _outline => Paint()
    ..style = PaintingStyle.stroke
    ..color = CD.plum
    ..strokeJoin = StrokeJoin.round;

  void _capsule(Canvas c) {
    final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -16, 100, 32), const Radius.circular(16));
    c.drawRRect(rect, Paint()..color = Color(med.colorA));
    final right = RRect.fromRectAndRadius(const Rect.fromLTWH(1, -14.5, 47.5, 29), const Radius.circular(14.5));
    c.drawRRect(right, Paint()..color = Color(med.colorB));
    c.drawLine(const Offset(0, -16), const Offset(0, 16), Paint()..color = CD.plum..strokeWidth = 3);
    c.drawRRect(rect, _outline..strokeWidth = 3.4);
    c.drawOval(const Rect.fromLTWH(-38, -11, 20, 8), Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  void _tablet(Canvas c) {
    final circle = const Rect.fromLTWH(-30, -30, 60, 60);
    c.drawOval(circle, Paint()..color = Color(med.colorA));
    c.drawOval(circle, _outline..strokeWidth = 3.4);
    c.drawLine(const Offset(-18, 0), const Offset(18, 0), Paint()..color = CD.plum.withValues(alpha: 0.5)..strokeWidth = 2.4);
    c.drawOval(const Rect.fromLTWH(-18, -22, 16, 7), Paint()..color = Colors.white.withValues(alpha: 0.8));
  }

  void _oblong(Canvas c) {
    final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(-46, -19, 92, 38), const Radius.circular(19));
    c.drawRRect(rect, Paint()..color = Color(med.colorA));
    c.drawRRect(rect, _outline..strokeWidth = 3.4);
    c.drawOval(const Rect.fromLTWH(-34, -13, 22, 8), Paint()..color = Colors.white.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(_PillPainter old) => old.med != med;
}

/// 上傳空狀態相機插畫（A 風格）
class CameraArt extends StatelessWidget {
  const CameraArt({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _CameraPainter(), size: Size.infinite);
}

class _CameraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 50;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = CD.accent
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(-17, -9, 34, 24), const Radius.circular(7));
    canvas.save();
    canvas.translate(1.4, -1.2);
    canvas.drawRRect(body, Paint()..color = CD.accentSoft);
    canvas.restore();
    canvas.drawRRect(body, stroke);
    final top = Path()
      ..moveTo(-8, -9)
      ..lineTo(-5, -14)
      ..lineTo(5, -14)
      ..lineTo(8, -9);
    canvas.drawPath(top, stroke);
    canvas.drawCircle(const Offset(0, 2), 7, stroke);
    canvas.drawCircle(const Offset(0, 3), 2, Paint()..color = CD.lemon);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CameraPainter old) => false;
}

/// 太陽 icon
class SunBurst extends StatelessWidget {
  const SunBurst({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _SunPainter(), size: Size.infinite);
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    canvas.drawCircle(c, r * 0.52, Paint()..color = CD.lemon);
    final rays = Paint()
      ..style = PaintingStyle.stroke
      ..color = CD.lemon
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;
    for (var i = 0; i < 8; i++) {
      final a = i / 8 * 2 * math.pi;
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * r * 0.68, c.dy + math.sin(a) * r * 0.68),
        Offset(c.dx + math.cos(a) * r * 0.98, c.dy + math.sin(a) * r * 0.98),
        rays,
      );
    }
  }

  @override
  bool shouldRepaint(_SunPainter old) => false;
}
