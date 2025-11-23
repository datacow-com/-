import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

/// Service for managing window properties and mouse pass-through
class WindowService {
  static const MethodChannel _channel = MethodChannel('com.teleprompter/window');
  
  bool _isMousePassThroughEnabled = false;
  
  bool get isMousePassThroughEnabled => _isMousePassThroughEnabled;
  
  /// Initialize window with transparent, borderless, always-on-top settings
  Future<void> initialize() async {
    await windowManager.ensureInitialized();
    
    final windowOptions = WindowOptions(
      size: const Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent, // Start with transparent, will be set based on mode
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
    });
    
    // Platform-specific initialization
    if (Platform.isMacOS) {
      await _initializeMacOS();
    }
  }
  
  /// Initialize macOS-specific window settings
  Future<void> _initializeMacOS() async {
    try {
      // Wait a bit to ensure window is fully created
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Make the window transparent (but keep it visible for control panel)
      await WindowManipulator.makeTitlebarTransparent();
      await WindowManipulator.hideTitle();
      
      // Enable full-size content view
      WindowManipulator.enableFullSizeContentView();
    } catch (e) {
      debugPrint('Error initializing macOS window: $e');
    }
  }
  
  /// Toggle mouse pass-through (click-through) functionality
  Future<void> toggleMousePassThrough(bool enabled) async {
    _isMousePassThroughEnabled = enabled;
    
    if (Platform.isMacOS) {
      try {
        if (enabled) {
          await WindowManipulator.ignoreMouseEvents();
        } else {
          await WindowManipulator.acknowledgeMouseEvents();
        }
      } catch (e) {
        debugPrint('Error toggling mouse pass-through on macOS: $e');
      }
    } else if (Platform.isWindows) {
      try {
        await _channel.invokeMethod('setMousePassThrough', enabled);
      } catch (e) {
        debugPrint('Error toggling mouse pass-through on Windows: $e');
      }
    }
  }
  
  /// Set window opacity
  Future<void> setOpacity(double opacity) async {
    try {
      if (Platform.isWindows) {
        // Use method channel for Windows to ensure proper transparency
        await _channel.invokeMethod('setWindowOpacity', opacity.clamp(0.0, 1.0));
      } else {
        await windowManager.setOpacity(opacity.clamp(0.0, 1.0));
      }
    } catch (e) {
      debugPrint('Error setting window opacity: $e');
    }
  }
  
  /// Set window to always on top
  Future<void> setAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await windowManager.setAlwaysOnTop(alwaysOnTop);
    } catch (e) {
      debugPrint('Error setting always on top: $e');
    }
  }
  
  /// Set window size
  Future<void> setSize(Size size) async {
    try {
      await windowManager.setSize(size);
    } catch (e) {
      debugPrint('Error setting window size: $e');
    }
  }
  
  /// Set window position
  Future<void> setPosition(Offset position) async {
    try {
      await windowManager.setPosition(position);
    } catch (e) {
      debugPrint('Error setting window position: $e');
    }
  }
  
  /// Set window background color
  Future<void> setBackgroundColor(Color color) async {
    try {
      await windowManager.setBackgroundColor(color);
    } catch (e) {
      debugPrint('Error setting background color: $e');
    }
  }
}
