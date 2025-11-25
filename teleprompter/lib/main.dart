import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/teleprompter_provider.dart';
import 'screens/preparation_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize window manager
    await windowManager.ensureInitialized();
    
    // Load saved window state
    final prefs = await SharedPreferences.getInstance();
    final double? savedX = prefs.getDouble('window_x');
    final double? savedY = prefs.getDouble('window_y');
    final double? savedWidth = prefs.getDouble('window_width');
    final double? savedHeight = prefs.getDouble('window_height');
    
    WindowOptions windowOptions = WindowOptions(
      size: Size(savedWidth ?? 800, savedHeight ?? 600),
      center: savedX == null, // Center if no saved position
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Teleprompter Pro',
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      
      if (savedX != null && savedY != null) {
        await windowManager.setPosition(Offset(savedX, savedY));
      }
    });
    
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('🔴 Global Error: $error');
    debugPrint('Stack trace: $stack');
    // In production, report to crash reporting service
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeleprompterProvider(),
      child: MaterialApp(
        title: 'Teleprompter Pro',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppTheme.background,
          primaryColor: AppTheme.accent,
          fontFamily: 'SF Pro',
        ),
        home: const PreparationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
