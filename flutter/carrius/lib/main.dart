import 'package:flutter/material.dart';
import 'design/tokens.dart';
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
          home: PaletteScope(
            palette: palette,
            child: AppShell(state: state),
          ),
        );
      },
    );
  }
}
