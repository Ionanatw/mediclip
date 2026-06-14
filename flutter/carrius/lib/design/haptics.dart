import 'dart:async';
import 'package:flutter/services.dart';

/// 震動回饋。對應 SwiftUI Haptics.swift 的三類設計：
/// 1. 節奏引導（呼吸）2. 拉回注意力 3. 回饋確認。
/// Flutter 標準 HapticFeedback 在 iOS 走 Taptic Engine、Android 走 VibrationEffect。
/// 呼吸的連續漸強曲線在 Android 受馬達硬體限制，故以「視覺主導＋節點震動」呈現。
class Haptics {
  static void light() => HapticFeedback.lightImpact();
  static void soft() => HapticFeedback.selectionClick();
  static void success() => HapticFeedback.mediumImpact();
  static void warning() => HapticFeedback.heavyImpact();
  static void selectionTick() => HapticFeedback.selectionClick();

  /// 樹升級：漸強三連震
  static Future<void> levelUp() async {
    for (var i = 0; i < 3; i++) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 180));
    }
  }

  /// 拉回注意力：兩短一長
  static Future<void> attention() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 220));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 280));
    HapticFeedback.heavyImpact();
  }

  // ---- 呼吸節奏（節點式，閉眼可跟）----
  static Timer? _breathTimer;

  /// 吸氣：每秒一個漸強節點
  static void breatheIn(double seconds) => _ticks(seconds, ramp: true);

  /// 屏息：每秒一個極輕心跳點
  static void breatheHold(double seconds) => _ticks(seconds, light: true);

  /// 吐氣：每秒一個漸弱節點
  static void breatheOut(double seconds) => _ticks(seconds, ramp: true, down: true);

  static void _ticks(double seconds, {bool ramp = false, bool light = false, bool down = false}) {
    stopBreathing();
    var t = 0;
    final total = seconds.round();
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (t >= total) {
        timer.cancel();
        return;
      }
      if (light) {
        HapticFeedback.selectionClick();
      } else {
        final progress = down ? (total - t) / total : (t + 1) / total;
        if (progress > 0.66) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      }
      t++;
    });
  }

  static void stopBreathing() {
    _breathTimer?.cancel();
    _breathTimer = null;
  }
}
