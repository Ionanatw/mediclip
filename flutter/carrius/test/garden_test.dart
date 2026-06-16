// 花園養成引擎單元測試：多樹解鎖、每日上限、永不死亡（核心做真）。
import 'package:flutter_test/flutter_test.dart';
import 'package:carrius/state/app_state.dart';
import 'package:carrius/models/models.dart';
import 'package:carrius/design/illustrations/sakura_tree.dart';

HappyTask _task(int sun, [HappyKind kind = HappyKind.exercise]) => HappyTask('t', '', sun, kind);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('初始狀態：櫻花已長成、茶樹養成中、橘子未解鎖', () {
    final s = AppState();
    expect(s.isGrown(TreeSpecies.sakura), true);
    expect(s.currentSpecies, TreeSpecies.tea);
    expect(s.isUnlocked(TreeSpecies.tea), true);
    expect(s.isUnlocked(TreeSpecies.orange), false);
    expect(s.grownSpecies, [TreeSpecies.sakura]);
    expect(s.allGrown, false);
  });

  test('完成任務把陽光灌進「當前的樹」，受每日 15 上限', () {
    final s = AppState();
    s.sunToday = 14; // 只剩 1 額度
    final before = s.sunFor(TreeSpecies.tea);
    s.completeTask(_task(3)); // 想 +3，只給 1
    expect(s.sunToday, 15);
    expect(s.sunFor(TreeSpecies.tea), before + 1);
    expect(s.sunFor(TreeSpecies.sakura), 200); // 已長成的不受影響
  });

  test('養成到 200 → 該樹長成、解鎖並切換到下一棵', () {
    final s = AppState();
    s.treeSun[TreeSpecies.tea] = 198;
    s.sunToday = 0;
    s.completeTask(_task(3)); // 201 → clamp 200
    expect(s.isGrown(TreeSpecies.tea), true);
    expect(s.isUnlocked(TreeSpecies.orange), true);
    expect(s.currentSpecies, TreeSpecies.orange);
  });

  test('全部長成 → allGrown，再完成任務不報錯、仍記每日陽光', () {
    final s = AppState();
    s.treeSun[TreeSpecies.tea] = 200;
    s.treeSun[TreeSpecies.orange] = 200;
    expect(s.allGrown, true);
    s.sunToday = 0;
    s.completeTask(_task(2, HappyKind.gratitude));
    expect(s.sunToday, 2);
    expect(s.allGrown, true);
  });

  test('永不死亡：荒廢只給訊息、進度不減，回來歸零', () {
    final s = AppState();
    final tea = s.sunFor(TreeSpecies.tea);
    s.idleDays = 3;
    expect(s.idleMessage, TreeSpecies.idle3d);
    s.idleDays = 14;
    expect(s.idleMessage, TreeSpecies.idle14d);
    expect(s.sunFor(TreeSpecies.tea), tea); // 荒廢不扣進度
    s.completeTask(_task(2, HappyKind.gratitude));
    expect(s.idleDays, 0); // 回來立刻歸零
  });

  test('stage 跟著當前樹的陽光走', () {
    final s = AppState();
    // 茶樹 124 → 茁壯（120 門檻）
    expect(s.stage, TreeStage.growing);
    expect(s.currentSun, 124);
  });
}
