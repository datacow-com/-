import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teleprompter_provider.dart';
import '../widgets/scrolling_text.dart';

/// Distraction-free prompter display screen
class PrompterScreen extends StatelessWidget {
  const PrompterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Main scrolling text
              ScrollingText(
                text: settings.text,
                fontSize: settings.fontSize,
                textColor: settings.textColor,
                textOpacity: settings.textOpacity,
                scrollSpeed: settings.scrollSpeed,
                isScrolling: provider.isScrolling,
                onScrollPositionChanged: provider.updateScrollPosition,
                initialScrollPosition: provider.scrollPosition,
              ),
              
              // Minimal floating controls (bottom center)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: provider.toggleAutoScroll,
                          icon: Icon(
                            provider.isScrolling ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          tooltip: provider.isScrolling ? '暂停' : '播放',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: provider.resetScroll,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          tooltip: '重置',
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            debugPrint('[PrompterScreen] Edit button clicked');
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          tooltip: '编辑 (Cmd+T)',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Hint overlay (top)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '按 Cmd+T 返回编辑器',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
