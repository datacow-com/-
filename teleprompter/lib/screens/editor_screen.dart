import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/teleprompter_provider.dart';

/// Editor screen for composing and managing teleprompter scripts
class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TeleprompterProvider>(context, listen: false);
    _textController = TextEditingController(text: provider.settings.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadTextFromFile(TeleprompterProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        _textController.text = content;
        provider.updateText(content);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded: ${result.files.single.name}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startPrompter(BuildContext context, TeleprompterProvider provider) {
    debugPrint('[EditorScreen] Start Prompter button clicked');
    debugPrint('[EditorScreen] Current text length: ${provider.settings.text.length}');
    
    // Validate script is not empty
    if (provider.settings.text.trim().isEmpty) {
      debugPrint('[EditorScreen] Script is empty, showing dialog');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('脚本为空'),
          content: const Text('请先输入或加载脚本后再开始提词。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }

    debugPrint('[EditorScreen] Navigating to prompter screen');
    // Navigate to prompter screen
    Navigator.pushNamed(context, '/prompter');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        // Sync controller with provider
        if (_textController.text != provider.settings.text) {
          _textController.text = provider.settings.text;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF1E1E1E),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 28), // Extra padding for macOS title bar
              child: Column(
                children: [
                  // Top toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '脚本编辑器',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _loadTextFromFile(provider),
                      icon: const Icon(Icons.file_upload, color: Colors.white70),
                      tooltip: '从文件加载',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _textController.clear();
                        provider.clearText();
                      },
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      tooltip: '清空',
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _startPrompter(context, provider),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('开始提词'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Text editor
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        hintText: '在此粘贴您的演讲稿...\n\n提示：使用 Cmd+T 在编辑器和提词器模式之间切换。',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                      onChanged: (value) => provider.updateText(value),
                    ),
                  ),
                ),
              ),
              
              // Bottom controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSlider(
                        label: '速度',
                        value: provider.settings.scrollSpeed,
                        min: 10,
                        max: 200,
                        onChanged: provider.updateScrollSpeed,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildSlider(
                        label: '字体大小',
                        value: provider.settings.fontSize,
                        min: 20,
                        max: 120,
                        onChanged: provider.updateFontSize,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildSlider(
                        label: '文字透明度',
                        value: provider.settings.textOpacity,
                        min: 0.1,
                        max: 1.0,
                        onChanged: provider.updateTextOpacity,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.blue,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
