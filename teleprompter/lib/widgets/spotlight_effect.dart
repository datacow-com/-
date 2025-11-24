import 'package:flutter/material.dart';

/// 聚光灯效果组件
/// 使用径向渐变创建舞台聚光灯效果
class SpotlightEffect extends StatelessWidget {
  final Offset center; // 聚光灯中心位置
  final double radius; // 聚光灯半径
  final double intensity; // 强度（0.0-1.0）

  const SpotlightEffect({
    super.key,
    required this.center,
    this.radius = 400,
    this.intensity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: SpotlightPainter(
          center: center,
          radius: radius,
          intensity: intensity,
        ),
        child: Container(),
      ),
    );
  }
}

/// 聚光灯绘制器
class SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double intensity;

  SpotlightPainter({
    required this.center,
    required this.radius,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 创建径向渐变
    final gradient = RadialGradient(
      center: Alignment(
        (center.dx / size.width) * 2 - 1,
        (center.dy / size.height) * 2 - 1,
      ),
      radius: radius / (size.width / 2),
      colors: [
        Colors.transparent, // 中心透明
        Colors.black.withOpacity(0.3 * intensity), // 过渡区
        Colors.black.withOpacity(0.7 * intensity), // 边缘暗区
        Colors.black.withOpacity(0.9 * intensity), // 最外围
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.intensity != intensity;
  }
}
