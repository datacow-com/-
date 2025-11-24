import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyService {
  static final HotkeyService _instance = HotkeyService._internal();
  factory HotkeyService() => _instance;
  HotkeyService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await hotKeyManager.unregisterAll();
    _isInitialized = true;
  }
  
  Future<void> registerToggleHotkey(VoidCallback onToggle) async {
    debugPrint('Registering toggle hotkey...');
    // Define the hotkey based on platform
    HotKey hotKey;
    
    if (Platform.isMacOS) {
      // Cmd + T
      hotKey = HotKey(
        key: LogicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.meta],
        scope: HotKeyScope.system,
      );
    } else {
      // Ctrl + T (Windows/Linux)
      hotKey = HotKey(
        key: LogicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.system,
      );
    }
    
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) {
        debugPrint('Hotkey pressed!');
        onToggle();
      },
    );
    debugPrint('Hotkey registered successfully: $hotKey');
  }
  
  Future<void> unregisterAll() async {
    await hotKeyManager.unregisterAll();
  }
}
