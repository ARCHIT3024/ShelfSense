import 'package:flutter/foundation.dart';

/// Lightweight structured logger. Debug lines are dropped in release.
/// Surface to /diagnostics; never phones home.
enum LogLevel { debug, info, warn, error }

class AppLogger {
  static final _logs = <LogEntry>[];
  static const _maxEntries = 500;

  static void d(String tag, String msg) => _log(LogLevel.debug, tag, msg);
  static void i(String tag, String msg) => _log(LogLevel.info, tag, msg);
  static void w(String tag, String msg) => _log(LogLevel.warn, tag, msg);
  static void e(String tag, String msg, [Object? err]) =>
      _log(LogLevel.error, tag, err != null ? '$msg — $err' : msg);

  static void _log(LogLevel level, String tag, String msg) {
    final entry = LogEntry(
      level: level,
      tag: tag,
      message: msg,
      timestamp: DateTime.now(),
    );
    _logs.add(entry);
    if (_logs.length > _maxEntries) _logs.removeAt(0);
    // Info+ always reaches logcat: the on-device model/latency numbers are
    // read from there (T-17) and release is the only build we run.
    if (kDebugMode || level != LogLevel.debug) {
      debugPrint('[${entry.levelChar}] [$tag] $msg');
    }
  }

  /// Returns a copy of the log buffer, newest first, for the Diagnostics screen.
  static List<LogEntry> dump() => List.unmodifiable(_logs.reversed);

  /// Export as plain text for log dump button.
  static String dumpText() => _logs
      .map((e) =>
          '${e.timestamp.toIso8601String()} [${e.levelChar}] [${e.tag}] ${e.message}')
      .join('\n');
}

class LogEntry {
  const LogEntry({
    required this.level,
    required this.tag,
    required this.message,
    required this.timestamp,
  });
  final LogLevel level;
  final String tag, message;
  final DateTime timestamp;
  String get levelChar => switch (level) {
        LogLevel.debug => 'D',
        LogLevel.info => 'I',
        LogLevel.warn => 'W',
        LogLevel.error => 'E',
      };
}
