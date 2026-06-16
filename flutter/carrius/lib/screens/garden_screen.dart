import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../design/components.dart';
import '../design/haptics.dart';
import '../design/illustrations/sakura_tree.dart';
import '../design/illustrations/backgrounds.dart';
import '../models/models.dart';
import '../models/mock_data.dart';
import '../state/app_state.dart';

/// 花園頁的暖色調用色（mockup #E08A2B 系），與品牌薰衣草紫並存。
const _sunOrange = Color(0xFFE08A2B);

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

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    final groups = MockData.happyActivities();
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 120),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: PageHeader(kicker: '快樂花園', title: '照顧家人，也照顧自己'),
        ),
        const SizedBox(height: 14),
        _streakCard(p),
        const SizedBox(height: 8),
        _treeScene(p),
        for (final g in groups) ...[
          const SizedBox(height: 18),
          _railHead(p, g),
          const SizedBox(height: 9),
          _rail(context, g),
        ],
        const SizedBox(height: 18),
        _recap(p),
      ],
    );
  }

  // ---- 1. 連續簽到 ----
  Widget _streakCard(Palette p) {
    // 本週示意：週一至週四已完成、週五今天、週末留白（對齊 mockup 5/7）
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    const states = [_Day.done, _Day.done, _Day.done, _Day.done, _Day.today, _Day.empty, _Day.empty];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: CDCard(
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7C2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_fire_department, size: 17, color: _sunOrange),
                ),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    style: CDText.title(14.5, color: p.text),
                    children: [
                      const TextSpan(text: '連續 '),
                      TextSpan(text: '${state.streak}', style: CDText.display(15, color: _sunOrange)),
                      const TextSpan(text: ' 天照顧自己'),
                    ],
                  ),
                ),
                const Spacer(),
                Text('本週 5 / 7', style: CDText.body(11, weight: FontWeight.w700, color: p.text2)),
              ],
            ),
            const SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < labels.length; i++) _dayPip(p, labels[i], states[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayPip(Palette p, String label, _Day day) {
    final Widget dot;
    switch (day) {
      case _Day.done:
        dot = Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(color: CD.accent, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 14, color: CD.cream),
        );
      case _Day.today:
        dot = Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: p.surface,
            shape: BoxShape.circle,
            border: Border.all(color: CD.accent, width: 2),
          ),
          child: Center(child: Text('今', style: CDText.body(10.5, weight: FontWeight.w900, color: CD.accent))),
        );
      case _Day.empty:
        dot = Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: p.surface3, shape: BoxShape.circle),
        );
    }
    return Column(
      children: [
        Text(label, style: CDText.body(10, weight: FontWeight.w700, color: p.text3)),
        const SizedBox(height: 5),
        dot,
      ],
    );
  }

  // ---- 2. 樹當吉祥物的暖場景（無框） ----
  Widget _treeScene(Palette p) {
    final cur = state.currentSpecies;
    final remain = (state.nextThreshold - state.currentSun).clamp(0, 999);
    final idle = state.idleMessage;
    final caption = state.allGrown ? '你的森林，長得正好' : '你的${cur.nameZh}，長得正好';
    return SizedBox(
      height: 286,
      child: Stack(
        children: [
          const Positioned.fill(child: _SceneBackground()),
          // ☀ 數字浮標（右上）
          Positioned(
            top: 12,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: CD.cream.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 13, color: _sunOrange),
                  const SizedBox(width: 4),
                  Text('${state.currentSun}', style: CDText.display(12.5, color: _sunOrange)),
                ],
              ),
            ),
          ),
          // 樹（吉祥物）
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: SizedBox(height: 200, child: GardenTree(species: cur, stage: state.stage)),
          ),
          // 溫柔文案
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Column(
              children: [
                Text(caption, style: CDText.display(18, color: p.text)),
                const SizedBox(height: 3),
                _caption(p, remain, idle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 場景副標：荒廢時顯示溫柔訊息，否則顯示「{階段}期 · 再 N ☀ 就長成大樹」。
  Widget _caption(Palette p, int remain, String? idle) {
    final style = CDText.body(12, weight: FontWeight.w600, color: p.text2);
    if (idle != null) return Text(idle, style: style);
    if (state.allGrown) return Text('三棵都長成了 · 更多品種即將到來', style: style);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${state.stage.label}期 · 再 $remain ', style: style),
        const Icon(Icons.wb_sunny_outlined, size: 12, color: _sunOrange),
        Text(' 就長成大樹', style: style),
      ],
    );
  }

  // ---- 3. 分類橫向滑動快樂圖卡 ----
  Widget _railHead(Palette p, GardenActivityGroup g) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(g.title, style: CDText.title(15.5, color: p.text)),
          const SizedBox(height: 1),
          Text(g.subtitle, style: CDText.body(11.5, weight: FontWeight.w600, color: p.text2)),
        ],
      ),
    );
  }

  Widget _rail(BuildContext context, GardenActivityGroup g) {
    return SizedBox(
      height: 138,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: g.activities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (ctx, i) => _activityCard(ctx, g.activities[i]),
      ),
    );
  }

  Widget _activityCard(BuildContext context, GardenActivity a) {
    final p = PaletteScope.of(context);
    final done = state.activityDone(a.title);
    final cardBg = p.brightness == Brightness.dark ? p.surface : Color.alphaBlend(a.tint.withValues(alpha: 0.10), CD.cream);
    final blobBg = p.brightness == Brightness.dark
        ? a.tint.withValues(alpha: 0.22)
        : Color.alphaBlend(a.tint.withValues(alpha: 0.22), CD.cream);
    return GestureDetector(
      onTap: () => _route(context, a),
      child: Container(
        width: 138,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: p.brightness == Brightness.dark ? Border.all(color: p.cardBorder, width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: blobBg, borderRadius: BorderRadius.circular(16)),
              child: Icon(a.icon, size: 25, color: a.tint),
            ),
            const SizedBox(height: 8),
            Text(a.title, style: CDText.title(13.5, color: p.text), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Expanded(
              child: Text(a.guide,
                  style: CDText.body(10.5, weight: FontWeight.w600, color: p.text2, height: 1.35),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            Row(
              children: [
                if (done)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: CD.success.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 11, color: CD.success),
                        const SizedBox(width: 3),
                        Text('已完成', style: CDText.body(9.5, weight: FontWeight.w800, color: CD.success)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: CD.cream.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('+${a.sun}', style: CDText.display(10, color: _sunOrange)),
                        const SizedBox(width: 2),
                        const Icon(Icons.wb_sunny_outlined, size: 10, color: _sunOrange),
                      ],
                    ),
                  ),
                const SizedBox(width: 6),
                if (!done)
                  Flexible(
                    child: Text(a.chem,
                        style: CDText.body(9.5, weight: FontWeight.w800, color: p.text3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _route(BuildContext context, GardenActivity a) {
    switch (a.kind) {
      case HappyKind.breathing:
        Haptics.light();
        onBreathing();
      case HappyKind.gratitude:
        Haptics.light();
        onGratitude();
      case HappyKind.share:
        Haptics.light();
        onMoodCard();
      case HappyKind.exercise:
      case HappyKind.challenge:
        state.completeActivity(a.title, a.sun);
    }
  }

  // ---- 4. 底部回顧 ----
  Widget _recap(Palette p) {
    final recapBg = p.brightness == Brightness.dark ? p.surface : CD.accentSoft;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: recapBg,
          borderRadius: BorderRadius.circular(20),
          border: p.brightness == Brightness.dark ? Border.all(color: p.cardBorder, width: 1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.eco_outlined, size: 18, color: CD.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('這週你照顧自己 5 天', style: CDText.title(13.5, color: p.text)),
                  const SizedBox(height: 1),
                  Text('每天一點點，${state.currentSpecies.nameZh}和你都在長',
                      style: CDText.body(11, weight: FontWeight.w600, color: p.text2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Day { done, today, empty }

/// 樹場景背景：暖色天空漸層 + 柔和太陽光暈 + 小山丘曲線（無方框）。
class _SceneBackground extends StatelessWidget {
  const _SceneBackground();
  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return CustomPaint(painter: _ScenePainter(p.brightness == Brightness.dark), size: Size.infinite);
  }
}

class _ScenePainter extends CustomPainter {
  final bool dark;
  _ScenePainter(this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // 天空漸層
    final skyTop = dark ? const Color(0xFF272233) : const Color(0xFFF3ECFF);
    final skyMid = dark ? const Color(0xFF2A2622) : const Color(0xFFFBF4EC);
    final skyBot = dark ? const Color(0xFF1C1C1C) : const Color(0xFFFDFBF7);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, skyBot],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );
    // 柔和太陽光暈
    final glow = dark ? const Color(0xFF4A3F2A) : const Color(0xFFFFEFD6);
    final glowInner = dark ? const Color(0xFF5A4A2E) : const Color(0xFFFFE3B8);
    final cx = w / 2, cy = h * 0.40;
    canvas.drawCircle(Offset(cx, cy), w * 0.34, Paint()..color = glow.withValues(alpha: 0.7));
    canvas.drawCircle(Offset(cx, cy), w * 0.23, Paint()..color = glowInner.withValues(alpha: 0.55));
    // 小山丘曲線（兩層）
    final hill1 = dark ? const Color(0xFF24302A) : const Color(0xFFEAF3EA);
    final hill2 = dark ? const Color(0xFF1F2A24) : const Color(0xFFDCEEDF);
    final p1 = Path()
      ..moveTo(0, h * 0.83)
      ..quadraticBezierTo(w * 0.35, h * 0.75, w * 0.58, h * 0.81)
      ..quadraticBezierTo(w * 0.82, h * 0.87, w, h * 0.80)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p1, Paint()..color = hill1);
    final p2 = Path()
      ..moveTo(0, h * 0.89)
      ..quadraticBezierTo(w * 0.44, h * 0.82, w * 0.77, h * 0.88)
      ..quadraticBezierTo(w * 0.92, h * 0.91, w, h * 0.87)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p2, Paint()..color = hill2);
    // 飄浮小點點
    if (!dark) {
      canvas.drawCircle(Offset(w * 0.19, h * 0.26), 3.5, Paint()..color = const Color(0xFFC9B7F2));
      canvas.drawCircle(Offset(w * 0.83, h * 0.21), 4, Paint()..color = const Color(0xFFF3C7DC));
      canvas.drawCircle(Offset(w * 0.88, h * 0.51), 3, Paint()..color = const Color(0xFFC9B7F2));
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.dark != dark;
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
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        onClose();
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, size: 18, color: CD.cream),
                      ),
                    ),
                    const Spacer(),
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
