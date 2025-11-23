import 'package:flutter/material.dart';
import 'dart:async';

/// Widget that displays auto-scrolling text
class ScrollingText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final double textOpacity;
  final double scrollSpeed; // pixels per second
  final bool isScrolling;
  final Function(double) onScrollPositionChanged;
  final double initialScrollPosition;
  
  const ScrollingText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.textColor,
    required this.textOpacity,
    required this.scrollSpeed,
    required this.isScrolling,
    required this.onScrollPositionChanged,
    this.initialScrollPosition = 0.0,
  }) : super(key: key);
  
  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollPosition,
    );
    _scrollController.addListener(_onScroll);
    
    if (widget.isScrolling) {
      _startAutoScroll();
    }
  }
  
  @override
  void didUpdateWidget(ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle scrolling state changes
    if (widget.isScrolling != oldWidget.isScrolling) {
      if (widget.isScrolling) {
        _startAutoScroll();
      } else {
        _stopAutoScroll();
      }
    }
    
    // Handle scroll position reset
    if (widget.initialScrollPosition != oldWidget.initialScrollPosition &&
        widget.initialScrollPosition == 0.0) {
      _scrollController.jumpTo(0.0);
    }
  }
  
  @override
  void dispose() {
    _stopAutoScroll();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    widget.onScrollPositionChanged(_scrollController.offset);
  }
  
  void _startAutoScroll() {
    _stopAutoScroll();
    
    // Update scroll position at 60 FPS
    const updateInterval = Duration(milliseconds: 16);
    final pixelsPerFrame = widget.scrollSpeed / 60.0;
    
    _scrollTimer = Timer.periodic(updateInterval, (timer) {
      if (!_scrollController.hasClients) return;
      
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      
      if (currentScroll >= maxScroll) {
        // Reached the end, loop back to start
        _scrollController.jumpTo(0.0);
      } else {
        final newPosition = currentScroll + pixelsPerFrame;
        _scrollController.jumpTo(newPosition.clamp(0.0, maxScroll));
      }
    });
  }
  
  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) {
      return Center(
        child: Opacity(
          opacity: widget.textOpacity,
          child: Text(
            'Enter your text in the control panel',
            style: TextStyle(
              fontSize: widget.fontSize * 0.5,
              color: widget.textColor.withOpacity(0.5),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Opacity(
          opacity: widget.textOpacity,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: widget.textColor,
              fontWeight: FontWeight.w500,
              height: 1.5,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
