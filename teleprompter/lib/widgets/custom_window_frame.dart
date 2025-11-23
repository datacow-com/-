import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

/// Custom window frame with drag area and window controls
class CustomWindowFrame extends StatelessWidget {
  final Widget child;
  final bool showControls;
  
  const CustomWindowFrame({
    Key? key,
    required this.child,
    this.showControls = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showControls) _buildTitleBar(),
        Expanded(child: child),
      ],
    );
  }
  
  Widget _buildTitleBar() {
    return WindowTitleBarBox(
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Teleprompter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            _buildWindowButton(
              icon: Icons.remove,
              onPressed: () => appWindow.minimize(),
            ),
            _buildWindowButton(
              icon: Icons.close,
              onPressed: () => appWindow.close(),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWindowButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isClose = false,
  }) {
    return SizedBox(
      width: 46,
      height: 32,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          color: Colors.transparent,
          child: Icon(
            icon,
            size: 16,
            color: isClose ? Colors.red.shade300 : Colors.white,
          ),
        ),
      ),
    );
  }
}
