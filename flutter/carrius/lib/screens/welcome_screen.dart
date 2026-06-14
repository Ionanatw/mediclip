import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/illustrations/sakura_tree.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  const WelcomeScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(),
          const SizedBox(width: 240, height: 220, child: SakuraTree(stage: TreeStage.bloom)),
          const SizedBox(height: 18),
          Text('Carrius', style: CDText.display(38, color: p.text)),
          const SizedBox(height: 10),
          Text('拍照上傳醫療單\nAI 幫你秒懂、秒整理、秒提醒',
              textAlign: TextAlign.center, style: CDText.body(16, weight: FontWeight.w500, color: p.text2, height: 1.5)),
          const Spacer(),
          PillButton(title: '開始使用', style: PillStyle.lemon, onTap: onStart),
          const SizedBox(height: 14),
          Text('醫療資料只存在你的手機，伺服器不碰、不存、不看',
              textAlign: TextAlign.center, style: CDText.body(11.5, weight: FontWeight.w500, color: p.text3)),
          const SizedBox(height: 44),
        ],
      ),
    );
  }
}
