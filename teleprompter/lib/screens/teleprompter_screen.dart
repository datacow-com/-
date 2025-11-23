import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/teleprompter_provider.dart';
import '../widgets/scrolling_text.dart';

/// Main teleprompter display screen with transparent background
class TeleprompterScreen extends StatelessWidget {
  const TeleprompterScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        
        return Container(
          color: Colors.transparent,
          child: Stack(
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
              
              // Drag handle area at the top
              // Note: When mouse pass-through is enabled (WS_EX_TRANSPARENT on Windows),
              // the window ignores all mouse events, so dragging won't work in that mode.
              // Users can switch to control panel mode (Cmd/Ctrl+T) to move the window.
              // This drag area works when mouse pass-through is disabled.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40,
                child: GestureDetector(
                  onPanStart: (details) async {
                    await windowManager.startDragging();
                  },
                  child: Container(
                    color: Colors.transparent,
                    // Optional: Show a subtle indicator when hovering
                    child: MouseRegion(
                      cursor: SystemMouseCursors.move,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Floating hint (only shown when text is empty)
              if (settings.text.isEmpty)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Press Cmd/Ctrl + T to open control panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
