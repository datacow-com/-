import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/teleprompter_provider.dart';
import '../models/speech_history.dart';
import '../utils/app_theme.dart';

class HistoryDialog extends StatelessWidget {
  const HistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔧 FIX: 使用约束而非固定尺寸，适应不同屏幕
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width > 800 ? 600.0 : size.width * 0.9;
    final dialogHeight = size.height > 900 ? 700.0 : size.height * 0.8;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: AppTheme.panelBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildHistoryList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppTheme.accent, size: 28),
              const SizedBox(width: 12),
              Text(
                '演讲历史记录',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<SpeechHistory>>(
          future: provider.getHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '加载失败: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final history = snapshot.data ?? [];

            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      '暂无演讲记录',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryItem(context, item);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, SpeechHistory item) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Score Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getScoreColor(item.score).withOpacity(0.2),
              border: Border.all(color: _getScoreColor(item.score)),
            ),
            child: Center(
              child: Text(
                '${item.score}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(item.score),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.scriptTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildIconText(Icons.access_time, dateFormat.format(item.timestamp)),
                    const SizedBox(width: 16),
                    _buildIconText(Icons.timer, _formatDuration(item.durationSeconds)),
                    const SizedBox(width: 16),
                    _buildIconText(Icons.text_fields, '${item.wordCount} 字'),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () => _confirmDelete(context, item),
            tooltip: '删除记录',
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SpeechHistory item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        title: const Text('确认删除', style: TextStyle(color: Colors.white)),
        content: const Text('确定要删除这条演讲记录吗？此操作无法撤销。', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      if (context.mounted) {
        await Provider.of<TeleprompterProvider>(context, listen: false)
            .deleteHistory(item.id!);
      }
    }
  }

  // ... (helper methods remain same)

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFFFFD700); // Gold
    if (score >= 80) return const Color(0xFFC0C0C0); // Silver
    return const Color(0xFFCD7F32); // Bronze
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
