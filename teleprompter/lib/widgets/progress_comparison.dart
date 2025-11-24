import 'package:flutter/material.dart';

/// 进度对比显示组件
/// 显示预期进度 vs 实际进度，以及偏差状态
class ProgressComparison extends StatelessWidget {
  final double expectedProgress;
  final double actualProgress;
  final String deviationStatus;
  final int deviationColor;

  const ProgressComparison({
    super.key,
    required this.expectedProgress,
    required this.actualProgress,
    required this.deviationStatus,
    required this.deviationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📊 进度对比',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildProgressBar('预期', expectedProgress, const Color(0xFF0EA5E9)),
          const SizedBox(height: 8),
          _buildProgressBar('实际', actualProgress, const Color(0xFF22C55E)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(deviationColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Color(deviationColor)),
            ),
            child: Text(
              deviationStatus,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(deviationColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
