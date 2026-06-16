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
    return (state.currentSun - prev) / (next - prev);
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final cur = state.currentSpecies;
    final treeNo = state.allGrown ? TreeSpecies.values.length : state.grownSpecies.length + 1;
    final idle = state.idleMessage;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: [
        PageHeader(
          kicker: '快樂花園 · 第 $treeNo 棵 / ${TreeSpecies.values.length}',
          title: state.allGrown ? '你的快樂森林' : '你的${cur.nameZh}',
        ),
        const SizedBox(height: 14),
        SizedBox(height: 220, child: GardenTree(species: cur, stage: state.stage)),
        if (idle != null) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(idle, style: CDText.body(12.5, weight: FontWeight.w600, color: p.text2)),
          ),
        ],
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
                  Text(
                      state.allGrown
                          ? '三棵都長成了'
                          : '${state.stage.label}期 · 陽光 ${state.currentSun} / 200',
                      style: CDText.title(14, color: p.text)),
                  const Spacer(),
                  if (!state.allGrown)
                    Text('距離$_nextStageName ${(state.nextThreshold - state.currentSun).clamp(0, 999)}',
                        style: CDText.body(11.5, weight: FontWeight.w700, color: p.text2)),
                ],
              ),
              const SizedBox(height: 8),
              SunProgressBar(value: _progress),
              const SizedBox(height: 8),
              Text(
                  state.allGrown
                      ? '更多品種即將到來 · 今日陽光 ${state.sunToday} / 15'
                      : '${cur.tagline} · 今日陽光 ${state.sunToday} / 15 · 連續 ${state.streak} 天',
                  style: CDText.body(11.5, weight: FontWeight.w500, color: p.text2)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionHeader(title: '快樂森林', trailing: '看全部', onTap: () => _openForest(context)),
        const SizedBox(height: 10),
        _forestRow(context, p),
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

  // 快樂森林：3 樹種一列（已長成／養成中／未解鎖）
  Widget _forestRow(BuildContext context, Palette p) {
    return Row(
      children: [
        for (final s in TreeSpecies.values) ...[
          Expanded(child: _speciesTile(context, p, s)),
          if (s != TreeSpecies.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _speciesTile(BuildContext context, Palette p, TreeSpecies s) {
    final grown = state.isGrown(s);
    final unlocked = state.isUnlocked(s);
    return GestureDetector(
      onTap: () => _openForest(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(CD.rRow),
          border: Border.all(color: grown ? CD.accent.withValues(alpha: 0.4) : p.cardBorder, width: 1),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: unlocked
                  ? GardenTree(species: s, stage: grown ? TreeStage.bloom : state.stage)
                  : Center(child: Icon(Icons.lock_outline, size: 18, color: p.text3)),
            ),
            const SizedBox(height: 4),
            Text(s.nameZh, style: CDText.body(11.5, weight: FontWeight.w800, color: unlocked ? p.text : p.text3)),
            const SizedBox(height: 2),
            Text(
              grown ? '已長成' : (unlocked ? '${state.sunFor(s)}/200' : '未解鎖'),
              style: CDText.body(10, weight: FontWeight.w700, color: grown ? CD.accent : p.text3),
            ),
          ],
        ),
      ),
    );
  }

  void _openForest(BuildContext context) {
    Haptics.light();
    showCDSheet(context, title: '快樂森林', body: _forestBody(context));
  }

  Widget _forestBody(BuildContext context) {
    final p = PaletteScope.of(context);
    final grownCount = state.grownSpecies.length;
    final scene = grownCount <= 1
        ? '空地上種著你的樹'
        : grownCount == 2
            ? '兩棵樹之間多了一條小路'
            : '柵欄圍起小花園，蝴蝶飛來了';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetParagraph('完成快樂任務累積陽光，每棵樹 200 陽光長成，長成後解鎖下一棵。樹永遠不會死亡，荒廢只會垂頭打瞌睡。'),
        const SizedBox(height: 6),
        for (final s in TreeSpecies.values) _forestSpeciesRow(p, s),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.park_outlined, size: 15, color: CD.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text('森林場景：$scene（已長成 $grownCount / ${TreeSpecies.values.length}）',
                  style: CDText.body(12.5, weight: FontWeight.w500, color: p.text2)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _forestSpeciesRow(Palette p, TreeSpecies s) {
    final grown = state.isGrown(s);
    final unlocked = state.isUnlocked(s);
    final status = grown ? '已長成 · 收進森林' : (unlocked ? '養成中 ${state.sunFor(s)} / 200' : '尚未解鎖 · ${s.unlockHint}');
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(CD.rRow),
        border: Border.all(color: grown ? CD.accent.withValues(alpha: 0.4) : p.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: unlocked
                ? GardenTree(species: s, stage: grown ? TreeStage.bloom : state.stage)
                : Center(child: Icon(Icons.lock_outline, size: 18, color: p.text3)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.nameZh, style: CDText.title(14, color: unlocked ? p.text : p.text3)),
                const SizedBox(height: 2),
                Text(status, style: CDText.body(11.5, weight: FontWeight.w600, color: grown ? CD.accent : p.text2)),
                const SizedBox(height: 1),
                Text(s.tagline, style: CDText.body(10.5, weight: FontWeight.w500, color: p.text3)),
              ],
            ),
          ),
          if (grown) const Icon(Icons.check_circle, size: 18, color: CD.accent),
        ],
      ),
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
