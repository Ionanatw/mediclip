import 'package:flutter/material.dart';

/// Phantom 設計 tokens（取自 phantom.com production CSS）。淺色為先。
/// 對應 SwiftUI 版 Tokens.swift，雙平台共用同一組數值。
class CD {
  // ---- 品牌（深淺共用） ----
  static const accent = Color(0xFFAB9FF2); // 薰衣草紫
  static const accentSoft = Color(0xFFE2DFFE);
  static const plum = Color(0xFF3C315B);
  static const plumDeep = Color(0xFF2C2250);
  static const lemon = Color(0xFFF1FF52);
  static const cream = Color(0xFFFFFDF8);

  // ---- 機能色 ----
  static const success = Color(0xFF45E863);
  static const danger = Color(0xFFFF0037);
  static const caution = Color(0xFFFFD600);
  static const info = Color(0xFF6CA0FB);

  // ---- 插畫粉色系 ----
  static const pink = Color(0xFFFFB7D5);
  static const pinkLight = Color(0xFFFFD9E8);
  static const pinkHot = Color(0xFFFF7EB0);

  // ---- 圓角 ----
  static const double rCard = 18;
  static const double rCardLarge = 24;
  static const double rRow = 14;
  static const double rIcon = 11;

  // ---- 動效（Phantom cubic-bezier(.22,1,.36,1)） ----
  static const ease = Cubic(0.22, 1, 0.36, 1);
  static const easeDur = Duration(milliseconds: 400);
  static const easeSlowDur = Duration(milliseconds: 700);

  // ---- 字體 ----
  static const display = 'Nunito';   // 圓潤標題（取代 SF Pro Rounded）
  static const body = 'NotoSansTC';  // 中文內文
}

/// 深淺色語意色票。預設淺色。
class Palette {
  final Color bg, surface, surface2, surface3;
  final Color text, text2, text3;
  final Color cardBorder;
  final Color tabbar;
  final Brightness brightness;

  const Palette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.text,
    required this.text2,
    required this.text3,
    required this.cardBorder,
    required this.tabbar,
    required this.brightness,
  });

  static const light = Palette(
    bg: Color(0xFFFFFDF8),
    surface: Color(0xFFFDFCFE),
    surface2: Color(0xFFF4F2F4),
    surface3: Color(0xFFEDEDEF),
    text: Color(0xFF3C315B),
    text2: Color(0xFF86848D),
    text3: Color(0xFFA09FA6),
    cardBorder: Color(0x143C315B), // plum 8%
    tabbar: Color(0xE0FDFCFE),
    brightness: Brightness.light,
  );

  static const dark = Palette(
    bg: Color(0xFF1C1C1C),
    surface: Color(0xFF28282C),
    surface2: Color(0xFF34343A),
    surface3: Color(0xFF2E2E32),
    text: Color(0xFFFFFDF8),
    text2: Color(0xFFA09FA6),
    text3: Color(0xFF86848D),
    cardBorder: Color(0x12FFFDF8), // cream 7%
    tabbar: Color(0xDB28282C),
    brightness: Brightness.dark,
  );
}

/// 讓 widget 取用目前色票。
class PaletteScope extends InheritedWidget {
  final Palette palette;
  const PaletteScope({super.key, required this.palette, required super.child});

  static Palette of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PaletteScope>();
    return scope?.palette ?? Palette.light;
  }

  @override
  bool updateShouldNotify(PaletteScope oldWidget) => oldWidget.palette != palette;
}

/// 字型工具（對應 SwiftUI .cdDisplay/.cdTitle/.cdBody）
class CDText {
  static TextStyle display(double size, {Color? color}) => TextStyle(
        fontFamily: CD.display,
        fontWeight: FontWeight.w900,
        fontSize: size,
        height: 1.15,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle title(double size, {Color? color}) => TextStyle(
        fontFamily: CD.display,
        fontWeight: FontWeight.w800,
        fontSize: size,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color? color, double? height}) =>
      TextStyle(
        fontFamily: CD.body,
        fontWeight: weight,
        fontSize: size,
        height: height,
        color: color,
      );
}
