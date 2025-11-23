import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teleprompter_settings.dart';

/// Service for persisting and loading teleprompter settings
class SettingsService {
  static const String _settingsKey = 'teleprompter_settings';
  
  /// Save settings to persistent storage
  Future<void> saveSettings(TeleprompterSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, jsonString);
  }
  
  /// Load settings from persistent storage
  Future<TeleprompterSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    
    if (jsonString == null) {
      return const TeleprompterSettings();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TeleprompterSettings.fromJson(json);
    } catch (e) {
      // If there's an error parsing, return default settings
      return const TeleprompterSettings();
    }
  }
  
  /// Clear all saved settings
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }
}
