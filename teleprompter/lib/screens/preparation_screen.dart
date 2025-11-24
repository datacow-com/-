import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teleprompter_provider.dart';
import '../utils/app_theme.dart';
import 'presentation_screen.dart';

/// 准备模式 - 极简单屏设计
/// 目标：3秒内开始演讲
class PreparationScreen extends StatefulWidget {
  const PreparationScreen({super.key});

  @override
  State<PreparationScreen> createState() => _PreparationScreenState();
}

class _PreparationScreenState extends State<PreparationScreen> {
  final TextEditingController _textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TeleprompterProvider>(context, listen: false);
    // 加载上次的脚本
    provider.loadLastScript().then((_) {
      if (mounted) {
        _textController.text = provider.settings.text;
      }
    });
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          width: 800,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Script Input (Fixed height instead of Expanded)
                SizedBox(
                  height: 200,
                  child: _buildScriptInput(),
                ),
                
                const SizedBox(height: 16),
                
                // Settings Panel
                _buildRecentScripts(),
                
                const SizedBox(height: 24),
                
                // Start Button
                _buildStartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.mic,
          size: 64,
          color: AppTheme.accent,
        ),
        const SizedBox(height: 16),
        Text(
          'Teleprompter Pro',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '您的专业演讲伙伴',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildScriptInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '输入或粘贴您的演讲稿',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: AppTheme.textMain,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '在此输入演讲内容...\n\n例如：\n欢迎大家参加今天的产品发布会。\n今天我们将介绍三个重要的新功能...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              onChanged: (value) {
                final provider = Provider.of<TeleprompterProvider>(
                  context,
                  listen: false,
                );
                provider.updateText(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildScriptStats(),
        ],
      ),
    );
  }

  Widget _buildScriptStats() {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        final wordCount = provider.settings.text.length;
        final estimatedMinutes = (wordCount / 140).ceil();
        
        return Row(
          children: [
            _buildStatItem(Icons.text_fields, '$wordCount 字'),
            const SizedBox(width: 24),
            _buildStatItem(Icons.timer, '约 $estimatedMinutes 分钟'),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
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

  Widget _buildRecentScripts() {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        // TODO: 实现最近脚本列表
        // 暂时返回空容器
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStartButton() {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        final hasContent = provider.settings.text.isNotEmpty;
        
        return SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: hasContent ? () => _startPresentation() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              disabledBackgroundColor: AppTheme.borderColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: hasContent ? 4 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  size: 32,
                  color: hasContent ? Colors.white : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  '开始演讲',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: hasContent ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startPresentation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PresentationScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
