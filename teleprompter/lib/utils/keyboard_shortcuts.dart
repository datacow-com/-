import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcuts for the teleprompter
class KeyboardShortcuts {
  /// Toggle between teleprompter and control mode
  static const toggleMode = SingleActivator(
    LogicalKeyboardKey.keyT,
    meta: true, // Command on macOS
    control: true, // Ctrl on Windows
  );
  
  /// Play/Pause scrolling
  static const playPause = SingleActivator(LogicalKeyboardKey.space);
  
  /// Reset scroll to top
  static const reset = SingleActivator(LogicalKeyboardKey.keyR);
  
  /// Increase font size
  static const increaseFontSize = SingleActivator(
    LogicalKeyboardKey.equal,
    meta: true,
    control: true,
  );
  
  /// Decrease font size
  static const decreaseFontSize = SingleActivator(
    LogicalKeyboardKey.minus,
    meta: true,
    control: true,
  );
  
  /// Increase scroll speed
  static const increaseSpeed = SingleActivator(LogicalKeyboardKey.arrowUp);
  
  /// Decrease scroll speed
  static const decreaseSpeed = SingleActivator(LogicalKeyboardKey.arrowDown);
}

/// Widget that handles keyboard shortcuts
class KeyboardShortcutHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback onToggleMode;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;
  final VoidCallback onIncreaseFontSize;
  final VoidCallback onDecreaseFontSize;
  final VoidCallback onIncreaseSpeed;
  final VoidCallback onDecreaseSpeed;
  
  const KeyboardShortcutHandler({
    super.key,
    required this.child,
    required this.onToggleMode,
    required this.onPlayPause,
    required this.onReset,
    required this.onIncreaseFontSize,
    required this.onDecreaseFontSize,
    required this.onIncreaseSpeed,
    required this.onDecreaseSpeed,
  });
  
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        KeyboardShortcuts.toggleMode: onToggleMode,
        KeyboardShortcuts.playPause: onPlayPause,
        KeyboardShortcuts.reset: onReset,
        KeyboardShortcuts.increaseFontSize: onIncreaseFontSize,
        KeyboardShortcuts.decreaseFontSize: onDecreaseFontSize,
        KeyboardShortcuts.increaseSpeed: onIncreaseSpeed,
        KeyboardShortcuts.decreaseSpeed: onDecreaseSpeed,
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
