import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teleprompter_provider.dart';
import 'editor_screen.dart';
import 'prompter_screen.dart';

/// Main teleprompter screen - switches between Editor and Prompter modes
class TeleprompterScreen extends StatelessWidget {
  const TeleprompterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TeleprompterProvider>(
      builder: (context, provider, child) {
        debugPrint('[TeleprompterScreen] Building with isControlMode: ${provider.isControlMode}');
        return provider.isControlMode 
            ? EditorScreen(key: ValueKey('editor_${provider.isControlMode}'))
            : PrompterScreen(key: ValueKey('prompter_${provider.isControlMode}'));
      },
    );
  }
}
