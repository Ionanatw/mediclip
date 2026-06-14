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

/// 鎖定模糊遮罩（付費導流）
class BlurLock extends StatelessWidget {
  final String cta;
  final Widget child;
  const BlurLock({super.key, required this.cta, required this.child});

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
          onTap: Haptics.soft,
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
