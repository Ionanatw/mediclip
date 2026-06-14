import 'package:flutter/material.dart';
import 'design/tokens.dart';
import 'state/app_state.dart';
import 'models/models.dart';
import 'widgets/carrius_tab_bar.dart';
import 'screens/welcome_screen.dart';
import 'screens/email_gate_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/followup_screen.dart';
import 'screens/results_screen.dart';
import 'screens/med_card_screen.dart';
import 'screens/checklist_screen.dart';
import 'screens/poster_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/breathing_screen.dart';

enum _Onboard { welcome, email }

enum UploadStep { none, upload, processing, followUp, results }

class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  _Onboard _onboard = _Onboard.welcome;
  UploadStep _upload = UploadStep.none;
  Widget? _sheet;

  AppState get state => widget.state;

  void _openSheet(Widget w) => setState(() => _sheet = w);
  void _closeSheet() => setState(() => _sheet = null);

  void _startUpload() {
    state.pickedCount = 0;
    setState(() => _upload = UploadStep.upload);
  }

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          if (!state.onboarded) return _onboarding(p);
          return Stack(
            children: [
              Positioned.fill(child: SafeArea(bottom: false, child: _tabBody())),
              Positioned(left: 0, right: 0, bottom: 8, child: SafeArea(top: false, child: CarriusTabBar(state: state, onUpload: _startUpload))),
              if (_upload != UploadStep.none)
                Positioned.fill(child: SafeArea(bottom: false, child: ColoredBox(color: p.bg, child: _uploadFlow()))),
              if (_sheet != null) Positioned.fill(child: ColoredBox(color: p.bg, child: SafeArea(bottom: false, child: _sheet!))),
            ],
          );
        },
      ),
    );
  }

  // ---- 引導 ----
  Widget _onboarding(Palette p) {
    return SafeArea(
      child: switch (_onboard) {
        _Onboard.welcome => WelcomeScreen(onStart: () => setState(() => _onboard = _Onboard.email)),
        _Onboard.email => EmailGateScreen(
            state: state,
            onContinue: () => setState(() => state.onboarded = true),
          ),
      },
    );
  }

  // ---- 分頁 ----
  Widget _tabBody() {
    switch (state.tab) {
      case AppTab.home:
        return HomeScreen(
          state: state,
          onOpenGarden: () => state.setTab(AppTab.garden),
          onOpenChecklist: () => _openSheet(ChecklistScreen(state: state, onClose: _closeSheet)),
          onOpenSettings: () => _openSheet(SettingsScreen(onClose: _closeSheet)),
        );
      case AppTab.calendar:
        return CalendarScreen(state: state);
      case AppTab.documents:
        return DocumentsScreen(state: state);
      case AppTab.garden:
        return GardenScreen(
          state: state,
          onBreathing: () => _openSheet(BreathingScreen(onClose: _closeSheet)),
          onGratitude: () => _openSheet(GratitudeScreen(state: state, onClose: _closeSheet)),
          onMoodCard: () => _openSheet(MoodCardScreen(onClose: _closeSheet)),
        );
    }
  }

  // ---- 上傳流程 ----
  Widget _uploadFlow() {
    void close() => setState(() => _upload = UploadStep.none);
    switch (_upload) {
      case UploadStep.upload:
        return UploadScreen(state: state, onClose: close, onStart: () => setState(() => _upload = UploadStep.processing));
      case UploadStep.processing:
        return ProcessingScreen(onDone: () => setState(() => _upload = UploadStep.followUp));
      case UploadStep.followUp:
        return FollowUpScreen(state: state, onClose: close, onDone: () => setState(() => _upload = UploadStep.results));
      case UploadStep.results:
        return ResultsScreen(
          state: state,
          onClose: close,
          onOpenMed: (Medication m) => _openSheet(MedCardScreen(med: m, onClose: _closeSheet)),
          onOpenPoster: () => _openSheet(PosterScreen(state: state, onClose: _closeSheet)),
          onFinish: () {
            close();
            state.setTab(AppTab.home);
          },
        );
      case UploadStep.none:
        return const SizedBox.shrink();
    }
  }
}
