import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/teleprompter_provider.dart';
import '../models/teleprompter_settings.dart';
import '../models/script_template.dart';
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
        // Feature 5: Check if first time and show onboarding
        _checkFirstTimeAndShowOnboarding();
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
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and Title
              _buildHeader(),
              
              const SizedBox(height: 24),
              
              // Script Input - Adaptive height for full visibility
              Expanded(
                child: _buildScriptInput(),
              ),
              
              const SizedBox(height: 16),
              
              // Scene Selector
              _buildRecentScripts(),
              
              const SizedBox(height: 24),
              
              // Start Button
              _buildStartButton(),
            ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              // P1 Feature: Template button
              TextButton.icon(
                onPressed: _showTemplateDialog,
                icon: const Icon(Icons.library_books, size: 16),
                label: const Text('选择模板'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent,
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
        // 准确统计中文字数（排除空格和标点）
        final wordCount = provider.settings.text
            .replaceAll(RegExp(r'[\s\p{P}]', unicode: true), '')
            .length;
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
                  const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '选择场景模式',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSceneModeButton(
                      '🎤 演讲',
                      '会议、培训、发布会',
                      SceneMode.speech,
                      provider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSceneModeButton(
                      '📹 口播',
                      '短视频、评测、教程',
                      SceneMode.video,
                      provider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSceneModeButton(
                      '🎥 直播',
                      '带货、互动、聊天',
                      SceneMode.live,
                      provider,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSceneModeButton(
    String title,
    String description,
    SceneMode mode,
    TeleprompterProvider provider,
  ) {
    final isSelected = provider.settings.sceneMode == mode;
    
    return GestureDetector(
      onTap: () => _selectSceneMode(mode, provider),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.accent : AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectSceneMode(SceneMode mode, TeleprompterProvider provider) {
    // 根据场景自动调整参数
    double speed;
    double fontSize;
    
    if (mode == SceneMode.video) {
      speed = 200.0;  // 口播快节奏
      fontSize = 64.0;
    } else if (mode == SceneMode.live) {
      speed = 120.0;  // 直播慢节奏
      fontSize = 80.0;
    } else {
      // SceneMode.speech or default
      speed = 140.0;  // 演讲标准节奏
      fontSize = 72.0;
    }
    
    // 更新设置
    provider.updateScrollSpeed(speed);
    provider.updateFontSize(fontSize);
    provider.updateSceneMode(mode);
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

  /// Feature 5: Check if first time and show onboarding
  Future<void> _checkFirstTimeAndShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;
    
    if (isFirstTime && mounted) {
      await prefs.setBool('is_first_time', false);
      _showOnboardingDialog();
    }
  }

  /// Feature 5: Show onboarding dialog
  void _showOnboardingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.waving_hand, color: AppTheme.accent, size: 32),
            const SizedBox(width: 12),
            Text(
              '欢迎使用 Teleprompter Pro',
              style: TextStyle(
                color: AppTheme.textMain,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '让每次演讲都充满信心',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _buildOnboardingStep(
                '1️⃣ 输入演讲稿',
                '在上方输入框粘贴或输入您的演讲内容',
              ),
              const SizedBox(height: 16),
              _buildOnboardingStep(
                '2️⃣ 选择场景',
                '根据您的使用场景（演讲/口播/直播）选择模式',
              ),
              const SizedBox(height: 16),
              _buildOnboardingStep(
                '3️⃣ 开始演讲',
                '点击"开始演讲"按钮，按空格键暂停/继续',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: AppTheme.accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡 提示：演讲时点击右下角麦克风开启KTV实时跟踪',
                        style: TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '开始体验',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingStep(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textMain,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  /// P1 Feature: Show template selection dialog
  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.library_books, color: AppTheme.accent, size: 24),
            const SizedBox(width: 12),
            Text(
              '选择脚本模板',
              style: TextStyle(
                color: AppTheme.textMain,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 500,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: AppTheme.accent,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.accent,
                  tabs: const [
                    Tab(text: '🎤 演讲'),
                    Tab(text: '📹 口播'),
                    Tab(text: '🎥 直播'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTemplateList(SceneMode.speech),
                      _buildTemplateList(SceneMode.video),
                      _buildTemplateList(SceneMode.live),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(SceneMode sceneMode) {
    final templates = TemplateLibrary.presetTemplates
        .where((t) => t.sceneMode == sceneMode)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(ScriptTemplate template) {
    return Card(
      color: AppTheme.panelBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.borderColor),
      ),
      child: InkWell(
        onTap: () => _applyTemplate(template),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${template.estimatedWords}字 · ${template.estimatedMinutes}分钟',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                template.content.length > 100
                    ? '${template.content.substring(0, 100)}...'
                    : template.content,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyTemplate(ScriptTemplate template) {
    final provider = Provider.of<TeleprompterProvider>(context, listen: false);
    
    // Apply template content
    _textController.text = template.content;
    provider.updateText(template.content);
    
    // Apply template scene mode
    _selectSceneMode(template.sceneMode, provider);
    
    // Close dialog
    Navigator.pop(context);
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已应用模板：${template.name}'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.accent,
      ),
    );
  }
}
