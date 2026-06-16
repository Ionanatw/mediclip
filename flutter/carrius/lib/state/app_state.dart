import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/mock_data.dart';
import '../design/haptics.dart';
import '../design/illustrations/sakura_tree.dart';

enum AppTab { home, calendar, documents, garden, settings }

/// 深色模式偏好（設定頁可切換；預設跟隨系統）
enum ThemePref { system, light, dark }

class AppState extends ChangeNotifier {
  bool onboarded = false;
  UserRole? role;
  String email = '';
  AppTab tab = AppTab.home;

  ThemePref themePref = ThemePref.system;
  void setThemePref(ThemePref t) {
    themePref = t;
    Haptics.light();
    notifyListeners();
  }

  CareSession session = MockData.session();
  int careDays = 47;

  // 上傳流程暫存
  int pickedCount = 0;
  final followUps = [
    FollowUpQuestion(
        '胃藥「早餐前 30 分鐘」如果忘記吃，衛教單沒寫怎麼辦。要用哪個規則提醒？',
        ['想起來立刻補吃', '過中午就跳過', '下次回診問醫師']),
    FollowUpQuestion(
        '傷口換藥是每天一次，還是滲濕才換？單子上兩處寫法不同。',
        ['每天固定一次', '滲濕就換', '兩者皆是']),
  ];

  // 藥品圖鑑：預設收合（乾淨），可一鍵展開全部或單列展開
  bool atlasExpandAll = false;
  final Set<String> atlasOpen = {};

  void atlasToggleAll() {
    atlasExpandAll = !atlasExpandAll;
    atlasOpen.clear();
    Haptics.light();
    notifyListeners();
  }

  void atlasToggleOne(String slug) {
    if (atlasOpen.contains(slug)) {
      atlasOpen.remove(slug);
    } else {
      atlasOpen.add(slug);
    }
    Haptics.light();
    notifyListeners();
  }

  bool atlasIsOpen(String slug) => atlasExpandAll || atlasOpen.contains(slug);

  // 快樂花園 — 多樹養成（PRD：3 樹依序解鎖、200 陽光長成、每日上限 15、永不死亡）
  int sunToday = 6;
  int streak = 12;
  int idleDays = 0; // 荒廢天數；做任務歸零。永不死亡，只垂頭打瞌睡
  final happyTasks = MockData.happyTasks();

  // 各樹累積陽光（demo 初始：櫻花已長成入森林、茶樹養成中、橘子未解鎖）
  final Map<TreeSpecies, int> treeSun = {
    TreeSpecies.sakura: 200,
    TreeSpecies.tea: 124,
    TreeSpecies.orange: 0,
  };

  int sunFor(TreeSpecies s) => treeSun[s] ?? 0;
  bool isGrown(TreeSpecies s) => sunFor(s) >= TreeStage.bloom.threshold;
  List<TreeSpecies> get grownSpecies => TreeSpecies.values.where(isGrown).toList();
  bool get allGrown => grownSpecies.length == TreeSpecies.values.length;

  /// 目前養成中的樹（第一棵未長成）；全長成則回最後一棵
  TreeSpecies get currentSpecies =>
      TreeSpecies.values.firstWhere((s) => !isGrown(s), orElse: () => TreeSpecies.values.last);

  /// 已解鎖＝排在「已長成數量」之內（前一棵長成才解鎖下一棵）
  bool isUnlocked(TreeSpecies s) => s.index <= grownSpecies.length;

  int get currentSun => sunFor(currentSpecies);
  TreeStage get stage => TreeStage.forSun(currentSun);
  int get nextThreshold {
    final next = TreeStage.values.firstWhere(
      (s) => s.threshold > stage.threshold,
      orElse: () => TreeStage.bloom,
    );
    return next.threshold;
  }

  /// 荒廢訊息（溫和不懲罰，永不死亡；回來立刻恢復）
  String? get idleMessage {
    if (idleDays >= 14) return TreeSpecies.idle14d;
    if (idleDays >= 7) return TreeSpecies.idle7d;
    if (idleDays >= 3) return TreeSpecies.idle3d;
    return null;
  }

  void setTab(AppTab t) {
    if (tab == t) return;
    Haptics.light();
    tab = t;
    notifyListeners();
  }

  void toggleMedication(Medication m) {
    m.takenToday = !m.takenToday;
    if (m.takenToday) Haptics.success();
    notifyListeners();
  }

  void toggleChecklist(ChecklistItem item) {
    item.done = !item.done;
    if (item.done) Haptics.success();
    notifyListeners();
  }

  void completeTask(HappyTask task) {
    if (task.done) return;
    task.done = true;
    idleDays = 0;
    final gain = task.sun.clamp(0, (15 - sunToday).clamp(0, 15));
    if (gain == 0 || allGrown) {
      sunToday += gain;
      Haptics.success();
      notifyListeners();
      return;
    }
    final cur = currentSpecies;
    final before = stage;
    sunToday += gain;
    treeSun[cur] = (sunFor(cur) + gain).clamp(0, TreeStage.bloom.threshold);
    // 階段提升或剛長成一棵樹 → 升級觸覺
    if (stage != before || isGrown(cur)) {
      Haptics.levelUp();
    } else {
      Haptics.success();
    }
    notifyListeners();
  }
}
