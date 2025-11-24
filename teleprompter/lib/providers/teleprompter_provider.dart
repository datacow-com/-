import 'package:flutter/material.dart';
import '../models/teleprompter_settings.dart';
import '../services/settings_service.dart';
import '../services/window_service.dart';
import '../services/hotkey_service.dart';
import '../services/tray_service.dart';
import '../services/debug_logger.dart';

/// Provider for managing teleprompter state
class TeleprompterProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  final WindowService _windowService;
  
  TeleprompterSettings _settings = const TeleprompterSettings();
  double _scrollPosition = 0.0;
  bool _isScrolling = false;
  
  TeleprompterProvider({
    required SettingsService settingsService,
    required WindowService windowService,
  })  : _settingsService = settingsService,
        _windowService = windowService;
        
  final _debugLogger = DebugLogger();
  
  // Getters
  TeleprompterSettings get settings => _settings;
  double get scrollPosition => _scrollPosition;
  bool get isScrolling => _isScrolling;
  bool get isControlMode => _settings.isControlMode;
  
  /// Initialize provider and load saved settings
  Future<void> initialize() async {
    _settings = await _settingsService.loadSettings();
    
    // Always start in control mode to ensure control panel is visible
    // Force control mode regardless of saved settings
    _settings = _settings.copyWith(isControlMode: true);
    
    // Wait for first frame to be rendered before showing window
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Show window after Flutter view is ready
      await _windowService.showWindowAfterFirstFrame();
      
      // Control mode - ensure window is clearly visible
      if (_settings.isControlMode) {
        if (_settings.windowOpacity < 0.8) {
          await _windowService.setOpacity(1.0);
          _settings = _settings.copyWith(windowOpacity: 1.0);
        } else {
          await _windowService.setOpacity(_settings.windowOpacity);
        }
        // Window size is handled by showWindowAfterFirstFrame
      } else {
        await _windowService.setOpacity(_settings.windowOpacity);
        // Ensure minimum size for teleprompter mode too
        await _windowService.ensureMinimumSize(const Size(600, 400));
      }
      
      // Set mouse pass-through based on mode
      await _windowService.toggleMousePassThrough(!_settings.isControlMode);
      
      // Apply macOS-specific window settings after first frame
      await _windowService.applyWindowSettingsAfterFirstFrame();
      
      // Initialize Hotkey Service
      final hotkeyService = HotkeyService();
      await hotkeyService.initialize();
      await hotkeyService.registerToggleHotkey(() {
        toggleMode();
      });
      
      // Initialize System Tray
      final trayService = TrayService();
      await trayService.initialize(
        onToggleVisibility: () {
          _windowService.setAlwaysOnTop(true);
          toggleMode();
        },
        onQuit: () {
          _windowService.close();
        },
      );
      
      // Notify listeners to trigger UI update
      notifyListeners();
      
      // Safety check: Force resize if window is too small after 1 second
      // This handles cases where window_manager might have restored a small size
      Future.delayed(const Duration(seconds: 1), () async {
        debugPrint('[WindowDebug] Running safety check (1s delay)');
        if (_settings.isControlMode) {
          final size = await _windowService.getSize(); // We need to expose getSize in WindowService or use windowManager directly
          // Since we can't easily get size from _windowService without modifying it, we'll just log and force
          debugPrint('[WindowDebug] Forcing size in safety check');
          await _windowService.ensureMinimumSize(const Size(1000, 700));
        }
      });
    });
    
    // Notify listeners immediately to trigger UI build
    notifyListeners();
  }
  
  /// Update text content
  void updateText(String text) {
    _settings = _settings.copyWith(text: text);
    _saveSettings();
    notifyListeners();
  }
  
  /// Update font size
  void updateFontSize(double fontSize) {
    _settings = _settings.copyWith(fontSize: fontSize);
    _saveSettings();
    notifyListeners();
  }
  
  /// Update text color
  void updateTextColor(Color color) {
    _settings = _settings.copyWith(textColor: color);
    _saveSettings();
    notifyListeners();
  }
  
  /// Update scroll speed
  void updateScrollSpeed(double speed) {
    _settings = _settings.copyWith(scrollSpeed: speed);
    _saveSettings();
    notifyListeners();
  }
  
  /// Update window opacity
  void updateWindowOpacity(double opacity) {
    _settings = _settings.copyWith(windowOpacity: opacity);
    _windowService.setOpacity(opacity);
    _saveSettings();
    notifyListeners();
  }
  
  /// Update text opacity
  void updateTextOpacity(double opacity) {
    _settings = _settings.copyWith(textOpacity: opacity);
    _saveSettings();
    notifyListeners();
  }
  
  /// Toggle auto-scroll
  void toggleAutoScroll() {
    _settings = _settings.copyWith(autoScroll: !_settings.autoScroll);
    _isScrolling = _settings.autoScroll;
    _saveSettings();
    notifyListeners();
  }
  
  /// Start scrolling
  void startScrolling() {
    _isScrolling = true;
    _settings = _settings.copyWith(autoScroll: true);
    notifyListeners();
  }
  
  /// Pause scrolling
  void pauseScrolling() {
    _isScrolling = false;
    _settings = _settings.copyWith(autoScroll: false);
    notifyListeners();
  }
  
  /// Reset scroll position to top
  void resetScroll() {
    _scrollPosition = 0.0;
    notifyListeners();
  }
  
  /// Update scroll position
  void updateScrollPosition(double position) {
    _scrollPosition = position;
    notifyListeners();
  }
  
  /// Toggle between control mode and teleprompter mode
  Future<void> toggleMode() async {
    final newMode = !_settings.isControlMode;
    _settings = _settings.copyWith(isControlMode: newMode);
    
    // Enable mouse pass-through in teleprompter mode
    await _windowService.toggleMousePassThrough(!newMode);
    
    // Adjust window opacity based on mode
    if (newMode) {
      // Control mode - ensure window is clearly visible
      if (_settings.windowOpacity < 0.8) {
        _settings = _settings.copyWith(windowOpacity: 1.0);
        await _windowService.setOpacity(1.0);
      } else {
        await _windowService.setOpacity(_settings.windowOpacity);
      }
      await _windowService.setAlwaysOnTop(true);
    } else {
      // Teleprompter mode - can be transparent
      await _windowService.setOpacity(_settings.windowOpacity);
    }
    
    _saveSettings();
    notifyListeners();
  }
  
  /// Enter editor mode explicitly
  Future<void> enterEditorMode() async {
    if (_settings.isControlMode) return; // Already in editor mode
    
    _settings = _settings.copyWith(isControlMode: true);
    
    // Control mode - ensure window is clearly visible
    if (_settings.windowOpacity < 0.8) {
      _settings = _settings.copyWith(windowOpacity: 1.0);
      await _windowService.setOpacity(1.0);
    } else {
      await _windowService.setOpacity(_settings.windowOpacity);
    }
    await _windowService.setAlwaysOnTop(true);
    await _windowService.toggleMousePassThrough(false);
    
    _saveSettings();
    notifyListeners();
  }

  /// Enter prompter mode explicitly
  Future<void> enterPrompterMode() async {
    if (!_settings.isControlMode) return; // Already in prompter mode
    
    _settings = _settings.copyWith(isControlMode: false);
    
    // Teleprompter mode - can be transparent
    await _windowService.setOpacity(_settings.windowOpacity);
    await _windowService.toggleMousePassThrough(true);
    
    _saveSettings();
    notifyListeners();
  }
  
  /// Save settings to persistent storage
  Future<void> _saveSettings() async {
    await _settingsService.saveSettings(_settings);
  }
  
  /// Load text from file
  void loadTextFromFile(String filePath) {
    // This will be implemented when file picker is used
    // For now, just a placeholder
    notifyListeners();
  }
  
  /// Clear all text
  void clearText() {
    _settings = _settings.copyWith(text: '');
    _saveSettings();
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _logState();
  }

  void _logState() {
    debugPrint('[DebugLogger] Logging state: isControlMode=${_settings.isControlMode}, windowOpacity=${_settings.windowOpacity}');
    _debugLogger.logState('settings', _settings.toJson());
    _debugLogger.logState('isScrolling', _isScrolling);
    _debugLogger.logState('scrollPosition', _scrollPosition);
  }
}
