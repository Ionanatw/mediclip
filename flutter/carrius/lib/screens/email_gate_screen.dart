import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// Email 註冊頁 + 身分單選（患者／照護者／其他）
class EmailGateScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onContinue;
  const EmailGateScreen({super.key, required this.state, required this.onContinue});

  @override
  State<EmailGateScreen> createState() => _EmailGateScreenState();
}

class _EmailGateScreenState extends State<EmailGateScreen> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.state.email);

  // 測試略過：輸入 11111 即可繼續（免真 email），其餘需含 @
  bool get _canContinue =>
      widget.state.role != null && (_ctrl.text.contains('@') || _ctrl.text.trim() == '11111');

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          PageHeader(kicker: '先讓我認識你', title: '你是？'),
          const SizedBox(height: 6),
          Text('我們會依你的身分調整提醒與用字。這個選擇不會上傳，只存在你的手機。',
              style: CDText.body(13, weight: FontWeight.w500, color: p.text2, height: 1.5)),
          const SizedBox(height: 20),
          for (final role in UserRole.values) ...[
            _roleOption(p, role),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          Text('Email', style: CDText.body(12, weight: FontWeight.w700, color: p.text3)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(CD.rCard),
              border: Border.all(color: p.cardBorder, width: 1),
            ),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => setState(() => widget.state.email = v),
              keyboardType: TextInputType.emailAddress,
              style: CDText.body(15, color: p.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'you@example.com',
                hintStyle: CDText.body(15, color: p.text3),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('同一 email 在試玩版限體驗 1 次 AI 整理',
              style: CDText.body(11, weight: FontWeight.w500, color: p.text3)),
          const Spacer(),
          PillButton(
            title: '繼續',
            style: PillStyle.lemon,
            dimmed: !_canContinue,
            onTap: () {
              if (!_canContinue) {
                Haptics.warning();
                return;
              }
              widget.onContinue();
            },
          ),
        ],
      ),
    );
  }

  Widget _roleOption(Palette p, UserRole role) {
    final selected = widget.state.role == role;
    return GestureDetector(
      onTap: () {
        Haptics.selectionTick();
        setState(() => widget.state.role = role);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? CD.accent : p.surface,
          borderRadius: BorderRadius.circular(CD.rCard),
          border: Border.all(color: selected ? CD.accent : p.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            Text(role.label, style: CDText.title(15, color: selected ? CD.plumDeep : p.text)),
            const Spacer(),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: selected ? CD.plumDeep : p.text3,
            ),
          ],
        ),
      ),
    );
  }
}
