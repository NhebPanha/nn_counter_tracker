import 'package:flutter/foundation.dart';

/// Minimal, dependency-free logger used across the package.
///
/// Logging is disabled by default and only emits output in debug/profile builds
/// (via [debugPrint]) when [enabled] is `true`.
class CounterLogger {
  /// Creates a logger. Logging is off unless [enabled] is `true`.
  const CounterLogger({this.enabled = false, this.tag = 'nn_counter_tracker'});

  /// Whether log output is emitted.
  final bool enabled;

  /// Prefix prepended to every log line.
  final String tag;

  /// Returns a copy of this logger with [enabled] overridden.
  CounterLogger copyWith({bool? enabled, String? tag}) =>
      CounterLogger(enabled: enabled ?? this.enabled, tag: tag ?? this.tag);

  /// Logs [message] when logging is [enabled].
  void log(String message) {
    if (!enabled) return;
    debugPrint('[$tag] $message');
  }

  /// Logs an error [message], optionally with an [error] and [stackTrace].
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!enabled) return;
    debugPrint('[$tag] ERROR: $message${error == null ? '' : ' -> $error'}');
    if (stackTrace != null) debugPrint('$stackTrace');
  }
}
