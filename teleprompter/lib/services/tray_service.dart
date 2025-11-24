import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class TrayService {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  
  bool _isInitialized = false;

  Future<void> initialize({
    required VoidCallback onToggleVisibility,
    required VoidCallback onQuit,
  }) async {
    if (_isInitialized) return;
    
    try {
      // Try to use app icon, but handle missing icon gracefully
      String? iconPath;
      if (Platform.isWindows) {
        iconPath = 'assets/app_icon.ico';
      } else if (Platform.isMacOS) {
        iconPath = 'assets/app_icon.png';
      }
      
      // Initialize system tray with error handling
      try {
        await _systemTray.initSystemTray(
          title: "Teleprompter",
          iconPath: iconPath ?? '', // Empty string will use system default
          toolTip: "Invisible Teleprompter",
        );
        debugPrint('[TrayService] System tray initialized successfully');
      } catch (e) {
        // If icon path fails, try without icon path (system default)
        debugPrint('[TrayService] Failed to initialize with icon, trying without: $e');
        try {
          await _systemTray.initSystemTray(
            title: "Teleprompter",
            iconPath: '', // Use system default
            toolTip: "Invisible Teleprompter",
          );
          debugPrint('[TrayService] System tray initialized with default icon');
        } catch (e2) {
          debugPrint('[TrayService] Failed to initialize system tray: $e2');
          // Continue without system tray - app can still function
          return;
        }
      }

      final Menu menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Show/Hide',
          onClicked: (menuItem) => onToggleVisibility(),
        ),
        MenuItemLabel(
          label: 'Quit',
          onClicked: (menuItem) => onQuit(),
        ),
      ]);

      await _systemTray.setContextMenu(menu);

      // Handle left click on tray icon
      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          _appWindow.show();
          onToggleVisibility();
        } else if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        }
      });
      
      _isInitialized = true;
      debugPrint('[TrayService] System tray setup complete');
    } catch (e) {
      debugPrint('[TrayService] Error initializing system tray: $e');
      // Don't throw - allow app to continue without system tray
    }
  }
}
