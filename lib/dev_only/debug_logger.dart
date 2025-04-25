import 'package:flutter/material.dart';
import 'dart:async';

class DebugLogger {
  static final ValueNotifier<List<String>> logsNotifier = ValueNotifier<List<String>>([]);
  static final List<String> _logs = [];
  static const int maxLogs = 100;

  // Log a message
  static void log(String message) {
    print(message); // Still print to console
    _addLog(message);
  }

  static void _addLog(String log) {
    final timestamp = DateTime.now().toString().split('.').first;
    final timestampedLog = '[$timestamp] $log';
    _logs.add(timestampedLog);

    // Keep log size in check
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }

    logsNotifier.value = List.from(_logs);
  }

  static void clear() {
    _logs.clear();
    logsNotifier.value = [];
  }

  // Initialize with zone to capture all print statements
  static void initWithZone(Widget app) {
    runZonedGuarded<Future<void>>(() async {
      // Capture Flutter errors
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        log('FlutterError: ${details.toString()}');
      };

      runApp(app);
    }, (error, stack) {
      log('Uncaught error: $error');
      log(stack.toString());
    }, zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        parent.print(zone, line);
        _addLog(line);
      },
    ));
  }
}