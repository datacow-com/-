import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teleprompter_settings.dart';
import '../services/speech_recognition_service.dart';
import '../services/karaoke_tracking_service.dart';

/// 简化版 Provider - 只保留核心功能 + KTV 跟踪
class TeleprompterProvider extends ChangeNotifier {
  TeleprompterSettings _settings = const TeleprompterSettings();
  double _scrollPosition = 0.0;
  bool _isScrolling = false;

  // Speech recognition and karaoke tracking
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final KaraokeTrackingService _trackingService = KaraokeTrackingService();
  bool _isTrackingEnabled = false;

  // Getters
  TeleprompterSettings get settings => _settings;
  double get scrollPosition => _scrollPosition;
  bool get isScrolling => _isScrolling;
  bool get isTrackingEnabled => _isTrackingEnabled;
  KaraokeTrackingService get trackingService => _trackingService;
  SpeechRecognitionService get speechService => _speechService;

  /// 初始化语音识别
  Future<bool> initializeSpeechRecognition() async {
    final success = await _speechService.initialize();
    if (success && _settings.text.isNotEmpty) {
      _trackingService.initializeScript(_settings.text);
    }
    return success;
  }

  /// 开始 KTV 跟踪
  Future<void> startTracking() async {
    if (!_speechService.isInitialized) {
      final success = await initializeSpeechRecognition();
      if (!success) {
        debugPrint('⚠️ Failed to initialize speech recognition');
        return;
      }
    }

    _isTrackingEnabled = true;
    await _speechService.startListening(
      onResult: (text) {
        _trackingService.updateRecognizedText(text);
        notifyListeners();
      },
    );
    notifyListeners();
  }

  /// 停止 KTV 跟踪
  Future<void> stopTracking() async {
    _isTrackingEnabled = false;
    await _speechService.stopListening();
    notifyListeners();
  }

  /// 更新文本
  Future<void> updateText(String text) async {
    _settings = _settings.copyWith(text: text);
    if (_isTrackingEnabled) {
      _trackingService.initializeScript(text);
    }
    
    // 自动保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_script', text);
    
    notifyListeners();
  }

  /// 加载上次的脚本
  Future<void> loadLastScript() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScript = prefs.getString('last_script');
    if (lastScript != null && lastScript.isNotEmpty) {
      _settings = _settings.copyWith(text: lastScript);
      notifyListeners();
    }
  }

  /// 切换自动滚动
  void toggleAutoScroll() {
    _isScrolling = !_isScrolling;
    notifyListeners();
  }

  /// 暂停滚动
  void pauseScrolling() {
    _isScrolling = false;
    notifyListeners();
  }

  /// 重置滚动位置
  void resetScroll() {
    _scrollPosition = 0.0;
    _isScrolling = false;
    _trackingService.reset();
    notifyListeners();
  }

  /// 更新滚动位置
  void updateScrollPosition(double position) {
    _scrollPosition = position;
    _trackingService.updateExpectedProgress(position);
    notifyListeners();
  }

  /// 更新滚动速度
  void updateScrollSpeed(double speed) {
    _settings = _settings.copyWith(scrollSpeed: speed);
    notifyListeners();
  }

  /// 更新字号
  void updateFontSize(double fontSize) {
    _settings = _settings.copyWith(fontSize: fontSize);
    notifyListeners();
  }

  /// 更新场景模式
  void updateSceneMode(SceneMode mode) {
    _settings = _settings.copyWith(sceneMode: mode);
    notifyListeners();
  }

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }
}
