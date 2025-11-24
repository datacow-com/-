import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

/// 语音识别服务
/// 使用 speech_to_text 插件实现实时语音识别
class SpeechRecognitionService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  
  /// 初始化语音识别
  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('❌ Speech error: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('📊 Speech status: $status');
        },
      );
      
      if (_isInitialized) {
        debugPrint('✅ Speech recognition initialized successfully');
      } else {
        debugPrint('❌ Speech recognition initialization failed');
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('❌ Speech initialization error: $e');
      return false;
    }
  }
  
  /// 开始监听
  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'zh_CN',
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Speech not initialized, cannot start listening');
      return;
    }
    
    try {
      await _speech.listen(
        onResult: (result) {
          // 只处理最终结果，避免过多更新
          if (result.finalResult || result.recognizedWords.isNotEmpty) {
            debugPrint('🎤 Recognized: ${result.recognizedWords}');
            onResult(result.recognizedWords);
          }
        },
        listenMode: ListenMode.dictation, // 持续监听模式
        partialResults: true, // 启用实时结果
        localeId: localeId, // 语言设置
        cancelOnError: false, // 出错时不取消
        listenFor: const Duration(minutes: 30), // 最长监听30分钟
      );
      
      debugPrint('🎙️ Started listening...');
    } catch (e) {
      debugPrint('❌ Start listening error: $e');
    }
  }
  
  /// 停止监听
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      debugPrint('🛑 Stopped listening');
    } catch (e) {
      debugPrint('❌ Stop listening error: $e');
    }
  }
  
  /// 是否正在监听
  bool get isListening => _speech.isListening;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 获取可用的语言列表
  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) return [];
    
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }
}
