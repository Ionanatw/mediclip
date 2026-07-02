import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../models/mock_data.dart';

/// 跟家人說說話 — 暖暖小卡直送：不知道說什麼，卡片替你開口。
/// 3 句備選（長輩早安圖的溫暖語感）＋自己寫一句，複製去傳，
/// 回來按「我傳出去了」領陽光（誠實制，不驗證）。
class FamilyTalkScreen extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onComplete;
  const FamilyTalkScreen({super.key, required this.onClose, this.onComplete});

  @override
  State<FamilyTalkScreen> createState() => _FamilyTalkScreenState();
}

const _pinkD = Color(0xFFA34067);

class _FamilyTalkScreenState extends State<FamilyTalkScreen> {
  final _custom = TextEditingController();
  int _selected = 0; // 0..2 備選；3 = 自己寫
  bool _copied = false;

  bool get _isCustom => _selected == 3;
  String get _text => _isCustom ? _custom.text.trim() : MockData.familyCardTexts[_selected];

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _copy() {
    if (_text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('先寫一句想說的話')));
      return;
    }
    Clipboard.setData(ClipboardData(text: _text));
    Haptics.light();
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已複製，貼到訊息傳給他吧')));
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Stack(fit: StackFit.expand, children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF4F8), Color(0xFFF9E3EC), Color(0xFFF4D5E3)],
            stops: [0, 0.55, 1],
          ),
        ),
      ),
      SafeArea(
        child: Column(
          children: [
            FlowTopBar(title: '跟家人說說話', onClose: widget.onClose),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                children: [
                  Text('不知道說什麼？卡片替你開口',
                      style: CDText.body(12.5, weight: FontWeight.w700, color: _pinkD.withValues(alpha: 0.8))),
                  const SizedBox(height: 10),
                  // 小卡預覽
                  Container(
                    height: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFC75E8A), Color(0xFF8E7EE8)]),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: const Color(0xFF8E7EE8).withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 10))],
                    ),
                    child: Center(
                      child: Text(
                        _text.isEmpty ? '寫下你想說的話…' : _text,
                        textAlign: TextAlign.center,
                        style: CDText.display(16, color: CD.cream.withValues(alpha: _text.isEmpty ? 0.55 : 1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < MockData.familyCardTexts.length; i++) ...[
                    _option(i, MockData.familyCardTexts[i]),
                    const SizedBox(height: 8),
                  ],
                  // 自己寫一句
                  GestureDetector(
                    onTap: () => setState(() => _selected = 3),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: _optionBox(_isCustom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('自己寫一句', style: CDText.body(11, weight: FontWeight.w800, color: _pinkD.withValues(alpha: 0.65))),
                          TextField(
                            controller: _custom,
                            maxLines: 2,
                            minLines: 1,
                            onTap: () => setState(() => _selected = 3),
                            onChanged: (_) => setState(() => _selected = 3),
                            style: CDText.body(14, color: p.text),
                            decoration: InputDecoration.collapsed(
                                hintText: '例如：週末回去看你，想吃什麼？', hintStyle: CDText.body(14, color: p.text3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!_copied)
                    PillButton(title: '複製這段話', icon: Icons.copy_rounded, style: PillStyle.lemon, onTap: _copy)
                  else ...[
                    PillButton(
                      title: '我傳出去了 · 收下 +2 陽光',
                      icon: Icons.favorite_border,
                      style: PillStyle.lemon,
                      onTap: () {
                        widget.onComplete?.call();
                        widget.onClose();
                      },
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text('貼到 LINE 或訊息，傳出去再回來',
                          style: CDText.body(12, weight: FontWeight.w600, color: _pinkD.withValues(alpha: 0.7))),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  BoxDecoration _optionBox(bool selected) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: selected ? 0.95 : 0.6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: selected ? const Color(0xFFC75E8A) : Colors.transparent, width: 2),
    );
  }

  Widget _option(int i, String text) {
    final selected = _selected == i;
    return GestureDetector(
      onTap: () {
        Haptics.soft();
        setState(() => _selected = i);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: _optionBox(selected),
        child: Row(
          children: [
            Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                size: 18, color: selected ? const Color(0xFFC75E8A) : _pinkD.withValues(alpha: 0.35)),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: CDText.body(13.5, weight: FontWeight.w600, color: const Color(0xFF5B3A49)))),
          ],
        ),
      ),
    );
  }
}
