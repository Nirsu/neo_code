import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de window_manager pour la fenêtre native
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // Rend la fenêtre frameless
    title: 'Neo Code',
  );

  // Remplace la fenêtre par défaut et attend qu'elle soit rendue avant de l'afficher
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Lancement de l'application englobée dans un ProviderScope pour Riverpod
  runApp(const ProviderScope(child: NeoCodeApp()));
}

class NeoCodeApp extends StatelessWidget {
  const NeoCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neo Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const NeoEditorScreen(),
    );
  }
}

class NeoEditorScreen extends ConsumerWidget {
  const NeoEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Barre de titre personnalisée pour pouvoir déplacer la fenêtre "frameless"
          const WindowTitleBar(),
          
          Expanded(
            child: Center(
              child: Text(
                'Bienvenue dans Neo Code\nL\'interface frameless est prête !',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de titre native personnalisée
class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    // DragToMoveArea permet aux utilisateurs de faire glisser la fenêtre 
    // en maintenant le clic sur la barre, ce qui est nécessaire sans la barre standard de l'OS.
    return DragToMoveArea(
      child: Container(
        height: 48.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16.0),
            const Icon(Icons.code, size: 20.0),
            const SizedBox(width: 12.0),
            Text(
              'Neo Code',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            // Fenêtre de contrôles natifs Windows (réduire, agrandir, fermer)
            const WindowButtons(),
          ],
        ),
      ),
    );
  }
}

/// Les boutons de fenêtre (réduire, fermer, etc.)
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
