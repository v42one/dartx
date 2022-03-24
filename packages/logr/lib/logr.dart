import 'package:contextdart/contextdart.dart';

class Logger {
  /// returns a new Context, derived from ctx, which carries the provided [Logger].
  static Context withLogger(Logger? logger) {
    return Context.withValue(logger);
  }

  /// returns a [Logger] from ctx or null.
  static Logger? get current {
    return Context.value<Logger>();
  }

  static T span<T>(String name, T Function() action, [Map? startValues]) {
    var log = Logger.current;
    if (log != null) {
      log = log.start(name, startValues);
      var ret = Logger.withLogger(log).run(action);
      log.end();
      return ret;
    }
    return action();
  }

  final LogSink _sink;
  late int _level;

  /// create a [Logger] with [LogSink]
  Logger(
    this._sink, {
    int level = 0,
  }) {
    _level = level;
  }

  LogSink get sink => _sink;

  Logger withSink(LogSink sink) {
    return Logger(sink, level: _level);
  }

  Logger start(String name, [Map? values]) {
    if (_sink is LogSinkTracer) {
      return withSink((_sink as LogSinkTracer).start(name, values));
    }
    if (values == null) {
      return withName(name);
    }
    return withName(name).withValues(values);
  }

  Logger end([Map? values]) {
    if (_sink is LogSinkTracer) {
      (_sink as LogSinkTracer).end(values);
    }
    // do nothing
    return this;
  }

  /// returns a new [Logger] instance with the specified name element added
  Logger withName(String name) {
    return withSink(_sink.withName(name));
  }

  /// returns a new [Logger] instance with Map values.
  Logger withValues(Map values) {
    return withSink(_sink.withValues(values));
  }

  /// returns a new Logger instance for a specific verbosity level, relative to this [Logger].
  ///
  /// In other words, V-levels are additive.  A higher verbosity level means a log message is less important.
  /// Negative V-levels are treated as 0.
  Logger v(int lvl) {
    if (lvl < 0) {
      lvl = 0;
    }
    return Logger(_sink, level: _level + lvl);
  }

  /// tests whether this Logger is enabled.
  ///
  /// For example, commandline flags might be used to set the logging verbosity and disable some info logs.
  bool enabled() {
    return _sink.enabled(_level);
  }

  /// logs a non-error String message or Map values as context.
  info(dynamic valuesOrMsg) {
    if (enabled()) {
      _sink.info(_level, _normalize(valuesOrMsg));
    }
  }

  /// logs an Exception, String message or Map values as context and stackTrace if passed.
  error(Exception e, dynamic valuesOrMsg, {StackTrace? stackTrace}) {
    _sink.error(e, _normalize(valuesOrMsg), stackTrace: stackTrace);
  }

  Map _normalize(dynamic valuesOrMsg) {
    if (valuesOrMsg is Map) {
      return valuesOrMsg;
    }
    return {"msg": valuesOrMsg};
  }
}

abstract class LogSink {
  /// returns a new [LogSink] with Map values.
  LogSink withValues(Map values);

  /// returns a new [LogSink] with specified name appended.
  LogSink withName(String name);

  /// tests whether this [LogSink] is enabled at the specified V-level.
  ///
  /// For example, commandline flags might be used to set the logging verbosity and disable some info logs.
  bool enabled(int level);

  /// logs non-error with Map values, message will always in field "msg"
  info(int level, Map values);

  /// logs an Exception, message will always in field "msg"
  error(Exception e, Map values, {StackTrace? stackTrace});
}

abstract class LogSinkTracer implements LogSink {
  LogSinkTracer start(String name, [Map? values]);

  end([Map? values]);
}
