import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'design/tokens.dart';
import 'design/haptics.dart';
import 'state/app_state.dart';
import 'app_shell.dart';

void main() => runApp(const CarriusApp());

class CarriusApp extends StatefulWidget {
  /// forcePalette：golden 測試指定深淺色用；null = 跟隨系統（預設淺色優先）
  final Palette? forcePalette;
  const CarriusApp({super.key, this.forcePalette});

  @override
  State<CarriusApp> createState() => _CarriusAppState();
}

class _CarriusAppState extends State<CarriusApp> {
  final state = AppState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final brightness = MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
        final sysDark = brightness == Brightness.dark;
        // 設定頁可覆寫系統；預設跟隨系統（淺色為先）
        final isDark = switch (state.themePref) {
          ThemePref.dark => true,
          ThemePref.light => false,
          ThemePref.system => sysDark,
        };
        final palette = widget.forcePalette ?? (isDark ? Palette.dark : Palette.light);

        return MaterialApp(
          title: 'Carrius',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: palette.bg,
            fontFamily: CD.body,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          // Web：在所有 route（含 modal sheet）之上掛震動視覺提示。真機不掛。
          builder: kIsWeb
              ? (context, child) => Stack(
                    children: [
                      if (child != null) child,
                      const Positioned(top: 0, left: 0, right: 0, child: _HapticDebugOverlay()),
                    ],
                  )
              : null,
          home: PaletteScope(
            palette: palette,
            child: AppShell(state: state),
          ),
        );
      },
    );
  }
}

/// Web 專用：震動觸發時，於頂部置中閃一個短暫小標籤（驗證「震動時機」用）。
class _HapticDebugOverlay extends StatefulWidget {
  const _HapticDebugOverlay();
  @override
  State<_HapticDebugOverlay> createState() => _HapticDebugOverlayState();
}

class _HapticDebugOverlayState extends State<_HapticDebugOverlay> {
  bool _show = false;
  String _label = '';
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    HapticDebug.tick.addListener(_onTick);
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      _label = HapticDebug.label;
      _show = true;
    });
    _hide?.cancel();
    _hide = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  void dispose() {
    HapticDebug.tick.removeListener(_onTick);
    _hide?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              opacity: _show ? 1 : 0,
              duration: Duration(milliseconds: _show ? 80 : 260),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.vibration, size: 15, color: Colors.white),
                    const SizedBox(width: 7),
                    Text('震動 · $_label',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700, fontFamily: CD.body)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
