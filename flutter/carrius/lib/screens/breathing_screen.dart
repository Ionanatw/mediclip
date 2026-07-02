import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/backgrounds.dart';

/// 478 呼吸練習 — 純觀看＋震動節奏（B 風格光暈背景）。
/// 吸氣 4 秒（圓放大＋震動漸強）→ 屏息 7 秒（心跳輕點）→ 吐氣 8 秒（圓縮小＋震動漸弱）
class BreathingScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const BreathingScreen({super.key, required this.onClose, this.onComplete});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

enum _Phase { ready, inhale, hold, exhale, done }

extension on _Phase {
  String get label => switch (this) {
        _Phase.ready => '準備',
        _Phase.inhale => '吸氣',
        _Phase.hold => '屏息',
        _Phase.exhale => '吐氣',
        _Phase.done => '完成',
      };
  double get seconds => switch (this) {
        _Phase.inhale => 4,
        _Phase.hold => 7,
        _Phase.exhale => 8,
        _ => 0,
      };
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  static const _totalRounds = 3;
  _Phase _phase = _Phase.ready;
  int _round = 0;
  int _countdown = 0;
  Timer? _timer;
  late final AnimationController _orb = AnimationController(vsync: this, duration: const Duration(seconds: 4), lowerBound: 0.55, upperBound: 1.0)..value = 0.55;

  @override
  void dispose() {
    _timer?.cancel();
    _orb.dispose();
    Haptics.stopBreathing();
    super.dispose();
  }

  void _startRound() {
    Haptics.light();
    _runPhase(_Phase.inhale);
  }

  void _runPhase(_Phase phase) {
    setState(() {
      _phase = phase;
      _countdown = phase.seconds.round();
    });
    switch (phase) {
      case _Phase.inhale:
        Haptics.breatheIn(phase.seconds);
        _orb.duration = Duration(seconds: phase.seconds.round());
        _orb.forward();
      case _Phase.hold:
        Haptics.breatheHold(phase.seconds);
      case _Phase.exhale:
        Haptics.breatheOut(phase.seconds);
        _orb.duration = Duration(seconds: phase.seconds.round());
        _orb.reverse();
      default:
        break;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    switch (_phase) {
      case _Phase.inhale:
        _runPhase(_Phase.hold);
      case _Phase.hold:
        _runPhase(_Phase.exhale);
      case _Phase.exhale:
        _round++;
        if (_round >= _totalRounds) {
          setState(() => _phase = _Phase.done);
          Haptics.success();
        } else {
          _runPhase(_Phase.inhale);
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const BreathBackground(),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        widget.onClose();
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, size: 18, color: CD.cream),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('478 呼吸法 · 第 ${(_round + 1).clamp(1, _totalRounds)} / $_totalRounds 輪',
                        style: CDText.body(13, weight: FontWeight.w900, color: CD.cream.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              const Spacer(),
              // 超大倒數數字在上（不疊圓）；階段字固定在呼吸圓中心
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 144,
                    child: (_phase != _Phase.ready && _phase != _Phase.done)
                        ? Text('$_countdown',
                            style: CDText.display(132, color: CD.plumDeep),
                            strutStyle: const StrutStyle(height: 1.05, forceStrutHeight: true))
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _orb,
                    builder: (context, _) {
                      return SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _orb.value * 1.18,
                              child: Container(width: 244, height: 244, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle)),
                            ),
                            Transform.scale(
                              scale: _orb.value,
                              child: Container(
                                width: 214,
                                height: 214,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    const Color(0xFFFFE9F2).withValues(alpha: 0.95),
                                    const Color(0xFFFFC9DF).withValues(alpha: 0.55),
                                  ]),
                                ),
                              ),
                            ),
                            // 階段字固定在圓心，不隨呼吸縮放
                            Text(_phase.label, style: CDText.display(34, color: CD.plumDeep)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40),
                child: _bottom(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottom() {
    if (_phase == _Phase.ready) {
      return Column(
        children: [
          Text('找個舒服的姿勢，手機放手心\n震動會帶著你呼吸，可以閉上眼睛',
              textAlign: TextAlign.center, style: CDText.body(14, weight: FontWeight.w500, color: CD.cream.withValues(alpha: 0.9), height: 1.4)),
          const SizedBox(height: 14),
          PillButton(title: '開始', style: PillStyle.lemon, onTap: _startRound),
        ],
      );
    }
    if (_phase == _Phase.done) {
      return Column(
        children: [
          Text('做得很好，把這份平靜帶回去', style: CDText.body(14, weight: FontWeight.w500, color: CD.cream.withValues(alpha: 0.9))),
          const SizedBox(height: 14),
          PillButton(
            title: '收下 +2 陽光',
            style: PillStyle.lemon,
            onTap: () {
              widget.onComplete?.call();
              widget.onClose();
            },
          ),
        ],
      );
    }
    return Text('跟著震動的節奏就好',
        textAlign: TextAlign.center, style: CDText.body(13, weight: FontWeight.w500, color: CD.cream.withValues(alpha: 0.7)));
  }
}
