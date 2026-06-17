import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Web 震動視覺提示（dev / POC 用）。
/// Web 平台沒有實體震動（HapticFeedback 在 web 是 no-op），
/// 因此每次觸發震動時，於 web 用一個短暫小標籤閃示「此刻是哪一種震動」，
/// 方便在 web demo 上驗證「震動時機」。真機（iOS/Android）走實體
/// Taptic / VibrationEffect，不顯示此提示（kIsWeb 守門）。
class HapticDebug {
  HapticDebug._();
  static final ValueNotifier<int> tick = ValueNotifier<int>(0);
  static String label = '';
  static void pulse(String l) {
    if (!kIsWeb) return;
    label = l;
    tick.value++;
  }
}

/// 震動回饋。對應 SwiftUI Haptics.swift 的三類設計：
/// 1. 節奏引導（呼吸）2. 拉回注意力 3. 回饋確認。
/// Flutter 標準 HapticFeedback 在 iOS 走 Taptic Engine、Android 走 VibrationEffect。
/// 呼吸的連續漸強曲線在 Android 受馬達硬體限制，故以「視覺主導＋節點震動」呈現。
class Haptics {
  static void light() {
    HapticFeedback.lightImpact();
    HapticDebug.pulse('輕擊');
  }

  static void soft() {
    HapticFeedback.selectionClick();
    HapticDebug.pulse('選取');
  }

  static void success() {
    HapticFeedback.mediumImpact();
    HapticDebug.pulse('完成');
  }

  static void warning() {
    HapticFeedback.heavyImpact();
    HapticDebug.pulse('警告');
  }

  static void selectionTick() {
    HapticFeedback.selectionClick();
    HapticDebug.pulse('選取');
  }

  /// 樹升級：漸強三連震
  static Future<void> levelUp() async {
    for (var i = 0; i < 3; i++) {
      HapticFeedback.mediumImpact();
      HapticDebug.pulse('升級 ${i + 1}/3');
      await Future.delayed(const Duration(milliseconds: 180));
    }
  }

  /// 拉回注意力：兩短一長
  static Future<void> attention() async {
    HapticFeedback.mediumImpact();
    HapticDebug.pulse('提醒');
    await Future.delayed(const Duration(milliseconds: 220));
    HapticFeedback.mediumImpact();
    HapticDebug.pulse('提醒');
    await Future.delayed(const Duration(milliseconds: 280));
    HapticFeedback.heavyImpact();
    HapticDebug.pulse('提醒（強）');
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
        HapticDebug.pulse('屏息');
      } else {
        final progress = down ? (total - t) / total : (t + 1) / total;
        if (progress > 0.66) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        HapticDebug.pulse(down ? '吐氣' : '吸氣');
      }
      t++;
    });
  }

  static void stopBreathing() {
    _breathTimer?.cancel();
    _breathTimer = null;
  }
}
