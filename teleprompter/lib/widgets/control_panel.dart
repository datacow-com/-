import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teleprompter_provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            // Ensure control panel has minimum width
            final width = constraints.maxWidth.clamp(250.0, 300.0);
            return Container(
              width: width,
              padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const Divider(color: Colors.white24),
                _buildSlider(
                  context,
                  label: 'Scroll Speed',
                  value: settings.scrollSpeed,
                  min: 10.0,
                  max: 200.0,
                  onChanged: provider.updateScrollSpeed,
                ),
                _buildSlider(
                  context,
                  label: 'Font Size',
                  value: settings.fontSize,
                  min: 20.0,
                  max: 120.0,
                  onChanged: provider.updateFontSize,
                ),
                _buildSlider(
                  context,
                  label: 'Text Opacity',
                  value: settings.textOpacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: provider.updateTextOpacity,
                ),
                _buildSlider(
                  context,
                  label: 'Window Opacity',
                  value: settings.windowOpacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: provider.updateWindowOpacity,
                ),
                const SizedBox(height: 16),
                _buildActionButtons(context, provider),
                const SizedBox(height: 12),
                _buildModeToggleButton(context, provider),
              ],
            ),
          ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TeleprompterProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => provider.toggleMode(),
          tooltip: 'Close Control Panel (Cmd+T)',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 24,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.blueAccent,
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
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, TeleprompterProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              provider.isScrolling ? Icons.pause : Icons.play_arrow,
              size: 16,
            ),
            label: Text(provider.isScrolling ? 'Pause' : 'Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.isScrolling ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: provider.toggleAutoScroll,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: provider.resetScroll,
          ),
        ),
      ],
    );
  }
  
  Widget _buildModeToggleButton(BuildContext context, TeleprompterProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.visibility_off, size: 16),
        label: const Text('Enter Invisible Mode (Cmd+T)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => provider.toggleMode(),
      ),
    );
  }
}
