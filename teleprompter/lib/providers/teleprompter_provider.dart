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

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
    // Auto-clear error after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      clearError();
    });
  }

  /// 初始化语音识别
  Future<bool> initializeSpeechRecognition() async {
    try {
      final success = await _speechService.initialize();
      if (success && _settings.text.isNotEmpty) {
        _trackingService.initializeScript(_settings.text);
      } else if (!success) {
        _setError('无法初始化语音识别，请检查麦克风权限');
      }
      return success;
    } catch (e) {
      _setError('语音识别初始化失败: $e');
      return false;
    }
  }

  /// 开始 KTV 跟踪
  Future<void> startTracking() async {
    try {
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
    } catch (e) {
      _setError('无法开始语音跟踪: $e');
      _isTrackingEnabled = false;
      notifyListeners();
    }
  }

  /// 停止 KTV 跟踪
  Future<void> stopTracking() async {
    try {
      _isTrackingEnabled = false;
      await _speechService.stopListening();
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping tracking: $e');
    }
  }

  /// 更新文本
  Future<void> updateText(String text) async {
    try {
      _settings = _settings.copyWith(text: text);
      if (_isTrackingEnabled) {
        _trackingService.initializeScript(text);
      }
      
      // 自动保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_script', text);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating text: $e');
    }
  }

  /// 加载设置
  Future<void> loadSettings() async {
    try {
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
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_script', _settings.text);
      await prefs.setDouble('font_size', _settings.fontSize);
      await prefs.setDouble('scroll_speed', _settings.scrollSpeed);
      await prefs.setInt('scene_mode', _settings.sceneMode.index);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // ... (scroll methods remain same)

  /// 保存演讲历史
  Future<void> saveSpeechHistory({
    required int durationSeconds,
    required int wordCount,
    required int score,
  }) async {
    try {
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
    } catch (e) {
      _setError('保存历史记录失败: $e');
    }
  }

  /// 获取最近的历史记录
  Future<List<SpeechHistory>> getHistory({int limit = 20}) async {
    try {
      return await DatabaseService().getRecentHistory(limit: limit);
    } catch (e) {
      _setError('获取历史记录失败: $e');
      return [];
    }
  }

  /// 删除历史记录
  Future<void> deleteHistory(int id) async {
    try {
      await DatabaseService().deleteHistory(id);
      notifyListeners();
    } catch (e) {
      _setError('删除历史记录失败: $e');
    }
  }

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }
}
