import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/sakura_tree.dart';
import '../design/illustrations/backgrounds.dart';
import '../models/models.dart';
import '../models/mock_data.dart';
import '../state/app_state.dart';

class GardenScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onBreathing;
  final VoidCallback onGratitude;
  final VoidCallback onMoodCard;
  const GardenScreen({
    super.key,
    required this.state,
    required this.onBreathing,
    required this.onGratitude,
    required this.onMoodCard,
  });

  String get _nextStageName {
    final next = TreeStage.values.firstWhere((s) => s.threshold > state.stage.threshold, orElse: () => TreeStage.bloom);
    return next.label;
  }

  double get _progress {
    final prev = state.stage.threshold.toDouble();
    final next = state.nextThreshold.toDouble();
    if (next <= prev) return 1;
    return (state.sunTotal - prev) / (next - prev);
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: [
        PageHeader(kicker: '快樂花園 · 第 1 棵', title: '你的櫻花樹'),
        const SizedBox(height: 14),
        SizedBox(height: 220, child: SakuraTree(stage: state.stage)),
        const SizedBox(height: 14),
        CDCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${state.stage.label}期 · 陽光 ${state.sunTotal}', style: CDText.title(14, color: p.text)),
                  const Spacer(),
                  Text('距離$_nextStageName ${(state.nextThreshold - state.sunTotal).clamp(0, 999)}',
                      style: CDText.body(11.5, weight: FontWeight.w700, color: p.text2)),
                ],
              ),
              const SizedBox(height: 8),
              SunProgressBar(value: _progress),
              const SizedBox(height: 8),
              Text('今日陽光 ${state.sunToday} / 15 · 連續 ${state.streak} 天',
                  style: CDText.body(11.5, weight: FontWeight.w500, color: p.text2)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionHeader(title: '今天的快樂任務'),
        const SizedBox(height: 10),
        for (final task in state.happyTasks) ...[_taskRow(context, p, task), const SizedBox(height: 10)],
        GestureDetector(
          onTap: () {
            Haptics.light();
            onMoodCard();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CD.rCard),
            child: SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const MoodBlobBackground(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('今日心情小卡', style: CDText.body(11, weight: FontWeight.w900, color: CD.cream.withValues(alpha: 0.8))),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Text(MockData.moodCards[0].text,
                              textAlign: TextAlign.center, style: CDText.title(14, color: CD.cream)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _taskRow(BuildContext context, Palette p, HappyTask task) {
    return Opacity(
      opacity: task.done ? 0.66 : 1,
      child: ListRowCard(
        onTap: () {
          switch (task.kind) {
            case HappyKind.breathing:
              Haptics.light();
              onBreathing();
            case HappyKind.gratitude:
              Haptics.light();
              onGratitude();
            default:
              state.completeTask(task);
          }
        },
        iconBg: _color(task.kind).withValues(alpha: 0.15),
        icon: Icon(_icon(task.kind), size: 15, color: _color(task.kind)),
        title: task.title,
        subtitle: task.done ? '${task.subtitle} · 已完成' : task.subtitle,
        trailing: TagView(text: '+${task.sun} 陽光', color: task.done ? CD.success : p.text2),
      ),
    );
  }

  IconData _icon(HappyKind k) => switch (k) {
        HappyKind.breathing => Icons.air,
        HappyKind.gratitude => Icons.favorite_border,
        HappyKind.exercise => Icons.self_improvement,
        HappyKind.challenge => Icons.local_fire_department_outlined,
        HappyKind.share => Icons.send_outlined,
      };
  Color _color(HappyKind k) => switch (k) {
        HappyKind.breathing => CD.info,
        HappyKind.gratitude => const Color(0xFFC8D432),
        HappyKind.exercise => CD.success,
        HappyKind.challenge => CD.danger,
        HappyKind.share => CD.accent,
      };
}

/// 感恩日記
class GratitudeScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onClose;
  const GratitudeScreen({super.key, required this.state, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Column(
      children: [
        FlowTopBar(title: '感恩日記', onClose: onClose),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                PageHeader(kicker: MockData.gratitudePrompts[0], title: '寫下一件感恩的事'),
                const SizedBox(height: 14),
                CDCard(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    maxLines: 6,
                    style: CDText.body(15, color: p.text),
                    decoration: InputDecoration.collapsed(hintText: '今天…', hintStyle: CDText.body(15, color: p.text3)),
                  ),
                ),
                const SizedBox(height: 14),
                PillButton(title: '存下來', icon: Icons.favorite_border, style: PillStyle.lemon, onTap: onClose),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 心情小卡（C 風格全幅）
class MoodCardScreen extends StatelessWidget {
  final VoidCallback onClose;
  const MoodCardScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const MoodBlobBackground(),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        onClose();
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 15, color: CD.cream),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Text(MockData.moodCards[0].text,
                    textAlign: TextAlign.center, style: CDText.display(22, color: CD.cream)),
              ),
              const SizedBox(height: 14),
              Text('— ${MockData.moodCards[0].author}', style: CDText.body(13, weight: FontWeight.w700, color: CD.cream.withValues(alpha: 0.7))),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: PillButton(
                    title: '分享給家人',
                    icon: Icons.send_outlined,
                    style: PillStyle.lemon,
                    onTap: () => showComingSoon(context, '分享給家人')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
