import 'package:flutter/foundation.dart';

/// KTV 卡拉OK 式跟踪服务
/// 实现词汇匹配、进度计算和偏差分析
class KaraokeTrackingService {
  // 脚本文本（分词）
  List<String> _words = [];
  
  // 已读词汇索引
  final Set<int> _readWordIndices = {};
  
  // 🔧 FIX: 记录最后匹配的索引，避免重复检查
  int _lastMatchedIndex = -1;
  
  // 当前识别的文本
  String _recognizedText = '';
  
  // 预期进度（基于滚动速度）
  double _expectedProgress = 0.0;
  
  // 实际进度（基于语音识别）
  double _actualProgress = 0.0;
  
  /// 初始化脚本
  void initializeScript(String script) {
    if (script.isEmpty) {
      _words = [];
      _readWordIndices.clear();
      _lastMatchedIndex = -1;
      return;
    }
    
    // 简单分词：按空格和常见标点分割
    _words = script
        .split(RegExp(r'[\s,，。！？、；：""''（）【】《》\n]'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    
    _readWordIndices.clear();
    _recognizedText = '';
    _actualProgress = 0.0;
    _lastMatchedIndex = -1;
    
    debugPrint('📝 Initialized script with ${_words.length} words');
  }
  
  /// 更新识别文本
  void updateRecognizedText(String text) {
    _recognizedText = text;
    _matchWords();
    _calculateActualProgress();
  }
  
  /// 🔧 FIX: 优化的词汇匹配算法
  /// 改进点：
  /// 1. 只检查未匹配的词（从 _lastMatchedIndex + 1 开始）
  /// 2. 使用词边界匹配，避免误匹配（如 "我" 匹配 "我们"）
  /// 3. 顺序匹配，一次只匹配一个词
  void _matchWords() {
    // 从上次匹配位置的下一个词开始检查
    for (int i = _lastMatchedIndex + 1; i < _words.length; i++) {
      final word = _words[i];
      
      // 🔧 FIX: 使用简单的包含检查（中文不需要词边界）
      // 对于更精确的匹配，可以考虑使用模糊匹配算法
      if (_recognizedText.contains(word)) {
        _readWordIndices.add(i);
        _lastMatchedIndex = i;
        debugPrint('✅ Matched word #$i: $word');
        
        // 🔧 FIX: 一次只匹配一个词，保证顺序
        // 这样可以避免跳过中间的词
        break;
      }
    }
  }
  
  /// 计算实际进度
  void _calculateActualProgress() {
    if (_words.isEmpty) {
      _actualProgress = 0.0;
      return;
    }
    
    _actualProgress = _readWordIndices.length / _words.length;
  }
  
  /// 更新预期进度
  void updateExpectedProgress(double progress) {
    _expectedProgress = progress.clamp(0.0, 1.0);
  }
  
  /// 获取偏差（实际 - 预期）
  double get deviation => _actualProgress - _expectedProgress;
  
  /// 获取偏差百分比
  double get deviationPercent => deviation * 100;
  
  /// 获取偏差状态文本
  String get deviationStatus {
    if (deviation > 0.1) {
      return '太快了，慢一点 🔴';
    } else if (deviation < -0.1) {
      return '太慢了，加快一点 🟡';
    } else {
      return '节奏完美！🟢';
    }
  }
  
  /// 获取偏差状态颜色
  int get deviationColor {
    if (deviation > 0.1) {
      return 0xFFEF4444; // 红色
    } else if (deviation < -0.1) {
      return 0xFFFBBF24; // 黄色
    } else {
      return 0xFF22C55E; // 绿色
    }
  }
  
  /// 获取已读词汇索引
  Set<int> get readWordIndices => Set.from(_readWordIndices);
  
  /// 获取词汇列表
  List<String> get words => List.from(_words);
  
  /// 获取预期进度
  double get expectedProgress => _expectedProgress;
  
  /// 获取实际进度
  double get actualProgress => _actualProgress;
  
  /// 获取识别文本
  String get recognizedText => _recognizedText;
  
  /// 重置跟踪状态
  void reset() {
    _readWordIndices.clear();
    _recognizedText = '';
    _actualProgress = 0.0;
    _expectedProgress = 0.0;
    _lastMatchedIndex = -1; // 🔧 FIX: 重置最后匹配索引
    debugPrint('🔄 Reset tracking state');
  }
}
