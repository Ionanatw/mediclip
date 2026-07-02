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

/// 樹種美術配色（抽象色塊風）。2026-06-19 定案：色塊堆疊、去描邊、Phantom 色。
/// 新增品種 = 加一筆 enum + 一組 TreePalette（JSON-config 精神）。
class TreePalette {
  /// canopy=最深色塊底、mid/light/inner 由深到淺、accent=lavender 點綴色塊、
  /// accentDot=亮點色、trunk=樹幹、fruit=結果（橘子用）。
  final Color canopy, canopyMid, canopyLight, canopyInner, accent, accentDot, trunk, fruit;
  const TreePalette({
    required this.canopy,
    required this.canopyMid,
    required this.canopyLight,
    required this.canopyInner,
    required this.accent,
    required this.accentDot,
    this.trunk = const Color(0xFF7A5C4F),
    this.fruit = const Color(0x00000000),
  });

  static const sakura = TreePalette(
    canopy: Color(0xFFFFB7D5),
    canopyMid: Color(0xFFFFCBE0),
    canopyLight: Color(0xFFFFDDEA),
    canopyInner: Color(0xFFFFF0F5),
    accent: Color(0xFFEBE3FB),
    accentDot: Color(0xFFFF7EB0),
  );
  static const tea = TreePalette(
    canopy: Color(0xFF8FD3A6),
    canopyMid: Color(0xFFA9DEBC),
    canopyLight: Color(0xFFCBEBD6),
    canopyInner: Color(0xFFECF8F0),
    accent: Color(0xFFDDEFE4),
    accentDot: Color(0xFFFFFFFF),
  );
  static const orange = TreePalette(
    canopy: Color(0xFF8ACB97),
    canopyMid: Color(0xFFA6D8AE),
    canopyLight: Color(0xFFC9E8CC),
    canopyInner: Color(0xFFEAF6EA),
    accent: Color(0xFFE2DFFE),
    accentDot: Color(0xFFFFFFFF),
    fruit: Color(0xFFFF9D42),
  );

  static TreePalette of(TreeSpecies s) => switch (s) {
        TreeSpecies.sakura => sakura,
        TreeSpecies.tea => tea,
        TreeSpecies.orange => orange,
      };
}

/// 養成樹（抽象色塊風）。依品種換配色與結果裝飾。
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

/// 色塊層次（由深到淺 + lavender accent）
enum _Layer { deep, mid, light, inner, accent }

class _TreePainter extends CustomPainter {
  final TreeSpecies species;
  final TreeStage stage;
  _TreePainter(this.species, this.stage);

  TreePalette get pal => TreePalette.of(species);

  static const double _design = 300;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    canvas.scale(s / _design);

    _shadow(canvas);

    switch (stage) {
      case TreeStage.seed:
        _drawSeed(canvas);
      case TreeStage.sprout:
        _drawSprout(canvas);
      case TreeStage.sapling:
        _drawSapling(canvas);
      case TreeStage.growing:
        _drawTree(canvas, full: false);
      case TreeStage.bloom:
        _drawTree(canvas, full: true);
    }
    canvas.restore();
  }

  // ---- 共用 ----
  void _fill(Canvas c, Path p, Color color) => c.drawPath(p, Paint()..color = color);

  void _blob(Canvas c, double cx, double cy, double rx, double ry, Color color) =>
      _fill(c, _cloudPath(cx, cy, rx, ry), color);

  /// 地面柔影（lavender 低透明），給樹一點重量、不畫硬地線
  void _shadow(Canvas c) {
    final w = switch (stage) {
      TreeStage.seed => 34.0,
      TreeStage.sprout => 30.0,
      TreeStage.sapling => 46.0,
      TreeStage.growing => 64.0,
      TreeStage.bloom => 82.0,
    };
    c.drawOval(
      Rect.fromCenter(center: const Offset(150, 252), width: w, height: w * 0.26),
      Paint()..color = const Color(0xFFC7BDF6).withValues(alpha: 0.18),
    );
  }

  /// 樹幹色塊（有機錐形，無描邊）
  Path _trunkPath(double topY, double halfBase, {double halfTop = 6}) {
    return Path()
      ..moveTo(150 - halfBase, 250)
      ..cubicTo(150 - halfBase + 1, 250 - (250 - topY) * 0.45, 150 - halfTop - 2, topY + 12, 150 - halfTop, topY)
      ..lineTo(150 + halfTop, topY)
      ..cubicTo(150 + halfTop + 2, topY + 12, 150 + halfBase - 1, 250 - (250 - topY) * 0.45, 150 + halfBase, 250)
      ..close();
  }

  void _drawSeed(Canvas c) {
    _blob(c, 150, 246, 30, 12, pal.accent); // 土堆
    _blob(c, 150, 224, 15, 19, pal.canopy); // 飽滿種子莢
    _blob(c, 150, 220, 9, 12, pal.canopyLight);
    c.drawCircle(const Offset(150, 214), 2.6, Paint()..color = pal.accentDot);
  }

  void _drawSprout(Canvas c) {
    _fill(c, _trunkPath(212, 4, halfTop: 3), const Color(0xFF8FBF86)); // 嫩莖
    _blob(c, 132, 210, 18, 13, const Color(0xFF8FD3A6)); // 左葉
    _blob(c, 168, 206, 18, 13, const Color(0xFF8FD3A6)); // 右葉
    _blob(c, 134, 208, 10, 7, const Color(0xFFCBEBD6));
    _blob(c, 166, 204, 10, 7, const Color(0xFFCBEBD6));
  }

  void _drawSapling(Canvas c) {
    _fill(c, _trunkPath(186, 6, halfTop: 4), pal.trunk);
    // 迷你花冠雲（約大樹 1/4）
    _blob(c, 150, 176, 36, 28, pal.canopy);
    _blob(c, 132, 184, 16, 13, pal.accent);
    _blob(c, 160, 168, 26, 19, pal.canopyLight);
    _blob(c, 152, 174, 15, 11, pal.canopyInner);
    c.drawCircle(const Offset(150, 172), 2.4, Paint()..color = pal.accentDot);
  }

  void _drawTree(Canvas c, {required bool full}) {
    if (full) {
      _fill(c, _trunkPath(150, 11), pal.trunk);
      _canopy(c, const [
        (150.0, 112.0, 84.0, 58.0, _Layer.deep),
        (112.0, 140.0, 28.0, 24.0, _Layer.accent),
        (178.0, 100.0, 66.0, 48.0, _Layer.mid),
        (198.0, 128.0, 22.0, 18.0, _Layer.accent),
        (150.0, 84.0, 64.0, 44.0, _Layer.light),
        (152.0, 96.0, 40.0, 28.0, _Layer.inner),
      ]);
      _decorate(c, full: true);
    } else {
      _fill(c, _trunkPath(160, 9), pal.trunk);
      _canopy(c, const [
        (150.0, 150.0, 56.0, 42.0, _Layer.deep),
        (120.0, 158.0, 21.0, 18.0, _Layer.accent),
        (184.0, 156.0, 26.0, 22.0, _Layer.mid),
        (150.0, 134.0, 38.0, 26.0, _Layer.light),
        (150.0, 144.0, 22.0, 16.0, _Layer.inner),
      ]);
      _decorate(c, full: false);
      _sparkle(c, const Offset(64, 96), 9);
      _sparkle(c, const Offset(238, 120), 7);
    }
  }

  void _canopy(Canvas c, List<(double, double, double, double, _Layer)> blobs) {
    for (final b in blobs) {
      final color = switch (b.$5) {
        _Layer.deep => pal.canopy,
        _Layer.mid => pal.canopyMid,
        _Layer.light => pal.canopyLight,
        _Layer.inner => pal.canopyInner,
        _Layer.accent => pal.accent,
      };
      _blob(c, b.$1, b.$2, b.$3, b.$4, color);
    }
  }

  /// 亮點 / accent 點 / 結果 / 飄落花瓣（全色塊、無描邊）
  void _decorate(Canvas c, {required bool full}) {
    // 單一柔光（偏上、離中心），不畫左右對稱粉點＝不會被看成眼睛（無臉）
    final hl = full ? const Offset(132, 88) : const Offset(134, 130);
    c.drawCircle(hl, full ? 15 : 10, Paint()..color = pal.canopyInner.withValues(alpha: 0.5));
    if (species == TreeSpecies.orange) {
      final fruits = full
          ? const [Offset(120, 120), Offset(184, 96), Offset(196, 134)]
          : const [Offset(132, 150), Offset(172, 140)];
      for (final p in fruits) {
        c.drawCircle(p, full ? 8 : 6, Paint()..color = pal.fruit);
        c.drawCircle(p.translate(-2.2, -2.4), full ? 2 : 1.6, Paint()..color = CD.cream.withValues(alpha: 0.7));
      }
    }
    if (full) {
      _petal(c, const Offset(238, 178), 0.5);
      _petal(c, const Offset(74, 196), -0.6);
      _petal(c, const Offset(214, 214), 0.2);
    }
  }

  /// 飄落小瓣（色塊）
  void _petal(Canvas c, Offset center, double rotation) {
    final p = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(10, -2, 8, 9)
      ..quadraticBezierTo(-2, 11, 0, 0)
      ..close();
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(rotation);
    c.drawPath(p, Paint()..color = species == TreeSpecies.sakura ? pal.canopy : pal.canopyMid);
    c.restore();
  }

  /// 有機色塊（7 個起伏的閉合 blob）
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
        ..color = const Color(0xFFAB9FF2)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4,
    );
  }

  @override
  bool shouldRepaint(_TreePainter old) => old.stage != stage || old.species != species;
}
