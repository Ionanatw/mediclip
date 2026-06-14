import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../state/app_state.dart';

class FollowUpScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onClose;
  final VoidCallback onDone;
  const FollowUpScreen({super.key, required this.state, required this.onClose, required this.onDone});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  bool get _allAnswered => widget.state.followUps.every((q) => q.selected != null);

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      children: [
        FlowTopBar(title: 'AI 追問', onClose: widget.onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            children: [
              PageHeader(kicker: '差一步就好', title: '幫我確認 2 件事'),
              const SizedBox(height: 16),
              for (final q in widget.state.followUps) ...[
                CDCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.question, style: CDText.body(14, weight: FontWeight.w700, color: p.text, height: 1.4)),
                      const SizedBox(height: 11),
                      for (final option in q.options) ...[
                        GestureDetector(
                          onTap: () {
                            Haptics.selectionTick();
                            setState(() => q.selected = option);
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: q.selected == option ? CD.accent : p.surface2,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                Text(option, style: CDText.body(13.5, weight: FontWeight.w700, color: q.selected == option ? CD.plumDeep : p.text)),
                                const Spacer(),
                                if (q.selected == option) const Icon(Icons.check_circle, size: 18, color: CD.plumDeep),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              PillButton(
                title: '完成整理',
                icon: Icons.check,
                style: PillStyle.lemon,
                dimmed: !_allAnswered,
                onTap: () {
                  if (!_allAnswered) {
                    Haptics.warning();
                    return;
                  }
                  widget.onDone();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
