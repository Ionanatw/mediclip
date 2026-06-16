import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carrius/design/tokens.dart';
import 'package:carrius/models/models.dart';
import 'package:carrius/models/mock_data.dart';
import 'package:carrius/state/app_state.dart';
import 'package:carrius/widgets/carrius_tab_bar.dart';
import 'package:carrius/design/illustrations/sakura_tree.dart';

import 'package:carrius/screens/welcome_screen.dart';
import 'package:carrius/screens/email_gate_screen.dart';
import 'package:carrius/screens/home_screen.dart';
import 'package:carrius/screens/calendar_screen.dart';
import 'package:carrius/screens/drug_atlas_screen.dart';
import 'package:carrius/screens/documents_screen.dart';
import 'package:carrius/screens/garden_screen.dart';
import 'package:carrius/screens/upload_screen.dart';
import 'package:carrius/screens/followup_screen.dart';
import 'package:carrius/screens/results_screen.dart';
import 'package:carrius/screens/med_card_screen.dart';
import 'package:carrius/screens/checklist_screen.dart';
import 'package:carrius/screens/poster_screen.dart';
import 'package:carrius/screens/settings_screen.dart';
import 'package:carrius/screens/breathing_screen.dart';

const phoneSize = Size(393, 852);

Future<void> _loadFonts() async {
  final manifest = json.decode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  for (final entry in manifest) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List<dynamic>)) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Widget _frame(Widget child, {Palette palette = Palette.light, bool tabBar = false, AppState? state}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, fontFamily: CD.body, scaffoldBackgroundColor: palette.bg, splashFactory: NoSplash.splashFactory),
    home: PaletteScope(
      palette: palette,
      // 模擬真機安全區（靈動島 + 底部 home indicator），讓截圖與實機一致、
      // 並驗證內容不會頂到狀態列。結構對齊 app_shell。
      child: Builder(builder: (context) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(padding: const EdgeInsets.only(top: 59, bottom: 34)),
          child: Scaffold(
            backgroundColor: palette.bg,
            body: tabBar && state != null
                ? Stack(children: [
                    Positioned.fill(child: SafeArea(bottom: false, child: child)),
                    Positioned(left: 0, right: 0, bottom: 8, child: SafeArea(top: false, child: CarriusTabBar(state: state))),
                  ])
                : SafeArea(bottom: false, child: child),
          ),
        );
      }),
    ),
  );
}

void main() {
  setUpAll(_loadFonts);

  Future<void> shoot(WidgetTester tester, String name, Widget widget, {Size size = phoneSize}) async {
    tester.view.physicalSize = Size(size.width * 3, size.height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 60));
    // 讓 Image.asset 真的顯示（test 環境圖片解碼是 async）
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        final img = e.widget as Image;
        await precacheImage(img.image, e);
      }
    });
    await tester.pump(const Duration(milliseconds: 60));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
  }

  AppState homeState() => AppState()..onboarded = true;

  testWidgets('all screens (light)', (tester) async {
    await shoot(tester, '01-welcome', _frame(WelcomeScreen(onStart: () {})));

    final s2 = AppState()..role = UserRole.caregiver..email = 'mom.care@example.com';
    await shoot(tester, '02-email-identity', _frame(EmailGateScreen(state: s2, onContinue: () {})));

    final h = homeState();
    await shoot(tester, '03-home', _frame(HomeScreen(state: h, onOpenGarden: () {}, onOpenChecklist: () {}, onOpenSettings: () {}), tabBar: true, state: h));

    final up = homeState()..pickedCount = 3;
    await shoot(tester, '04-upload', _frame(UploadScreen(state: up, onClose: () {}, onStart: () {})));

    final fu = homeState();
    fu.followUps[0].selected = fu.followUps[0].options[0];
    await shoot(tester, '05-followup', _frame(FollowUpScreen(state: fu, onClose: () {}, onDone: () {})));

    final r = homeState();
    await shoot(tester, '06-results', _frame(ResultsScreen(state: r, onClose: () {}, onOpenMed: (_) {}, onOpenPoster: () {}, onFinish: () {})));

    await shoot(tester, '07-medcard', _frame(MedCardScreen(med: MockData.medications()[0], onClose: () {})));

    final cal = homeState()..tab = AppTab.calendar;
    await shoot(tester, '08-calendar', _frame(CalendarScreen(state: cal), tabBar: true, state: cal));

    await shoot(tester, '09-checklist', _frame(ChecklistScreen(state: homeState(), onClose: () {})));

    await shoot(tester, '10-poster', _frame(PosterScreen(state: homeState(), onClose: () {})));

    final doc = homeState()..tab = AppTab.documents;
    await shoot(tester, '11-documents', _frame(DocumentsScreen(state: doc), tabBar: true, state: doc));

    final atlas = homeState()..tab = AppTab.documents;
    await shoot(tester, '16-atlas', _frame(DrugAtlasScreen(state: atlas), tabBar: true, state: atlas));

    final atlasOpen = homeState()..tab = AppTab.documents;
    atlasOpen.atlasOpen.addAll(['ulcer_lansoprazole', 'ulcer_amoxicillin']);
    await shoot(tester, '17-atlas-open', _frame(DrugAtlasScreen(state: atlasOpen), tabBar: true, state: atlasOpen),
        size: const Size(393, 1680));

    // KSPH 完整標準表 showcase（舒脈優 = 鴿王參考卡本尊）
    final atlasHtn = homeState()..tab = AppTab.documents;
    atlasHtn.atlasOpen.add('htn_sevikar_hct');
    await shoot(tester, '18-atlas-htn-full',
        _frame(DrugAtlasScreen(state: atlasHtn, focusDisease: '高血壓及併發心臟疾病'), tabBar: true, state: atlasHtn),
        size: const Size(393, 1700));

    await shoot(tester, '12-settings', _frame(SettingsScreen(state: homeState())));

    final g = homeState()..tab = AppTab.garden;
    await shoot(tester, '13-garden', _frame(GardenScreen(state: g, onBreathing: () {}, onGratitude: () {}, onMoodCard: () {}), tabBar: true, state: g));

    await shoot(tester, '14-breathing', _frame(BreathingScreen(onClose: () {})));

    await shoot(tester, '15-moodcard', _frame(MoodCardScreen(onClose: () {})));
  });

  testWidgets('dark samples', (tester) async {
    final h = homeState();
    await shoot(tester, 'dark-home', _frame(HomeScreen(state: h, onOpenGarden: () {}, onOpenChecklist: () {}, onOpenSettings: () {}), palette: Palette.dark, tabBar: true, state: h));
    final g = homeState()..tab = AppTab.garden;
    await shoot(tester, 'dark-garden', _frame(GardenScreen(state: g, onBreathing: () {}, onGratitude: () {}, onMoodCard: () {}), palette: Palette.dark, tabBar: true, state: g));

    // 補齊深色覆蓋（稽核項 E：原本只測 2 張）
    final cal = homeState()..tab = AppTab.calendar;
    await shoot(tester, 'dark-calendar', _frame(CalendarScreen(state: cal), palette: Palette.dark, tabBar: true, state: cal));
    final atlas = homeState()..tab = AppTab.documents;
    await shoot(tester, 'dark-atlas', _frame(DrugAtlasScreen(state: atlas), palette: Palette.dark, tabBar: true, state: atlas));
    final docs = homeState()..tab = AppTab.documents;
    await shoot(tester, 'dark-documents', _frame(DocumentsScreen(state: docs), palette: Palette.dark, tabBar: true, state: docs));
    await shoot(tester, 'dark-results', _frame(ResultsScreen(state: homeState(), onClose: () {}, onOpenMed: (_) {}, onOpenPoster: () {}, onFinish: () {}), palette: Palette.dark), size: const Size(393, 1100));
    await shoot(tester, 'dark-medcard', _frame(MedCardScreen(med: MockData.medications()[0], onClose: () {}), palette: Palette.dark), size: const Size(393, 1000));
    final up = homeState()..pickedCount = 3;
    await shoot(tester, 'dark-upload', _frame(UploadScreen(state: up, onClose: () {}, onStart: () {}), palette: Palette.dark), size: const Size(393, 1000));
    await shoot(tester, 'dark-poster', _frame(PosterScreen(state: homeState(), onClose: () {}), palette: Palette.dark), size: const Size(393, 1000));
    await shoot(tester, 'dark-checklist', _frame(ChecklistScreen(state: homeState(), onClose: () {}), palette: Palette.dark), size: const Size(393, 1000));
    await shoot(tester, 'dark-breathing', _frame(BreathingScreen(onClose: () {}), palette: Palette.dark));
  });

  testWidgets('tree stages', (tester) async {
    for (final stage in TreeStage.values) {
      await shoot(tester, 'tree-${stage.index}-${stage.label}',
          _frame(Padding(padding: const EdgeInsets.all(40), child: SakuraTree(stage: stage))),
          size: const Size(360, 360));
    }
  });

  // 清死按鈕新增的 sheet / 內容頁 golden（含深色），看圖驗收 + 回歸保護
  Future<void> shootSheet(WidgetTester tester, String name, Widget widget, Finder tapTarget,
      {Size size = const Size(393, 1500)}) async {
    tester.view.physicalSize = Size(size.width * 3, size.height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SizedBox.shrink()); // 清掉上一個 sheet 的 Navigator/route，避免殘留
    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.ensureVisible(tapTarget);
    await tester.pumpAndSettle();
    await tester.tap(tapTarget);
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
  }

  testWidgets('demo new-state sheets (light + dark)', (tester) async {
    await shootSheet(tester, '19-sheet-privacy', _frame(SettingsScreen(state: homeState())), find.text('隱私政策'));
    await shootSheet(tester, '20-sheet-pricing', _frame(SettingsScreen(state: homeState())), find.textContaining('方案：免費'));
    await shootSheet(tester, '21-sheet-about', _frame(SettingsScreen(state: homeState())), find.textContaining('Carrius v0.1 POC'));
    final doc = homeState()..tab = AppTab.documents;
    await shootSheet(tester, '22-doc-detail', _frame(DocumentsScreen(state: doc)),
        find.text(doc.session.documents.first.title));
    final gf = homeState()..tab = AppTab.garden;
    await shootSheet(tester, '23-forest',
        _frame(GardenScreen(state: gf, onBreathing: () {}, onGratitude: () {}, onMoodCard: () {})),
        find.text('看全部'));
    // 深色模式驗證（新 sheet 用 palette token，理應自適應）
    await shootSheet(tester, 'dark-sheet-privacy', _frame(SettingsScreen(state: homeState()), palette: Palette.dark),
        find.text('隱私政策'));
    await shootSheet(tester, 'dark-sheet-pricing', _frame(SettingsScreen(state: homeState()), palette: Palette.dark),
        find.textContaining('方案：免費'));
  });
}
