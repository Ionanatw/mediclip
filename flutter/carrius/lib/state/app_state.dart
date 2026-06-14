import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/mock_data.dart';
import '../design/haptics.dart';
import '../design/illustrations/sakura_tree.dart';

enum AppTab { home, calendar, documents, garden }

class AppState extends ChangeNotifier {
  bool onboarded = false;
  UserRole? role;
  String email = '';
  AppTab tab = AppTab.home;

  CareSession session = MockData.session();
  int careDays = 47;

  // 上傳流程暫存
  int pickedCount = 0;
  String noteText = '';
  final followUps = [
    FollowUpQuestion(
        '胃藥「早餐前 30 分鐘」如果忘記吃，衛教單沒寫怎麼辦。要用哪個規則提醒？',
        ['想起來立刻補吃', '過中午就跳過', '下次回診問醫師']),
    FollowUpQuestion(
        '傷口換藥是每天一次，還是滲濕才換？單子上兩處寫法不同。',
        ['每天固定一次', '滲濕就換', '兩者皆是']),
  ];

  // 快樂花園
  int sunToday = 6;
  int sunTotal = 132;
  int streak = 12;
  final happyTasks = MockData.happyTasks();
  String gratitudeText = '';

  TreeStage get stage => TreeStage.forSun(sunTotal);
  int get nextThreshold {
    final next = TreeStage.values.firstWhere(
      (s) => s.threshold > stage.threshold,
      orElse: () => TreeStage.bloom,
    );
    return next.threshold;
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
    final gain = task.sun.clamp(0, (15 - sunToday).clamp(0, 15));
    final before = stage;
    sunToday += gain;
    sunTotal += gain;
    if (stage != before) {
      Haptics.levelUp();
    } else {
      Haptics.success();
    }
    notifyListeners();
  }
}
