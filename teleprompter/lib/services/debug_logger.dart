import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to log runtime state and errors to a local file for verification.
class DebugLogger {
  static final DebugLogger _instance = DebugLogger._internal();
  
  factory DebugLogger() {
    return _instance;
  }
  
  DebugLogger._internal();
  
  final File _logFile = File('debug_state.json');
  
  Map<String, dynamic> _currentState = {};
  
  /// Initialize the logger
  Future<void> initialize() async {
    debugPrint('DebugLogger initialized. Writing to ${_logFile.absolute.path}');
    _currentState = {
      'initialized_at': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'errors': [],
      'app_state': {},
    };
    await _flush();
  }
  
  /// Update a specific section of the state
  Future<void> logState(String key, dynamic value) async {
    debugPrint('[DebugLogger.logState] key=$key, value=$value');
    final appState = Map<String, dynamic>.from(_currentState['app_state'] as Map);
    appState[key] = value;
    _currentState['app_state'] = appState;
    _currentState['last_updated'] = DateTime.now().toIso8601String();
    await _flush();
    debugPrint('[DebugLogger.logState] Flushed to file');
  }
  
  /// Log an error
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    final errors = List<Map<String, dynamic>>.from(_currentState['errors'] as List);
    errors.add({
      'timestamp': DateTime.now().toIso8601String(),
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
    });
    _currentState['errors'] = errors;
    await _flush();
  }
  
  /// Write current state to file
  Future<void> _flush() async {
    try {
      await _logFile.writeAsString(jsonEncode(_currentState));
    } catch (e) {
      debugPrint('Failed to write debug log: $e');
    }
  }
}
