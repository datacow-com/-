import 'package:flutter/material.dart';

/// Settings model for the teleprompter application
class TeleprompterSettings {
  // Text settings
  final String text;
  final double fontSize;
  final Color textColor;
  
  // Scroll settings
  final double scrollSpeed; // pixels per second
  final bool autoScroll;
  
  // Window settings
  final double windowOpacity; // 0.0 to 1.0
  final double textOpacity; // 0.0 to 1.0
  
  // Display mode
  final bool isControlMode; // true = control panel, false = teleprompter
  
  const TeleprompterSettings({
    this.text = '',
    this.fontSize = 48.0,
    this.textColor = Colors.white,
    this.scrollSpeed = 50.0,
    this.autoScroll = false,
    this.windowOpacity = 0.5, // Default to semi-transparent
    this.textOpacity = 1.0,
    this.isControlMode = true,
  });
  
  TeleprompterSettings copyWith({
    String? text,
    double? fontSize,
    Color? textColor,
    double? scrollSpeed,
    bool? autoScroll,
    double? windowOpacity,
    double? textOpacity,
    bool? isControlMode,
  }) {
    return TeleprompterSettings(
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      autoScroll: autoScroll ?? this.autoScroll,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      textOpacity: textOpacity ?? this.textOpacity,
      isControlMode: isControlMode ?? this.isControlMode,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'fontSize': fontSize,
      'textColor': textColor.value,
      'scrollSpeed': scrollSpeed,
      'autoScroll': autoScroll,
      'windowOpacity': windowOpacity,
      'textOpacity': textOpacity,
      'isControlMode': isControlMode,
    };
  }
  
  factory TeleprompterSettings.fromJson(Map<String, dynamic> json) {
    return TeleprompterSettings(
      text: json['text'] as String? ?? '',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 48.0,
      textColor: Color(json['textColor'] as int? ?? Colors.white.value),
      scrollSpeed: (json['scrollSpeed'] as num?)?.toDouble() ?? 50.0,
      autoScroll: json['autoScroll'] as bool? ?? false,
      windowOpacity: (json['windowOpacity'] as num?)?.toDouble() ?? 1.0,
      textOpacity: (json['textOpacity'] as num?)?.toDouble() ?? 1.0,
      isControlMode: json['isControlMode'] as bool? ?? true,
    );
  }
}
