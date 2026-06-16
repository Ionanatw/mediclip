import 'package:flutter/material.dart';
import 'design/tokens.dart';
import 'design/haptics.dart';
import 'design/components.dart';
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
          final inset = MediaQuery.of(context).padding.bottom;
          return Stack(
            children: [
              Positioned.fill(child: SafeArea(bottom: false, child: _tabBody())),
              // 右下快速記錄 FAB（浮在 tab bar 之上；上傳流程/sheet 時隱藏）
              if (_upload == UploadStep.none && _sheet == null)
                Positioned(right: 22, bottom: 8 + inset + 54 + 12, child: _fab()),
              Positioned(left: 0, right: 0, bottom: 8, child: SafeArea(top: false, child: CarriusTabBar(state: state))),
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
          onOpenSettings: () => state.setTab(AppTab.settings),
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
      case AppTab.settings:
        return SettingsScreen(state: state);
    }
  }

  // ---- 右下快速記錄 FAB + hub ----
  Widget _fab() {
    return GestureDetector(
      onTap: () {
        Haptics.light();
        _openHub();
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: CD.accent,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: CD.accent.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: const Icon(Icons.add, size: 24, color: CD.plumDeep),
      ),
    );
  }

  void _openHub() {
    final p = PaletteScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        Widget row(IconData icon, Color c, String title, String sub, VoidCallback onTap) {
          return GestureDetector(
            onTap: () {
              Haptics.light();
              Navigator.of(ctx).pop();
              onTap();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(13)),
                      child: Icon(icon, size: 20, color: CD.cream)),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: CDText.title(14.5, color: p.text)),
                        const SizedBox(height: 1),
                        Text(sub, style: CDText.body(11.5, weight: FontWeight.w500, color: p.text2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return PaletteScope(
          palette: p,
          child: Container(
            decoration: BoxDecoration(color: p.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + media.padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 38, height: 4, decoration: BoxDecoration(color: p.surface3, borderRadius: BorderRadius.circular(999))),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: Text('快速記錄', style: CDText.title(16, color: p.text))),
                const SizedBox(height: 4),
                row(Icons.document_scanner_outlined, CD.info, '整理新文件', '拍照／選圖，AI 三分鐘整理成指南', _startUpload),
                Divider(height: 1, color: p.cardBorder),
                row(Icons.edit_note, CD.success, '記一筆', '體溫、症狀、今天的觀察', () => showComingSoon(context, '記一筆')),
                Divider(height: 1, color: p.cardBorder),
                row(Icons.notifications_none, CD.danger, '加提醒', '回診、領藥、換藥', () => showComingSoon(context, '加提醒')),
              ],
            ),
          ),
        );
      },
    );
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
