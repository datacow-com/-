import 'package:flutter/material.dart';
import '../models/teleprompter_settings.dart';
import '../services/settings_service.dart';
import '../services/window_service.dart';

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
  
  // Getters
  TeleprompterSettings get settings => _settings;
  double get scrollPosition => _scrollPosition;
  bool get isScrolling => _isScrolling;
  bool get isControlMode => _settings.isControlMode;
  
  /// Initialize provider and load saved settings
  Future<void> initialize() async {
    _settings = await _settingsService.loadSettings();
    await _windowService.initialize();
    
    // Apply window opacity based on current mode
    // Control panel mode should have visible background (opacity > 0)
    // Teleprompter mode can be transparent
    if (_settings.isControlMode && _settings.windowOpacity == 0.0) {
      // Default to 1.0 (fully opaque) for control panel if not set
      await _windowService.setOpacity(1.0);
      _settings = _settings.copyWith(windowOpacity: 1.0);
    } else {
      await _windowService.setOpacity(_settings.windowOpacity);
    }
    
    // Set mouse pass-through based on mode
    await _windowService.toggleMousePassThrough(!_settings.isControlMode);
    
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
    
    // Adjust window opacity and size based on mode
    if (newMode) {
      // Control mode - ensure window is visible (opacity >= 0.5)
      if (_settings.windowOpacity < 0.5) {
        _settings = _settings.copyWith(windowOpacity: 1.0);
        await _windowService.setOpacity(1.0);
      }
      // Control mode - larger window
      await _windowService.setSize(const Size(800, 600));
    } else {
      // Teleprompter mode - can be transparent
      // Keep current opacity setting
      // Keep current size
    }
    
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
}
