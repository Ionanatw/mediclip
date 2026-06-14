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
    final brightness = MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    // 淺色為先：系統未明確指定深色就走淺色
    final palette = widget.forcePalette ?? (brightness == Brightness.dark ? Palette.dark : Palette.light);

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
  }
}
