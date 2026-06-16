import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens.dart';

/// 成長階段（所有樹種共用，門檻對齊 PRD：0/20/60/120/200）
enum TreeStage {
  seed(0, '種子'),
  sprout(20, '發芽'),
  sapling(60, '幼苗'),
  growing(120, '茁壯'),
  bloom(200, '大樹');

  const TreeStage(this.threshold, this.label);
  final int threshold;
  final String label;

  static TreeStage forSun(int sun) {
    var result = TreeStage.seed;
    for (final s in TreeStage.values) {
      if (sun >= s.threshold) result = s;
    }
    return result;
  }
}

/// POC 三棵樹（依序解鎖）。新增品種 = 加一筆 enum + 一組 TreePalette（JSON-config 精神）。
enum TreeSpecies {
  sakura('櫻花樹', '療癒的開始', '註冊即可開始'),
  tea('茶樹', '泡杯茶，休息一下', '第 1 棵長成後解鎖'),
  orange('橘子樹', '照護旅程的收穫', '第 2 棵長成後解鎖');

  const TreeSpecies(this.nameZh, this.tagline, this.unlockHint);
  final String nameZh;
  final String tagline;
  final String unlockHint;

  // 荒廢訊息（溫和，永不死亡）
  static const idle3d = '我有點渴了…';
  static const idle7d = '沒關係，你先忙，我等你';
  static const idle14d = '我還在這裡。';
}

/// 樹種美術配色（描邊塗鴉風）。⚠️ 佔位，待鴿王拍板樹概念後替換，架構不變。
class TreePalette {
  final Color canopy, canopyInner, accentDot, fruit;
  const TreePalette({
    required this.canopy,
    required this.canopyInner,
    required this.accentDot,
    this.fruit = const Color(0x00000000),
  });

  static const sakura = TreePalette(canopy: CD.pink, canopyInner: CD.pinkLight, accentDot: CD.pinkHot);
  static const tea = TreePalette(
      canopy: Color(0xFF8FD3A6), canopyInner: Color(0xFFCFEDD9), accentDot: CD.cream);
  static const orange = TreePalette(
      canopy: Color(0xFF8ACB97), canopyInner: Color(0xFFC9E8CC), accentDot: Color(0xFFFFFFFF), fruit: Color(0xFFFF9D42));

  static TreePalette of(TreeSpecies s) => switch (s) {
        TreeSpecies.sakura => sakura,
        TreeSpecies.tea => tea,
        TreeSpecies.orange => orange,
      };
}

/// 養成樹（描邊錯位塗鴉風）。依品種換配色與結果裝飾。
class GardenTree extends StatelessWidget {
  final TreeSpecies species;
  final TreeStage stage;
  const GardenTree({super.key, this.species = TreeSpecies.sakura, required this.stage});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _TreePainter(species, stage), size: Size.infinite);
  }
}

/// 櫻花樹（向後相容：welcome 頁與 golden 用）。
class SakuraTree extends StatelessWidget {
  final TreeStage stage;
  const SakuraTree({super.key, required this.stage});

  @override
  Widget build(BuildContext context) => GardenTree(species: TreeSpecies.sakura, stage: stage);
}

class _TreePainter extends CustomPainter {
  final TreeSpecies species;
  final TreeStage stage;
  _TreePainter(this.species, this.stage);

  TreePalette get pal => TreePalette.of(species);

  static const double _design = 300;
  static const double _lineW = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    canvas.scale(s / _design);

    _strokePath(canvas, _groundPath(), width: 4.5);

    if (stage.index >= TreeStage.growing.index) {
      _sparkle(canvas, const Offset(52, 70), 11);
      _sparkle(canvas, const Offset(252, 46), 8);
    }

    switch (stage) {
      case TreeStage.seed:
        _drawSeed(canvas);
      case TreeStage.sprout:
        _drawSprout(canvas);
      case TreeStage.sapling:
        _drawSapling(canvas);
      case TreeStage.growing:
      case TreeStage.bloom:
        _drawTree(canvas, full: stage == TreeStage.bloom);
    }
    canvas.restore();
  }

  // ---- 共用 ----
  Paint get _plumStroke => Paint()
    ..style = PaintingStyle.stroke
    ..color = CD.plum
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = _lineW;

  void _strokePath(Canvas c, Path p, {double width = _lineW}) {
    c.drawPath(p, _plumStroke..strokeWidth = width);
  }

  /// 錯位填色：往右上偏移後填，再回原位描邊由呼叫端負責
  void _fillOffset(Canvas c, Path p, Color color, {double dx = 9, double dy = -8}) {
    c.save();
    c.translate(dx, dy);
    c.drawPath(p, Paint()..color = color);
    c.restore();
  }

  Path _groundPath() {
    return Path()
      ..moveTo(80, 252)
      ..quadraticBezierTo(150, 262, 220, 252);
  }

  void _drawSeed(Canvas c) {
    final mound = Path()
      ..moveTo(110, 252)
      ..quadraticBezierTo(150, 222, 190, 252);
    _fillOffset(c, mound, CD.accentSoft, dx: 5, dy: -4);
    _strokePath(c, mound, width: 5);
    final seed = Path()..addOval(const Rect.fromLTWH(138, 196, 26, 32));
    _fillOffset(c, seed, pal.canopy, dx: 4, dy: -4);
    _strokePath(c, seed, width: 5);
  }

  void _drawSprout(Canvas c) {
    final stem = Path()
      ..moveTo(150, 250)
      ..lineTo(150, 192);
    _strokePath(c, stem, width: 7);
    _leaf(c, const Offset(150, 210), -1, 42);
    _leaf(c, const Offset(150, 196), 1, 50);
  }

  void _drawSapling(Canvas c) {
    final trunk = Path()
      ..moveTo(150, 250)
      ..cubicTo(151, 220, 145, 185, 147, 150);
    _strokePath(c, trunk, width: 8);
    _leaf(c, const Offset(148, 190), -1, 46);
    _leaf(c, const Offset(148, 168), 1, 52);
    final bud = _cloudPath(148, 132, 34, 26);
    _fillOffset(c, bud, pal.canopyInner, dx: 6, dy: -6);
    _strokePath(c, bud, width: 5);
  }

  void _drawTree(Canvas c, {required bool full}) {
    final trunk = Path()
      ..moveTo(150, 250)
      ..cubicTo(152, 215, 142, 165, 144, 128);
    _strokePath(c, trunk, width: 11);
    final b1 = Path()
      ..moveTo(146, 188)
      ..cubicTo(132, 176, 118, 166, 102, 162);
    _strokePath(c, b1, width: 7);
    final b2 = Path()
      ..moveTo(147, 170)
      ..cubicTo(163, 156, 180, 148, 196, 146);
    _strokePath(c, b2, width: 7);

    final canopy = _cloudPath(150, 96, 86, 56);
    _fillOffset(c, canopy, pal.canopy);
    _strokePath(c, canopy, width: 5.5);
    final inner = _cloudPath(158, 88, 44, 28);
    _fillOffset(c, inner, pal.canopyInner, dx: 6, dy: -6);

    for (final pt in const [Offset(116, 102), Offset(184, 76), Offset(150, 118)]) {
      c.drawCircle(pt, 3.5, Paint()..color = pal.accentDot);
    }

    if (full) _decorate(c);
  }

  /// 大樹結果裝飾，依品種：櫻花＝花瓣、茶樹＝白花點、橘子＝橘子果實
  void _decorate(Canvas c) {
    switch (species) {
      case TreeSpecies.sakura:
        for (final pt in const [Offset(104, 88), Offset(170, 60), Offset(196, 104)]) {
          _blossom(c, pt);
        }
        _petal(c, const Offset(232, 176), 0.4);
        _petal(c, const Offset(70, 196), -0.5);
      case TreeSpecies.tea:
        for (final pt in const [Offset(104, 88), Offset(170, 60), Offset(196, 104), Offset(138, 78)]) {
          _teaFlower(c, pt);
        }
      case TreeSpecies.orange:
        for (final pt in const [Offset(108, 96), Offset(176, 70), Offset(196, 110)]) {
          _orangeFruit(c, pt);
        }
    }
  }

  Path _cloudPath(double cx, double cy, double rx, double ry) {
    const bumps = 7;
    final pts = <Offset>[];
    for (var i = 0; i < bumps; i++) {
      final a = i / bumps * 2 * math.pi;
      final wob = i.isEven ? 1.0 : 0.82;
      pts.add(Offset(cx + math.cos(a) * rx * wob, cy + math.sin(a) * ry * wob));
    }
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 0; i < bumps; i++) {
      final cur = pts[i];
      final next = pts[(i + 1) % bumps];
      final mid = Offset((cur.dx + next.dx) / 2, (cur.dy + next.dy) / 2);
      final dx = next.dx - cur.dx, dy = next.dy - cur.dy;
      final ctrl = Offset(mid.dx + dy * 0.22, mid.dy - dx * 0.22);
      p.quadraticBezierTo(ctrl.dx, ctrl.dy, next.dx, next.dy);
    }
    return p..close();
  }

  void _leaf(Canvas c, Offset from, double dir, double len) {
    final tip = Offset(from.dx + dir * len, from.dy - len * 0.62);
    final p = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(from.dx + dir * len * 0.15, from.dy - len * 0.72, tip.dx, tip.dy)
      ..quadraticBezierTo(from.dx + dir * len * 0.78, from.dy - len * 0.05, from.dx, from.dy)
      ..close();
    c.save();
    c.translate(4 * dir, -4);
    c.drawPath(p, Paint()..color = CD.success.withValues(alpha: 0.85));
    c.restore();
    c.drawPath(p, _plumStroke..strokeWidth = 4.5);
  }

  void _blossom(Canvas c, Offset center) {
    final petalStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = CD.plum
      ..strokeWidth = 2.4;
    for (var i = 0; i < 5; i++) {
      final a = i / 5 * 2 * math.pi - math.pi / 2;
      final o = Offset(center.dx + math.cos(a) * 6, center.dy + math.sin(a) * 6);
      c.drawCircle(o, 4.6, Paint()..color = CD.cream);
      c.drawCircle(o, 4.6, petalStroke);
    }
    c.drawCircle(center, 2.4, Paint()..color = CD.lemon);
  }

  /// 茶樹小白花（五瓣，黃蕊，較櫻花小巧）
  void _teaFlower(Canvas c, Offset center) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = CD.plum
      ..strokeWidth = 2;
    for (var i = 0; i < 5; i++) {
      final a = i / 5 * 2 * math.pi - math.pi / 2;
      final o = Offset(center.dx + math.cos(a) * 4.4, center.dy + math.sin(a) * 4.4);
      c.drawCircle(o, 3.4, Paint()..color = CD.cream);
      c.drawCircle(o, 3.4, stroke);
    }
    c.drawCircle(center, 2, Paint()..color = CD.caution);
  }

  /// 橘子果實（橘圓 + 描邊 + 高光）
  void _orangeFruit(Canvas c, Offset center) {
    c.drawCircle(center, 8, Paint()..color = pal.fruit);
    c.drawCircle(
        center,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = CD.plum
          ..strokeWidth = 2.6);
    c.drawCircle(center.translate(-2.4, -2.6), 2, Paint()..color = CD.cream.withValues(alpha: 0.7));
  }

  void _petal(Canvas c, Offset center, double rotation) {
    final p = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(11, -2, 9, 9)
      ..quadraticBezierTo(-2, 11, 0, 0);
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(rotation);
    c.drawPath(p, Paint()..color = pal.canopy);
    c.restore();
  }

  void _sparkle(Canvas c, Offset center, double r) {
    final p = Path();
    for (var i = 0; i < 4; i++) {
      final a = i / 4 * math.pi;
      final ca = math.cos(a), sa = math.sin(a);
      p.moveTo(center.dx + ca * r * 0.45, center.dy + sa * r * 0.45);
      p.lineTo(center.dx + ca * r, center.dy + sa * r);
      p.moveTo(center.dx - ca * r * 0.45, center.dy - sa * r * 0.45);
      p.lineTo(center.dx - ca * r, center.dy - sa * r);
    }
    c.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = CD.accent
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.6);
  }

  @override
  bool shouldRepaint(_TreePainter old) => old.stage != stage || old.species != species;
}
