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
                    Positioned(left: 0, right: 0, bottom: 8, child: SafeArea(top: false, child: CarriusTabBar(state: state, onUpload: () {}))),
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

    final atlas = homeState()..tab = AppTab.atlas;
    await shoot(tester, '16-atlas', _frame(DrugAtlasScreen(state: atlas), tabBar: true, state: atlas));

    final atlasOpen = homeState()..tab = AppTab.atlas;
    atlasOpen.atlasOpen.add('ulcer_lansoprazole');
    await shoot(tester, '17-atlas-open', _frame(DrugAtlasScreen(state: atlasOpen), tabBar: true, state: atlasOpen));

    await shoot(tester, '12-settings', _frame(SettingsScreen(onClose: () {})));

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
  });

  testWidgets('tree stages', (tester) async {
    for (final stage in TreeStage.values) {
      await shoot(tester, 'tree-${stage.index}-${stage.label}',
          _frame(Padding(padding: const EdgeInsets.all(40), child: SakuraTree(stage: stage))),
          size: const Size(360, 360));
    }
  });
}
