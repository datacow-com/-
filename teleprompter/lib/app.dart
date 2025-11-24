import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'screens/editor_screen.dart';
import 'screens/prompter_screen.dart';
import 'providers/teleprompter_provider.dart';
import 'utils/keyboard_shortcuts.dart';

class TeleprompterApp extends StatelessWidget {
  const TeleprompterApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teleprompter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: Colors.blue,
        canvasColor: const Color(0xFF1E1E1E),
      ),
      initialRoute: AppRoutes.editor,
      routes: {
        AppRoutes.editor: (context) => const EditorScreenRoute(),
        AppRoutes.prompter: (context) => const PrompterScreenRoute(),
      },
    );
  }
}

/// Wrapper for Editor screen with keyboard shortcuts
class EditorScreenRoute extends StatelessWidget {
  const EditorScreenRoute({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        // Sync provider state with current route
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!provider.isControlMode) {
            provider.enterEditorMode();
          }
        });
        
        return KeyboardShortcutHandler(
          onToggleMode: () {
            Navigator.pushNamed(context, AppRoutes.prompter);
          },
          onPlayPause: () {
            if (provider.isScrolling) {
              provider.pauseScrolling();
            } else {
              provider.startScrolling();
            }
          },
          onReset: provider.resetScroll,
          onIncreaseFontSize: () {
            final newSize = (provider.settings.fontSize + 2).clamp(20.0, 120.0);
            provider.updateFontSize(newSize);
          },
          onDecreaseFontSize: () {
            final newSize = (provider.settings.fontSize - 2).clamp(20.0, 120.0);
            provider.updateFontSize(newSize);
          },
          onIncreaseSpeed: () {
            final newSpeed = (provider.settings.scrollSpeed + 5).clamp(10.0, 200.0);
            provider.updateScrollSpeed(newSpeed);
          },
          onDecreaseSpeed: () {
            final newSpeed = (provider.settings.scrollSpeed - 5).clamp(10.0, 200.0);
            provider.updateScrollSpeed(newSpeed);
          },
          child: const EditorScreen(),
        );
      },
    );
  }
}

/// Wrapper for Prompter screen with keyboard shortcuts
class PrompterScreenRoute extends StatefulWidget {
  const PrompterScreenRoute({Key? key}) : super(key: key);

  @override
  State<PrompterScreenRoute> createState() => _PrompterScreenRouteState();
}

class _PrompterScreenRouteState extends State<PrompterScreenRoute> {
  @override
  void initState() {
    super.initState();
    // Auto-start scrolling when entering prompter mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TeleprompterProvider>(context, listen: false);
      provider.enterPrompterMode();
      
      // Auto-start after brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !provider.isScrolling) {
          provider.toggleAutoScroll();
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        return KeyboardShortcutHandler(
          onToggleMode: () {
            Navigator.pop(context);
          },
          onPlayPause: () {
            if (provider.isScrolling) {
              provider.pauseScrolling();
            } else {
              provider.startScrolling();
            }
          },
          onReset: provider.resetScroll,
          onIncreaseFontSize: () {
            final newSize = (provider.settings.fontSize + 2).clamp(20.0, 120.0);
            provider.updateFontSize(newSize);
          },
          onDecreaseFontSize: () {
            final newSize = (provider.settings.fontSize - 2).clamp(20.0, 120.0);
            provider.updateFontSize(newSize);
          },
          onIncreaseSpeed: () {
            final newSpeed = (provider.settings.scrollSpeed + 5).clamp(10.0, 200.0);
            provider.updateScrollSpeed(newSpeed);
          },
          onDecreaseSpeed: () {
            final newSpeed = (provider.settings.scrollSpeed - 5).clamp(10.0, 200.0);
            provider.updateScrollSpeed(newSpeed);
          },
          child: const PrompterScreen(),
        );
      },
    );
  }
}
