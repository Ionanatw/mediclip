import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/haptics.dart';

class ProcessingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const ProcessingScreen({super.key, required this.onDone});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  static const _steps = ['辨識文件內容', '結構化整理', '比對藥品資料庫', '產出照護懶人包'];
  int _step = 0;
  Timer? _timer;
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _advance();
  }

  void _advance() {
    _timer = Timer(const Duration(milliseconds: 900), () {
      Haptics.selectionTick();
      if (_step >= _steps.length - 1) {
        Haptics.attention();
        widget.onDone();
      } else {
        setState(() => _step++);
        _advance();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Spacer(),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final s = 0.94 + _pulse.value * 0.18;
              return SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(scale: s, child: _circle(150, CD.accent.withValues(alpha: 0.14))),
                    Transform.scale(scale: 0.96 + _pulse.value * 0.1, child: _circle(110, CD.accent.withValues(alpha: 0.2))),
                    const Icon(Icons.auto_awesome, size: 40, color: CD.accent),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 26),
          Text('AI 整理中', style: CDText.display(22, color: p.text)),
          const SizedBox(height: 26),
          for (var i = 0; i < _steps.length; i++) ...[
            Row(
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: i < _step
                      ? _doneCheck()
                      : i == _step
                          ? const Padding(padding: EdgeInsets.all(4), child: CircularProgressIndicator(strokeWidth: 2.4, color: CD.accent))
                          : DecoratedBox(decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 10),
                Text(_steps[i],
                    style: CDText.body(14, weight: i == _step ? FontWeight.w900 : FontWeight.w500, color: i <= _step ? p.text : p.text3)),
              ],
            ),
            const SizedBox(height: 13),
          ],
          const Spacer(),
          Text('照片只在這台手機與 AI 處理過程中存在，處理完即刪除',
              textAlign: TextAlign.center, style: CDText.body(11, weight: FontWeight.w500, color: p.text3)),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _circle(double d, Color c) => Container(width: d, height: d, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _doneCheck() => Container(
        decoration: BoxDecoration(color: CD.success.withValues(alpha: 0.16), shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 14, color: CD.success),
      );
}
