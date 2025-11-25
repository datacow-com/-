import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teleprompter_settings.dart';
import '../models/speech_history.dart';
import '../services/speech_recognition_service.dart';
import '../services/karaoke_tracking_service.dart';
import '../services/database_service.dart';

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

  /// 加载设置
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load script text
    final lastScript = prefs.getString('last_script');
    
    // Load other settings
    final fontSize = prefs.getDouble('font_size');
    final scrollSpeed = prefs.getDouble('scroll_speed');
    final sceneModeIndex = prefs.getInt('scene_mode');
    
    _settings = _settings.copyWith(
      text: lastScript ?? _settings.text,
      fontSize: fontSize ?? _settings.fontSize,
      scrollSpeed: scrollSpeed ?? _settings.scrollSpeed,
      sceneMode: sceneModeIndex != null 
          ? SceneMode.values[sceneModeIndex] 
          : _settings.sceneMode,
    );
    
    notifyListeners();
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_script', _settings.text);
    await prefs.setDouble('font_size', _settings.fontSize);
    await prefs.setDouble('scroll_speed', _settings.scrollSpeed);
    await prefs.setInt('scene_mode', _settings.sceneMode.index);
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
    _saveSettings();
    notifyListeners();
  }

  /// 更新字号
  void updateFontSize(double fontSize) {
    _settings = _settings.copyWith(fontSize: fontSize);
    _saveSettings();
    notifyListeners();
  }

  /// 更新场景模式
  void updateSceneMode(SceneMode mode) {
    _settings = _settings.copyWith(sceneMode: mode);
    _saveSettings();
    notifyListeners();
  }

  /// 恢复默认设置
  Future<void> resetSettings() async {
    _settings = const TeleprompterSettings();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('font_size');
    await prefs.remove('scroll_speed');
    await prefs.remove('scene_mode');
    // 保留 last_script 以防误删
    
    notifyListeners();
  }

  /// 保存演讲历史
  Future<void> saveSpeechHistory({
    required int durationSeconds,
    required int wordCount,
    required int score,
  }) async {
    // 获取脚本标题（前20个字）
    String title = _settings.text.trim();
    if (title.length > 20) {
      title = '${title.substring(0, 20)}...';
    } else if (title.isEmpty) {
      title = '未命名演讲';
    }

    final history = SpeechHistory(
      timestamp: DateTime.now(),
      durationSeconds: durationSeconds,
      wordCount: wordCount,
      score: score,
      scriptTitle: title,
      ktvDeviation: _isTrackingEnabled ? _trackingService.deviation : 0.0,
    );

    await DatabaseService().insertHistory(history);
    notifyListeners();
  }

  /// 获取最近的历史记录
  Future<List<SpeechHistory>> getHistory({int limit = 20}) async {
    return await DatabaseService().getRecentHistory(limit: limit);
  }

  /// 删除历史记录
  Future<void> deleteHistory(int id) async {
    await DatabaseService().deleteHistory(id);
    notifyListeners();
  }

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }
}
