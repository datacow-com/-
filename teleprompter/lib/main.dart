import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/teleprompter_provider.dart';
import 'services/settings_service.dart';
import 'services/window_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final settingsService = SettingsService();
  final windowService = WindowService();
  
  // Create provider
  final provider = TeleprompterProvider(
    settingsService: settingsService,
    windowService: windowService,
  );
  
  // Initialize provider (loads settings and configures window)
  await provider.initialize();
  
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const TeleprompterApp(),
    ),
  );
}
