// 互動回歸測試：死按鈕修復後的新路徑（sheet / 誠實 Coming Soon）不丟例外、內容正確。
// 對應 settings 內容頁、calendar/moodcard Coming Soon、documents 詳情。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carrius/design/tokens.dart';
import 'package:carrius/state/app_state.dart';
import 'package:carrius/models/mock_data.dart';
import 'package:carrius/screens/settings_screen.dart';
import 'package:carrius/screens/calendar_screen.dart';
import 'package:carrius/screens/documents_screen.dart';
import 'package:carrius/screens/family_talk_screen.dart';
import 'package:carrius/screens/home_screen.dart';
import 'package:carrius/screens/results_screen.dart';
import 'package:carrius/screens/med_card_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: CD.body),
      home: PaletteScope(
        palette: Palette.light,
        child: Scaffold(body: SafeArea(child: child)),
      ),
    );

AppState _state() => AppState()..onboarded = true;

void main() {
  testWidgets('settings 隱私政策 開出真內容 sheet', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(SettingsScreen(state: _state())));
    await tester.tap(find.text('隱私政策'));
    await tester.pumpAndSettle();
    expect(find.textContaining('你的醫療資料只存在這台手機'), findsOneWidget);
    expect(find.textContaining('送法務複核'), findsOneWidget);
  });

  testWidgets('settings 方案 開出三層定價 sheet', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(SettingsScreen(state: _state())));
    await tester.tap(find.textContaining('方案：免費'));
    await tester.pumpAndSettle();
    expect(find.text('方案與計費'), findsOneWidget);
    expect(find.textContaining('吃到飽'), findsOneWidget);
    expect(find.textContaining('付費功能即將在正式版開放'), findsOneWidget);
  });

  testWidgets('settings 同意書 + 關於 都開得出來', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(SettingsScreen(state: _state())));
    await tester.tap(find.text('使用者同意書'));
    await tester.pumpAndSettle();
    expect(find.textContaining('不是醫療器材'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cdSheetClose'))); // sheet 的 close（用 Key 精準定位）
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Carrius v0.1 POC'));
    await tester.pumpAndSettle();
    expect(find.text('關於 Carrius'), findsOneWidget);
  });

  testWidgets('calendar .ics 按鈕跳誠實 Coming Soon', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 1400 * 3); // 高視窗，讓 ListView 底部按鈕 build 出來
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final s = _state()..tab = AppTab.calendar;
    await tester.pumpWidget(_wrap(CalendarScreen(state: s)));
    await tester.tap(find.text('加入手機行事曆 (.ics)'));
    await tester.pump(); // SnackBar 動畫
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('即將在正式版開放'), findsOneWidget);
  });

  testWidgets('documents 文件列點擊開詳情 sheet', (tester) async {
    final s = _state()..tab = AppTab.documents;
    await tester.pumpWidget(_wrap(DocumentsScreen(state: s)));
    final firstDoc = s.session.documents.first;
    await tester.tap(find.text(firstDoc.title));
    await tester.pumpAndSettle();
    expect(find.textContaining('只存在你的手機，未上傳雲端'), findsOneWidget);
  });

  testWidgets('familytalk 複製後出現「我傳出去了」領陽光按鈕', (tester) async {
    var completed = false;
    await tester.pumpWidget(_wrap(FamilyTalkScreen(onClose: () {}, onComplete: () => completed = true)));
    expect(find.textContaining('我傳出去了'), findsNothing);
    await tester.tap(find.text('複製這段話'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('已複製'), findsOneWidget);
    await tester.tap(find.textContaining('我傳出去了'));
    await tester.pump();
    expect(completed, isTrue);
  });

  testWidgets('med_card 白話版付費鎖（BlurLock）跳 Coming Soon', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(MedCardScreen(med: MockData.medications()[0], onClose: () {})));
    await tester.tap(find.text('白話版 — 月費解鎖'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('即將在正式版開放'), findsOneWidget);
  });

  testWidgets('home 識別卡 header 切到藥品圖鑑分頁（不再是死按鈕）', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 1500 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final s = _state();
    await tester.pumpWidget(_wrap(
      HomeScreen(state: s, onOpenGarden: () {}, onOpenSettings: () {}, nowHour: 9),
    ));
    expect(s.tab, AppTab.home);
    await tester.tap(find.text('識別卡'));
    await tester.pump();
    expect(s.tab, AppTab.documents);
  });

  testWidgets('home 任務流：單顆勾選＋全部吃了＋進度連動', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 1500 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final s = _state();
    await tester.pumpWidget(_wrap(
      HomeScreen(state: s, onOpenGarden: () {}, onOpenSettings: () {}, nowHour: 9),
    ));
    expect(s.todayDone, 0);
    // 單顆勾選（早餐前第一顆）
    await tester.tap(find.text('胃藥 40mg').first);
    await tester.pump();
    expect(s.todayDone, 1);
    // 全部吃了 → 早餐前 3 顆全完成
    await tester.tap(find.text('全部吃了'));
    await tester.pump();
    expect(s.daySlots.first.groups.first.tasks.every((t) => t.done), isTrue);
    expect(s.todayDone, 3);
    // 再點一次已完成的 → 復原
    await tester.tap(find.text('胃藥 40mg').first);
    await tester.pump();
    expect(s.todayDone, 2);
  });

  testWidgets('results 不再有假連結「全部識別卡」', (tester) async {
    final s = _state();
    await tester.pumpWidget(_wrap(
      ResultsScreen(state: s, onClose: () {}, onOpenMed: (_) {}, onOpenPoster: () {}, onFinish: () {}),
    ));
    expect(find.text('全部識別卡'), findsNothing);
  });
}
