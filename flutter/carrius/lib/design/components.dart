import 'dart:ui';
import 'package:flutter/material.dart';
import 'tokens.dart';
import 'haptics.dart';

/// 卡片容器
class CDCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  const CDCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = CD.rCard,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.cardBorder, width: 1),
      ),
      child: child,
    );
  }
}

/// 膠囊按鈕
enum PillStyle { accent, lemon, ghost }

class PillButton extends StatefulWidget {
  final String title;
  final IconData? icon;
  final PillStyle style;
  final VoidCallback onTap;
  final bool dimmed;
  const PillButton({
    super.key,
    required this.title,
    this.icon,
    this.style = PillStyle.accent,
    required this.onTap,
    this.dimmed = false,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    Color bg;
    Color fg;
    switch (widget.style) {
      case PillStyle.accent:
        bg = CD.accent;
        fg = CD.plumDeep;
      case PillStyle.lemon:
        bg = CD.lemon;
        fg = CD.plumDeep;
      case PillStyle.ghost:
        bg = p.surface2;
        fg = p.text;
    }
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        Haptics.light();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: CD.easeDur,
        curve: CD.ease,
        child: Opacity(
          opacity: widget.dimmed ? 0.5 : 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(widget.title, style: CDText.title(15.5, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 標籤
class TagView extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;
  const TagView({super.key, required this.text, this.color = CD.accent, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: CDText.body(11, weight: FontWeight.w700, color: filled ? CD.plumDeep : color)),
    );
  }
}

/// 區塊標題
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTap;
  const SectionHeader({super.key, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(title, style: CDText.title(15, color: p.text)),
        const Spacer(),
        if (trailing != null)
          GestureDetector(
            onTap: () {
              Haptics.light();
              onTap?.call();
            },
            child: Text(trailing!, style: CDText.body(12, weight: FontWeight.w700, color: CD.accent)),
          ),
      ],
    );
  }
}

/// 列表項
class ListRowCard extends StatelessWidget {
  final Color iconBg;
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ListRowCard({
    super.key,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final row = Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(CD.rRow),
        border: Border.all(color: p.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(CD.rIcon)),
            child: Center(child: icon),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: CDText.title(13.5, color: p.text), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: CDText.body(11.5, weight: FontWeight.w500, color: p.text2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
    if (onTap == null) return row;
    return GestureDetector(
      onTap: () {
        Haptics.light();
        onTap!();
      },
      child: row,
    );
  }
}

/// 陽光進度條
class SunProgressBar extends StatelessWidget {
  final double value;
  const SunProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        color: p.surface3,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.02, 1),
          child: Container(color: CD.lemon),
        ),
      ),
    );
  }
}

/// 頁面標題
class PageHeader extends StatelessWidget {
  final String kicker;
  final String title;
  const PageHeader({super.key, required this.kicker, required this.title});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kicker, style: CDText.body(12, weight: FontWeight.w700, color: p.text2)),
        const SizedBox(height: 3),
        Text(title, style: CDText.display(24, color: p.text)),
      ],
    );
  }
}

/// 鎖定模糊遮罩（付費導流）。點 CTA 走 onTap（通常接 showComingSoon），不可只震動不做事。
class BlurLock extends StatelessWidget {
  final String cta;
  final Widget child;
  final VoidCallback? onTap;
  const BlurLock({super.key, required this.cta, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(CD.rCard),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Opacity(opacity: 0.7, child: child),
          ),
        ),
        GestureDetector(
          onTap: () {
            Haptics.light();
            onTap?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(color: CD.accent, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 11, color: CD.plumDeep),
                const SizedBox(width: 6),
                Text(cta, style: CDText.body(12, weight: FontWeight.w900, color: CD.plumDeep)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 免責聲明
class DisclaimerFooter extends StatelessWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text('此內容由 AI 輔助整理，請與原始醫療文件核對',
          textAlign: TextAlign.center, style: CDText.body(10.5, weight: FontWeight.w500, color: p.text3)),
    );
  }
}

/// 誠實「即將開放」提示（floating SnackBar，留出底部 TabBar 空間）。
/// 觸覺由呼叫端負責（PillButton/BlurLock/各 GestureDetector 自帶），這裡不重複觸發。
void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CD.plumDeep,
        elevation: 0,
        duration: const Duration(milliseconds: 2200),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 15, color: CD.cream),
            const SizedBox(width: 9),
            Flexible(
              child: Text('「$feature」即將在正式版開放',
                  style: CDText.body(12.5, weight: FontWeight.w700, color: CD.cream)),
            ),
          ],
        ),
      ),
    );
}

/// 底部資訊 sheet（隱私政策／同意書／方案／關於／文件詳情）
Future<void> showCDSheet(BuildContext context, {required String title, required Widget body}) {
  final p = PaletteScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final media = MediaQuery.of(ctx);
      return Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.82),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: p.surface3, borderRadius: BorderRadius.circular(999)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: CDText.title(16, color: p.text))),
                  GestureDetector(
                    key: const Key('cdSheetClose'),
                    onTap: () {
                      Haptics.light();
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 15, color: p.text2),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + media.padding.bottom),
                child: body,
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// sheet 內文：小節標題
class SheetHeading extends StatelessWidget {
  final String text;
  const SheetHeading(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(text, style: CDText.title(13.5, color: p.text)),
    );
  }
}

/// sheet 內文：段落
class SheetParagraph extends StatelessWidget {
  final String text;
  const SheetParagraph(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: CDText.body(13, weight: FontWeight.w500, color: p.text2, height: 1.5)),
    );
  }
}

/// sheet 內文：項目列（圓點）
class SheetBullet extends StatelessWidget {
  final String text;
  const SheetBullet(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 9),
            child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: CD.accent, shape: BoxShape.circle)),
          ),
          Expanded(child: Text(text, style: CDText.body(13, weight: FontWeight.w500, color: p.text2, height: 1.5))),
        ],
      ),
    );
  }
}

/// 流程頂欄（modal / sheet 用）
class FlowTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const FlowTopBar({super.key, required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          Text(title, style: CDText.title(16, color: p.text)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Haptics.light();
              onClose();
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
              child: Icon(Icons.close, size: 15, color: p.text2),
            ),
          ),
        ],
      ),
    );
  }
}
