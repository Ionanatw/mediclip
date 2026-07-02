import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';

/// 寫個小目標 — 輸入式（同感恩卡）：寫下今天想完成的一件小事，存檔 +2☀。
class GoalScreen extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const GoalScreen({super.key, required this.onClose, this.onComplete});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      children: [
        FlowTopBar(title: '寫個小目標', onClose: onClose),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const PageHeader(kicker: '今天想完成的一件小事', title: '寫下一個小目標'),
                const SizedBox(height: 14),
                CDCard(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    maxLines: 4,
                    style: CDText.body(15, color: p.text),
                    decoration: InputDecoration.collapsed(
                      hintText: '例如：中午到陽台坐 10 分鐘',
                      hintStyle: CDText.body(15, color: p.text3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                PillButton(
                  title: '存下來 · +2 陽光',
                  icon: Icons.flag_outlined,
                  style: PillStyle.lemon,
                  onTap: () {
                    Haptics.light();
                    onComplete?.call();
                    onClose();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
