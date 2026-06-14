import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onClose;
  const SettingsScreen({super.key, required this.onClose});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool medReminder = true;
  bool sitReminder = true;
  bool hapticsOn = true;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      children: [
        FlowTopBar(title: '設定', onClose: widget.onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              SectionHeader(title: '提醒（App 內）'),
              const SizedBox(height: 10),
              CDCard(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    _toggle(p, Icons.medication_outlined, '用藥時間輕震提醒', medReminder, (v) => setState(() => medReminder = v)),
                    _divider(p),
                    _toggle(p, Icons.directions_walk, '久坐提醒（等候時）', sitReminder, (v) => setState(() => sitReminder = v)),
                    _divider(p),
                    _toggle(p, Icons.vibration, '震動回饋', hapticsOn, (v) => setState(() => hapticsOn = v)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SectionHeader(title: '帳號'),
              const SizedBox(height: 10),
              CDCard(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    _nav(p, Icons.person_outline, 'ionachen@gamania.com'),
                    _divider(p),
                    _nav(p, Icons.credit_card, '方案：免費（剩 1 次照護時段）'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SectionHeader(title: '關於'),
              const SizedBox(height: 10),
              CDCard(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    _nav(p, Icons.lock_outline, '隱私政策'),
                    _divider(p),
                    _nav(p, Icons.article_outlined, '使用者同意書'),
                    _divider(p),
                    _nav(p, Icons.info_outline, 'Carrius v0.1 POC'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text('醫療資料只存在你的手機。伺服器只知道你的 email 和付費狀態。',
                  textAlign: TextAlign.center, style: CDText.body(11.5, weight: FontWeight.w500, color: p.text3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(Palette p) => Divider(height: 1, color: p.cardBorder);

  Widget _toggle(Palette p, IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 26, child: Icon(icon, size: 15, color: CD.accent)),
          const SizedBox(width: 11),
          Text(label, style: CDText.body(13.5, weight: FontWeight.w700, color: p.text)),
          const Spacer(),
          Switch(value: value, onChanged: onChanged, activeTrackColor: CD.accent, activeThumbColor: CD.cream),
        ],
      ),
    );
  }

  Widget _nav(Palette p, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 26, child: Icon(icon, size: 15, color: p.text2)),
          const SizedBox(width: 11),
          Text(label, style: CDText.body(13.5, weight: FontWeight.w700, color: p.text)),
          const Spacer(),
          Icon(Icons.chevron_right, size: 16, color: p.text3),
        ],
      ),
    );
  }
}
