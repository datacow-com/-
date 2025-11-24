import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/teleprompter_provider.dart';
import 'services/settings_service.dart';
import 'services/window_service.dart';

import 'services/debug_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Debug Logger
  final logger = DebugLogger();
  await logger.initialize();
  
  // Catch Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    logger.logError(details.exception, details.stack);
  };
  
  // Initialize services
  final settingsService = SettingsService();
  final windowService = WindowService();
  
  // Create provider
  final provider = TeleprompterProvider(
    settingsService: settingsService,
    windowService: windowService,
  );
  
  // Initialize window service first - this must complete before runApp
  await windowService.initialize();
  
  // Run app - this creates the Flutter view
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const TeleprompterApp(),
    ),
  );
  
  // Initialize provider after runApp - this ensures Flutter view is ready
  // Use addPostFrameCallback to ensure first frame is rendered
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await provider.initialize();
  });
}
