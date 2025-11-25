import 'package:flutter/material.dart';
import 'dart:math';

/// 成就动画组件
/// 演讲完成时显示的庆祝动画
class AchievementAnimation extends StatefulWidget {
  final int wordCount;
  final Duration duration;
  final int score;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const AchievementAnimation({
    super.key,
    required this.wordCount,
    required this.duration,
    required this.score,
    required this.onRestart,
    required this.onExit,
  });

  @override
  State<AchievementAnimation> createState() => _AchievementAnimationState();
}

class _AchievementAnimationState extends State<AchievementAnimation>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _badgeController;
  late AnimationController _confettiController;
  late AnimationController _statsController;

  late Animation<double> _flashAnimation;
  late Animation<double> _badgeScaleAnimation;
  late Animation<double> _badgeOpacityAnimation;
  late Animation<double> _statsOpacityAnimation;

  final List<Confetti> _confettiList = [];

  @override
  void initState() {
    super.initState();

    // 闪光动画
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
    _flashController.forward();

    // 徽章动画
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );
    _badgeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeIn),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _badgeController.forward();
    });

    // 五彩纸屑动画
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _initializeConfetti();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _confettiController.forward();
    });

    // 统计数据动画
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _statsOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeIn),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _statsController.forward();
    });
  }

  void _initializeConfetti() {
    final random = Random();
    for (int i = 0; i < 50; i++) {
      _confettiList.add(Confetti(
        x: random.nextDouble(),
        y: -0.1,
        color: _getRandomColor(random),
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 2 * pi,
        speedY: random.nextDouble() * 0.3 + 0.2,
        speedX: (random.nextDouble() - 0.5) * 0.1,
      ));
    }
  }

  Color _getRandomColor(Random random) {
    final colors = [
      const Color(0xFFEF4444), // 红
      const Color(0xFFF59E0B), // 橙
      const Color(0xFFFBBF24), // 黄
      const Color(0xFF22C55E), // 绿
      const Color(0xFF0EA5E9), // 蓝
      const Color(0xFFA855F7), // 紫
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Stack(
          children: [
            // 闪光效果
            _buildFlashEffect(),

            // 五彩纸屑
            _buildConfetti(),

            // 主内容
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashEffect() {
    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        final opacity = _flashAnimation.value > 0.5
            ? 1.0 - (_flashAnimation.value - 0.5) * 2
            : _flashAnimation.value * 2;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity * 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            confettiList: _confettiList,
            progress: _confettiController.value,
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 徽章
          _buildBadge(),

          const SizedBox(height: 24),

          // 标题
          const Text(
            '🎉 演讲完成！',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // 统计数据
          _buildStats(),

          const SizedBox(height: 32),

          // 按钮
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    // P1 Feature 3: Graded achievements
    final (medal, color1, color2) = _getMedalGrade();
    
    return AnimatedBuilder(
      animation: _badgeController,
      builder: (context, child) {
        return Transform.scale(
          scale: _badgeScaleAnimation.value,
          child: Opacity(
            opacity: _badgeOpacityAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color1, color2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color1.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  medal,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// P1 Feature 3: Get medal grade based on score
  (String, Color, Color) _getMedalGrade() {
    if (widget.score >= 90) {
      return ('🥇', const Color(0xFFFFD700), const Color(0xFFFFA500)); // Gold
    } else if (widget.score >= 80) {
      return ('🥈', const Color(0xFFC0C0C0), const Color(0xFF808080)); // Silver
    } else {
      return ('🥉', const Color(0xFFCD7F32), const Color(0xFF8B4513)); // Bronze
    }
  }

  Widget _buildStats() {
    // P1 Feature 3: Transparent scoring breakdown
    final baseScore = 60;
    final completionScore = 20;
    final ktvScore = widget.score - baseScore - completionScore;
    final suggestion = _getImprovementSuggestion();
    
    return AnimatedBuilder(
      animation: _statsOpacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _statsOpacityAnimation.value,
          child: Column(
            children: [
              _buildStatRow('📝 字数', '${widget.wordCount} 字'),
              const SizedBox(height: 16),
              _buildStatRow('⏱️ 时长', _formatDuration(widget.duration)),
              const SizedBox(height: 16),
              _buildStatRow('⭐ 总分', '${widget.score} 分'),
              const SizedBox(height: 8),
              // Scoring breakdown
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Column(
                  children: [
                    _buildScoreDetail('基础分', baseScore),
                    _buildScoreDetail('完成分', completionScore),
                    _buildScoreDetail('KTV分', ktvScore),
                  ],
                ),
              ),
              if (suggestion.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreDetail(String label, int score) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
          Text(
            '+$score',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  /// P1 Feature 3: Get improvement suggestion based on score
  String _getImprovementSuggestion() {
    if (widget.score >= 90) {
      return '完美表现！继续保持这个水平';
    } else if (widget.score >= 80) {
      return '表现优秀！可以尝试提升KTV跟踪准确度';
    } else {
      return '建议多练习几次，熟悉脚本内容';
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFFAAAAAA),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: widget.onExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF333333),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('返回'),
        ),
        ElevatedButton(
          onPressed: widget.onRestart,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('再来一次'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes分$seconds秒';
  }

  @override
  void dispose() {
    _flashController.dispose();
    _badgeController.dispose();
    _confettiController.dispose();
    _statsController.dispose();
    super.dispose();
  }
}

/// 五彩纸屑数据类
class Confetti {
  double x;
  double y;
  final Color color;
  final double size;
  final double rotation;
  final double speedY;
  final double speedX;

  Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.speedY,
    required this.speedX,
  });
}

/// 五彩纸屑绘制器
class ConfettiPainter extends CustomPainter {
  final List<Confetti> confettiList;
  final double progress;

  ConfettiPainter({
    required this.confettiList,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final confetti in confettiList) {
      final y = confetti.y + confetti.speedY * progress;
      final x = confetti.x + confetti.speedX * progress;

      if (y > 1.1) continue; // 超出屏幕不绘制

      final paint = Paint()
        ..color = confetti.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(confetti.rotation + progress * 4 * pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: confetti.size,
          height: confetti.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
