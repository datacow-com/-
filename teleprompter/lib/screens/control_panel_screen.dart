import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/teleprompter_provider.dart';

/// Control panel for adjusting teleprompter settings
class ControlPanelScreen extends StatefulWidget {
  const ControlPanelScreen({Key? key}) : super(key: key);
  
  @override
  State<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  late TextEditingController _textController;
  
  @override
  void initState() {
    super.initState();
    final provider = context.read<TeleprompterProvider>();
    _textController = TextEditingController(text: provider.settings.text);
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTextFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        _textController.text = content;
        context.read<TeleprompterProvider>().updateText(content);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading file: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade900,
                Colors.black,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(provider),
                const SizedBox(height: 24),
                
                // Text input area
                _buildTextInput(provider),
                const SizedBox(height: 24),
                
                // Playback controls
                _buildPlaybackControls(provider),
                const SizedBox(height: 24),
                
                // Settings
                _buildSettings(provider, settings),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(TeleprompterProvider provider) {
    return Row(
      children: [
        const Icon(
          Icons.settings,
          color: Colors.white,
          size: 32,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Control Panel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: provider.toggleMode,
          icon: const Icon(Icons.visibility),
          label: const Text('Show Teleprompter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextInput(TeleprompterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Script Text',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _loadTextFromFile,
              icon: const Icon(Icons.file_upload, size: 18),
              label: const Text('Load from file'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade300,
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                _textController.clear();
                provider.clearText();
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade700,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 10,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter your script here...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: provider.updateText,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPlaybackControls(TeleprompterProvider provider) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Playback Controls',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.replay,
                  label: 'Reset',
                  onPressed: provider.resetScroll,
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: provider.isScrolling ? Icons.pause : Icons.play_arrow,
                  label: provider.isScrolling ? 'Pause' : 'Play',
                  onPressed: provider.isScrolling
                      ? provider.pauseScrolling
                      : provider.startScrolling,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blue.shade700 : Colors.grey.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildSettings(TeleprompterProvider provider, settings) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Font size
            _buildSlider(
              label: 'Font Size',
              value: settings.fontSize,
              min: 20,
              max: 120,
              divisions: 100,
              valueLabel: '${settings.fontSize.round()}px',
              onChanged: provider.updateFontSize,
            ),
            
            // Scroll speed
            _buildSlider(
              label: 'Scroll Speed',
              value: settings.scrollSpeed,
              min: 10,
              max: 200,
              divisions: 190,
              valueLabel: '${settings.scrollSpeed.round()}px/s',
              onChanged: provider.updateScrollSpeed,
            ),
            
            // Text opacity
            _buildSlider(
              label: 'Text Opacity',
              value: settings.textOpacity,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              valueLabel: '${(settings.textOpacity * 100).round()}%',
              onChanged: provider.updateTextOpacity,
            ),
            
            // Window opacity
            _buildSlider(
              label: 'Window Background Opacity',
              value: settings.windowOpacity,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              valueLabel: '${(settings.windowOpacity * 100).round()}%',
              onChanged: provider.updateWindowOpacity,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(
                color: Colors.blue.shade300,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Colors.blue.shade400,
          inactiveColor: Colors.grey.shade600,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
