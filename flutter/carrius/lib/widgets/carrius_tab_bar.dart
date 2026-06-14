import 'dart:ui';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/haptics.dart';
import '../state/app_state.dart';

/// 懸浮膠囊 Tab Bar：首頁／行事曆／中央上傳圓鈕／文件／花園（小樹苗）
class CarriusTabBar extends StatelessWidget {
  final AppState state;
  final VoidCallback onUpload;
  const CarriusTabBar({super.key, required this.state, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: p.tabbar,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.cardBorder, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                _item(p, AppTab.home, Icons.home_outlined, '首頁'),
                const Spacer(),
                _item(p, AppTab.calendar, Icons.calendar_today_outlined, '行事曆'),
                const Spacer(),
                _centerButton(),
                const Spacer(),
                _item(p, AppTab.documents, Icons.description_outlined, '文件'),
                const Spacer(),
                _gardenItem(p),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(Palette p, AppTab tab, IconData icon, String label) {
    final on = state.tab == tab;
    return GestureDetector(
      onTap: () => state.setTab(tab),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: on ? CD.accent : p.text3),
            const SizedBox(height: 3),
            Text(label, style: CDText.body(9.5, weight: FontWeight.w900, color: on ? CD.accent : p.text3)),
            const SizedBox(height: 2),
            Container(width: 14, height: 3, decoration: BoxDecoration(color: on ? CD.accent : Colors.transparent, borderRadius: BorderRadius.circular(999))),
          ],
        ),
      ),
    );
  }

  Widget _gardenItem(Palette p) {
    final on = state.tab == AppTab.garden;
    final color = on ? CD.accent : p.text3;
    return GestureDetector(
      onTap: () => state.setTab(AppTab.garden),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 21, height: 21, child: CustomPaint(painter: _SproutIconPainter(color))),
            const SizedBox(height: 3),
            Text('花園', style: CDText.body(9.5, weight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Container(width: 14, height: 3, decoration: BoxDecoration(color: on ? CD.accent : Colors.transparent, borderRadius: BorderRadius.circular(999))),
          ],
        ),
      ),
    );
  }

  Widget _centerButton() {
    return GestureDetector(
      onTap: () {
        Haptics.light();
        onUpload();
      },
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: CD.accent,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: CD.accent.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, size: 22, color: CD.plumDeep),
        ),
      ),
    );
  }
}

/// 小樹苗 icon：莖＋左右兩葉＋地面線
class _SproutIconPainter extends CustomPainter {
  final Color color;
  _SproutIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // 莖
    canvas.drawLine(Offset(w * 0.5, h * 0.88), Offset(w * 0.5, h * 0.52), paint);
    // 左葉
    final left = Path()
      ..moveTo(w * 0.5, h * 0.58)
      ..cubicTo(w * 0.5, h * 0.40, w * 0.37, h * 0.27, w * 0.19, h * 0.27)
      ..cubicTo(w * 0.19, h * 0.45, w * 0.32, h * 0.58, w * 0.5, h * 0.58);
    canvas.drawPath(left, paint);
    // 右葉
    final right = Path()
      ..moveTo(w * 0.5, h * 0.48)
      ..cubicTo(w * 0.5, h * 0.30, w * 0.64, h * 0.18, w * 0.83, h * 0.18)
      ..cubicTo(w * 0.83, h * 0.36, w * 0.68, h * 0.48, w * 0.5, h * 0.48);
    canvas.drawPath(right, paint);
    // 地面
    canvas.drawLine(Offset(w * 0.30, h * 0.88), Offset(w * 0.70, h * 0.88), paint);
  }

  @override
  bool shouldRepaint(_SproutIconPainter old) => old.color != color;
}
