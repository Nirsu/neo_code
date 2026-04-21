import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'i18n/strings.g.dart';
import 'ui/theme/neo_theme.dart';
import 'ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  LocaleSettings.useDeviceLocale();

  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Neo Code',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    TranslationProvider(child: ProviderScope(child: const NeoCodeApp())),
  );
}

class NeoCodeApp extends StatelessWidget {
  const NeoCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neo Code',
      debugShowCheckedModeBanner: false,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58A6FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[NeoTheme.dark],
      ),
      home: const NeoEditorScreen(),
    );
  }
}

class NeoEditorScreen extends ConsumerWidget {
  const NeoEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neo = Theme.of(context).extension<NeoTheme>()!;
    return Scaffold(
      backgroundColor: neo.editorBg,
      body: Column(
        children: [
          WindowTitleBar(neoTheme: neo),
          Expanded(child: const HomeScreen()),
        ],
      ),
    );
  }
}

class WindowTitleBar extends StatelessWidget {
  final NeoTheme neoTheme;

  const WindowTitleBar({super.key, required this.neoTheme});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 48.0,
        decoration: BoxDecoration(color: neoTheme.titleBarBg),
        child: Row(
          children: [
            const SizedBox(width: 16.0),
            Icon(Icons.code, size: 20.0, color: neoTheme.textPrimary),
            const SizedBox(width: 12.0),
            Text(
              t.ui.titleBar.title,
              style: TextStyle(
                color: neoTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const WindowButtons(),
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        WindowCaptionButton.minimize(
          brightness: brightness,
          onPressed: () async => windowManager.minimize(),
        ),
        WindowCaptionButton.maximize(
          brightness: brightness,
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        WindowCaptionButton.close(
          brightness: brightness,
          onPressed: () async => windowManager.close(),
        ),
      ],
    );
  }
}
