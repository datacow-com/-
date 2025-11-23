import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/teleprompter_screen.dart';
import 'screens/control_panel_screen.dart';
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
        scaffoldBackgroundColor: Colors.transparent,
        primaryColor: Colors.blue,
        canvasColor: Colors.transparent,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        return KeyboardShortcutHandler(
          onToggleMode: provider.toggleMode,
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
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: provider.isControlMode
                ? const ControlPanelScreen()
                : const TeleprompterScreen(),
          ),
        );
      },
    );
  }
}
