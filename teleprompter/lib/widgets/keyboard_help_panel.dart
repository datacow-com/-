import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// 快捷键帮助面板
class KeyboardHelpPanel extends StatelessWidget {
  const KeyboardHelpPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard, color: AppTheme.accent, size: 24),
              const SizedBox(width: 12),
              Text(
                '快捷键帮助',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildShortcut('空格', '暂停/继续滚动'),
          _buildShortcut('ESC', '退出演讲模式'),
          _buildShortcut('L', '切换聚光灯效果'),
          _buildShortcut('?  或  H', '显示/隐藏此帮助'),
          const SizedBox(height: 16),
          Text(
            '💡 提示：按任意键关闭此面板',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcut(String key, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
            ),
            child: Text(
              key,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
