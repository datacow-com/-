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
    debugPrint('[WindowDebug] initialize() called');
    await windowManager.ensureInitialized();
    
    // Add debug listener
    windowManager.addListener(DebugWindowListener());
    
    // Set minimum size first to prevent window from being too small
    debugPrint('[WindowDebug] Setting minimum size to 800x600');
    await windowManager.setMinimumSize(const Size(800, 600));
    
    // Configure window manually to avoid race conditions with waitUntilReadyToShow
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    // await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    
    // Force size and position
    debugPrint('[WindowDebug] Forcing size to 1000x700');
    await windowManager.setSize(const Size(1000, 700));
    await windowManager.center();
    
    // Note: Window will be shown after first frame is rendered
    // via showWindowAfterFirstFrame() method
  }
  
  /// Show window after Flutter first frame is rendered
  /// Show window after Flutter first frame is rendered
  Future<void> showWindowAfterFirstFrame() async {
    debugPrint('[WindowDebug] showWindowAfterFirstFrame() called');
    try {
      // 1. Ensure minimum size first
      debugPrint('[WindowDebug] Ensuring minimum size 600x400');
      await windowManager.setMinimumSize(const Size(600, 400));
      
      // 2. Force size and position immediately
      await forceWindowSize();

      // 3. Show and focus
      debugPrint('[WindowDebug] Showing window');
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
      
      // 4. Start safety resize check loop
      // This handles cases where OS or window manager restores a bad size after show()
      startSafetyResizeCheck();
      
      // 5. Extra safety: One more force resize after a short delay
      Future.delayed(const Duration(milliseconds: 200), () {
         forceWindowSize();
      });
      
      debugPrint('[WindowService] Window shown with size: ${await windowManager.getSize()}');
    } catch (e) {
      debugPrint('[WindowService] Error in showWindowAfterFirstFrame: $e');
    }
  }

  /// Force window to a specific usable size
  Future<void> forceWindowSize() async {
    debugPrint('[WindowDebug] Forcing size to 1000x700');
    // Set size twice to be sure (sometimes first call is ignored during animation)
    await windowManager.setSize(const Size(1000, 700));
    await windowManager.center();
  }

  /// Periodically check and enforce window size for the first few seconds
  void startSafetyResizeCheck() {
    int checks = 0;
    // Check every 500ms for 3 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      checks++;
      
      try {
        final size = await windowManager.getSize();
        debugPrint('[WindowDebug] Safety check #$checks: ${size.width} x ${size.height}');
        
        if (size.width < 800 || size.height < 600) {
          debugPrint('[WindowDebug] Window too small! Forcing resize...');
          await forceWindowSize();
        }
      } catch (e) {
        debugPrint('[WindowDebug] Safety check error: $e');
      }
      
      // Stop after 6 checks (3 seconds)
      return checks < 6;
    });
  }
  
  /// Apply window settings after first frame is rendered
  /// This ensures Flutter view is ready before applying window properties
  Future<void> applyWindowSettingsAfterFirstFrame() async {
    // No-op: Window settings are handled by window_manager in initialize()
    // Removing WindowManipulator calls to prevent conflicts
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
        // Silent fail
      }
    } else if (Platform.isWindows) {
      try {
        await _channel.invokeMethod('setMousePassThrough', enabled);
      } catch (e) {
        rethrow;
      }
    }
  }
  
  /// Set window opacity
  Future<void> setOpacity(double opacity) async {
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    try {
      if (Platform.isWindows) {
        await _channel.invokeMethod('setWindowOpacity', clampedOpacity);
      } else {
        await windowManager.setOpacity(clampedOpacity);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Set window to always on top
  Future<void> setAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await windowManager.setAlwaysOnTop(alwaysOnTop);
      if (alwaysOnTop) {
        await windowManager.show();
        await windowManager.focus();
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Show and focus the window
  Future<void> showAndFocus() async {
    try {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Get window size
  Future<Size> getSize() async {
    return await windowManager.getSize();
  }

  /// Set window size
  Future<void> setSize(Size size) async {
    try {
      await windowManager.setSize(size);
    } catch (e) {
      debugPrint('Error setting window size: $e');
    }
  }
  
  /// Ensure window has minimum size, expand if smaller
  Future<void> ensureMinimumSize(Size minimumSize) async {
    try {
      final currentSize = await windowManager.getSize();
      if (currentSize.width < minimumSize.width || currentSize.height < minimumSize.height) {
        final newSize = Size(
          currentSize.width < minimumSize.width ? minimumSize.width : currentSize.width,
          currentSize.height < minimumSize.height ? minimumSize.height : currentSize.height,
        );
        await windowManager.setSize(newSize);
      }
    } catch (e) {
      // Silent fail - window size adjustment is not critical
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
  
  /// Close the window
  Future<void> close() async {
    await windowManager.close();
  }
}

/// Debug listener to track window events
class DebugWindowListener extends WindowListener {
  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    debugPrint('[WindowDebug] onWindowResize: ${size.width} x ${size.height}');
  }

  @override
  void onWindowMove() async {
    final pos = await windowManager.getPosition();
    debugPrint('[WindowDebug] onWindowMove: $pos');
  }

  @override
  void onWindowFocus() {
    debugPrint('[WindowDebug] onWindowFocus');
  }

  @override
  void onWindowBlur() {
    debugPrint('[WindowDebug] onWindowBlur');
  }
  
  @override
  void onWindowMaximize() {
    debugPrint('[WindowDebug] onWindowMaximize');
  }
  
  @override
  void onWindowUnmaximize() {
    debugPrint('[WindowDebug] onWindowUnmaximize');
  }
  
  @override
  void onWindowMinimize() {
    debugPrint('[WindowDebug] onWindowMinimize');
  }
  
  @override
  void onWindowRestore() {
    debugPrint('[WindowDebug] onWindowRestore');
  }
}
