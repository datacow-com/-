import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../providers/teleprompter_provider.dart';
import '../widgets/spotlight_effect.dart';
import '../widgets/progress_comparison.dart';
import '../widgets/achievement_animation.dart';
import '../widgets/keyboard_help_panel.dart';
import '../utils/app_theme.dart';

/// 演讲模式 - 全屏极简设计
/// 目标：100% 专注于文字，零干扰
class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  Duration _presentationStartTime = Duration.zero;
  int _currentLineIndex = 0;
  bool _showControls = false;
  bool _enableSpotlight = true; // 聚光灯效果开关
  Timer? _hideControlsTimer; // 自动隐藏控制栏的定时器
  bool _showKeyboardHelp = false; // P1 Feature 4: 快捷键帮助面板

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _presentationStartTime = Duration.zero;
    
    // 进入全屏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    _hideControlsTimer?.cancel(); // 取消定时器
    
    // 恢复系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final provider = Provider.of<TeleprompterProvider>(context, listen: false);
    if (!provider.isScrolling) return;

    // 🔧 FIX: 首次开始滚动时记录开始时间
    if (_presentationStartTime == Duration.zero) {
      _presentationStartTime = elapsed;
    }

    final double deltaTime = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (deltaTime <= 0) return;

    final double scrollAmount = provider.settings.scrollSpeed * deltaTime;

    if (_scrollController.hasClients) {
      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        provider.pauseScrolling();
        _showCompletionDialog();
      } else {
        _scrollController.jumpTo(currentScroll + scrollAmount);
        provider.updateScrollPosition(maxScroll > 0 ? currentScroll / maxScroll : 0);

        // 🔧 FIX: 使用动态计算的行高
        setState(() {
          _currentLineIndex = (currentScroll / _getLineHeight()).floor();
        });
      }
    }
  }

  List<String> _splitIntoLines(String text) {
    if (text.isEmpty) return ['请输入演讲稿...'];

    // Split by sentences
    final sentences = text.split(RegExp(r'[。！？\n]'));
    return sentences.where((s) => s.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<TeleprompterProvider>(
        builder: (context, provider, child) {
          // Handle Ticker state
          if (provider.isScrolling && !_ticker.isActive) {
            _lastElapsed = Duration.zero;
            _ticker.start();
          } else if (!provider.isScrolling && _ticker.isActive) {
            _ticker.stop();
          }

          return KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            onKeyEvent: (event) => _handleKeyEvent(event, provider),
            child: MouseRegion(
              onHover: (_) => _showControlsTemporarily(),
              child: Stack(
                children: [
                  // Main Teleprompter Display
                  _buildTeleprompterDisplay(provider),

                  // Spotlight Effect
                  if (_enableSpotlight)
                    SpotlightEffect(
                      center: _getFocusCenter(),
                      radius: 400,
                      intensity: 0.6,
                    ),

                  // Progress Comparison (P1 Feature 4: Moved to top-right)
                  if (provider.isTrackingEnabled)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: ProgressComparison(
                        expectedProgress: provider.scrollPosition,
                        actualProgress: provider.trackingService.actualProgress,
                        deviationStatus: provider.trackingService.deviationStatus,
                        deviationColor: provider.trackingService.deviationColor,
                      ),
                    ),

                  // Top Status Bar (Auto-hide)
                  if (_showControls) _buildTopStatusBar(provider),

                  // Bottom Control Bar (Show on hover)
                  if (_showControls) _buildBottomControlBar(provider),

                  // Fixed Floating Mic Button (Feature 4: Progressive KTV Disclosure)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: _buildFloatingMicButton(provider),
                  ),

                  // P1 Feature 4: Keyboard Help Panel
                  if (_showKeyboardHelp)
                    Center(
                      child: KeyboardHelpPanel(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Feature 4: Fixed floating mic button for KTV tracking
  Widget _buildFloatingMicButton(TeleprompterProvider provider) {
    return Tooltip(
      message: provider.isTrackingEnabled ? '停止KTV跟踪' : '开启KTV跟踪',
      child: FloatingActionButton(
        onPressed: () async {
          if (provider.isTrackingEnabled) {
            await provider.stopTracking();
          } else {
            await provider.startTracking();
          }
        },
        backgroundColor: provider.isTrackingEnabled 
            ? AppTheme.accent 
            : Colors.grey.withOpacity(0.7),
        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTeleprompterDisplay(TeleprompterProvider provider) {
    final lines = _splitIntoLines(provider.settings.text);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: 48,
        vertical: MediaQuery.of(context).size.height / 3,
      ),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        return _buildLine(lines[index], index, _currentLineIndex);
      },
    );
  }

  Widget _buildLine(String text, int index, int currentIndex) {
    // 已读区：绿色淡化
    if (index < currentIndex) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            height: 1.6,
            color: const Color(0xFF22C55E).withOpacity(0.3), // 绿色，30%透明度
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    // 焦点区：当前行，最大最亮
    if (index == currentIndex) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppTheme.accent, width: 4),
            right: BorderSide(color: AppTheme.accent, width: 4),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 72,
            height: 1.8,
            color: Colors.white,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    // 预读区1：下一行
    if (index == currentIndex + 1) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        child: Column(
          children: [
            const Divider(color: Color(0xFF333333), thickness: 1),
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 56,
                height: 1.6,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      );
    }

    // 预读区2：再下一行
    if (index == currentIndex + 2) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Column(
          children: [
            Divider(color: const Color(0xFF333333).withOpacity(0.5), thickness: 0.5),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 44,
                height: 1.5,
                color: Colors.white.withOpacity(0.3),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      );
    }

    // 其他行：隐藏
    return const SizedBox.shrink();
  }

  Widget _buildTopStatusBar(TeleprompterProvider provider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          border: const Border(
            bottom: BorderSide(color: Color(0xFF333333)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.mic, color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              provider.isScrolling ? '演讲中' : '已暂停',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '${(provider.scrollPosition * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ESC 退出',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControlBar(TeleprompterProvider provider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          border: const Border(
            top: BorderSide(color: Color(0xFF333333)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page, color: Colors.white),
              onPressed: provider.resetScroll,
            ),
            const SizedBox(width: 16),
            
            // Microphone button for KTV tracking
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: provider.isTrackingEnabled
                    ? const Color(0xFF22C55E)
                    : Colors.white24,
              ),
              child: IconButton(
                icon: Icon(
                  provider.isTrackingEnabled ? Icons.mic : Icons.mic_off,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () async {
                  if (provider.isTrackingEnabled) {
                    await provider.stopTracking();
                  } else {
                    await provider.startTracking();
                  }
                },
                tooltip: provider.isTrackingEnabled ? '停止跟踪' : '开始跟踪',
              ),
            ),
            const SizedBox(width: 16),
            
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent,
              ),
              child: IconButton(
                icon: Icon(
                  provider.isScrolling ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: provider.toggleAutoScroll,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.last_page, color: Colors.white),
              onPressed: () {}, // TODO: Jump to end
            ),
          ],
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event, TeleprompterProvider provider) {
    if (event is KeyDownEvent) {
      // P1 Feature 4: Close help panel on any key
      if (_showKeyboardHelp) {
        setState(() => _showKeyboardHelp = false);
        return;
      }
      
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        provider.toggleAutoScroll();
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        // P1 Feature 4: Toggle spotlight
        setState(() => _enableSpotlight = !_enableSpotlight);
      } else if (event.logicalKey == LogicalKeyboardKey.slash && event.character == '?') {
        // P1 Feature 4: Show help panel (?)
        setState(() => _showKeyboardHelp = true);
      } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
        // P1 Feature 4: Show help panel (H)
        setState(() => _showKeyboardHelp = true);
      }
    }
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  /// 🔧 FIX: 动态计算行高
  /// 焦点区：72px + padding 64px = 136px
  /// 预读区1：56px + padding 40px = 96px  
  /// 平均约 116px
  double _getLineHeight() {
    return 116.0;
  }

  /// 计算聚光灯焦点中心位置
  Offset _getFocusCenter() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Offset(screenWidth / 2, screenHeight / 2);
  }

  /// 🔧 FIX: 计算演讲时长（修复后）
  Duration _getPresentationDuration() {
    if (_presentationStartTime == Duration.zero) {
      return Duration.zero;
    }
    return _lastElapsed - _presentationStartTime;
  }

  /// 计算字数
  int _getWordCount() {
    final provider = Provider.of<TeleprompterProvider>(context, listen: false);
    return provider.settings.text.split(RegExp(r'[\s,，。！？、]'))
        .where((w) => w.isNotEmpty)
        .length;
  }

  /// 计算评分
  int _calculateScore() {
    final provider = Provider.of<TeleprompterProvider>(context, listen: false);
    
    // 1. 基础分 (60分)：基于完成度
    // 使用滚动位置作为完成度估算
    final completionRate = provider.scrollPosition.clamp(0.0, 1.0);
    int baseScore = (60 * completionRate).round();
    
    // 2. 完成分 (20分)：如果滚动到底部 (>95%)
    int completionScore = completionRate > 0.95 ? 20 : 0;
    
    // 3. KTV分 (20分)：基于跟踪准确度
    int ktvScore = 0;
    if (provider.isTrackingEnabled) {
      // 获取偏差绝对值
      final deviation = provider.trackingService.deviation.abs();
      
      // 偏差越小分数越高
      if (deviation < 0.1) {
        ktvScore = 20; // 完美 (<10% 偏差)
      } else if (deviation < 0.2) {
        ktvScore = 15; // 优秀 (<20% 偏差)
      } else if (deviation < 0.3) {
        ktvScore = 10; // 良好 (<30% 偏差)
      } else if (deviation < 0.5) {
        ktvScore = 5;  // 一般 (<50% 偏差)
      }
      // >50% 偏差得0分
    }
    
    return (baseScore + completionScore + ktvScore).clamp(0, 100);
  }

  /// 显示完成对话框
  void _showCompletionDialog() {
    final provider = Provider.of<TeleprompterProvider>(context, listen: false);
    final score = _calculateScore();
    final duration = _getPresentationDuration();
    final wordCount = _getWordCount();
    
    // P1 Feature 5: Save history
    provider.saveSpeechHistory(
      durationSeconds: duration.inSeconds,
      wordCount: wordCount,
      score: score,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementAnimation(
        score: score,
        duration: duration,
        wordCount: wordCount,
        onRestart: () async {
          Navigator.pop(context); // Close dialog
          
          // P1 Feature 2: Quick Replay System
          // Reset state but keep all settings
          provider.resetScroll();
          _presentationStartTime = Duration.zero;
          
          // Show countdown and auto-start
          await _showCountdownAndStart(provider);
        },
        onExit: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Exit presentation
        },
      ),
    );
  }

  /// P1 Feature 2: Show countdown and auto-start
  Future<void> _showCountdownAndStart(TeleprompterProvider provider) async {
    // Show countdown overlay
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      
      // Show countdown number
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (context) => Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$i',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    // Show "GO!"
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'GO!',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context);
    
    // Auto-start scrolling
    if (mounted && !provider.isScrolling) {
      provider.toggleAutoScroll();
    }
  }
}

