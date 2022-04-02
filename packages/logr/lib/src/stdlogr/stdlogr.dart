import 'package:logr/logr.dart';

class SpanContext {
  final String traceID;
  final String spanID;
  final String? parentSpanID;

  SpanContext(
    this.traceID,
    this.spanID, {
    this.parentSpanID,
  });
}

class StdLogSink implements LogSinkTracer {
  String name;
  Map values;

  final _idGen = IDGenerator();

  final SpanContext? spanContext;

  StdLogSink(
    this.name, {
    this.values = const {},
    this.spanContext,
  });

  @override
  StdLogSink withName(String name) {
    return StdLogSink(
      _appendName(name),
      values: values,
    );
  }

  String _appendName(String name) {
    return this.name == "" ? name : [this.name, name].join("/");
  }

  @override
  StdLogSink withValues(Map values) {
    return StdLogSink(
      name,
      values: {...this.values, ...values},
    );
  }

  @override
  bool enabled(int level) {
    return true;
  }

  @override
  error(Exception e, values, {StackTrace? stackTrace}) {
    _print(-2, {...this.values, ...values, "error": e}, stackTrace);
  }

  @override
  info(int level, values) {
    _print(level, {
      ...this.values,
      ...values,
    });
  }

  _print(int level, Map values, [StackTrace? stackTrace]) {
    var output = StringBuffer(
      "[${_namedLevel(level).substring(0, 4)}] span=$name",
    );

    if (spanContext != null) {
      values = {
        ...values,
        "traceID": spanContext!.traceID,
        "spanID": spanContext!.spanID,
        "parentSpanID": spanContext!.parentSpanID,
      };
    }

    for (var key in values.keys) {
      var value = values[key];
      if (value != null) {
        if (value is num) {
          output.write(" $key=$value");
        } else {
          output.write(' $key="$value"');
        }
      }
    }

    // ignore: avoid_print
    print(output.toString());

    if (stackTrace != null) {
      // ignore: avoid_print
      print(stackTrace.toString());
    }
  }

  String _namedLevel(int level) {
    if (level < 0) {
      if (level < -1) {
        return "FATAL";
      }
      if (level == -1) {
        return "WARN";
      }
      return "ERROR";
    }
    if (level > 1) {
      return "TRACE";
    }
    if (level == 1) {
      return "DEBUG";
    }
    return "INFO";
  }

  @override
  end([Map? values]) {
    // dispatch span
  }

  @override
  StdLogSink start(String name, [Map? values]) {
    return StdLogSink(
      _appendName(name),
      spanContext: _startSpan(),
      values: {...this.values, ...?values},
    );
  }

  _startSpan() {
    var traceID = spanContext?.traceID ?? _idGen.traceID();
    return SpanContext(
      traceID,
      _idGen.spanID(traceID),
      parentSpanID: spanContext?.spanID,
    );
  }
}
