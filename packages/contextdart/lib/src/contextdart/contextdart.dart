import 'dart:async';

/// The error returned by Context.err() when the context is canceled.
final exceptionCanceled = Exception("canceled");

/// The error returned by Context.err() when the context's deadline passes.
final exceptionDeadlineExceeded = Exception("deadline exceeded");

abstract class Context {
  /// create context with value or values
  ///
  /// when param is [Map], will be used as ZoneValues directly.
  /// when param is [List], each item will be convert to Map, when item is not [MapEntry], `runtimeType` of item will be the key.
  /// when param is [MapEntry], zoneValues will be with the [MapEntry].
  /// when param is not [MapEntry], `runtimeType` of param will be the key.
  static Context withValue(dynamic valueOrListOrMap) {
    Map zoneValues = {};

    if (valueOrListOrMap is List) {
      zoneValues = valueOrListOrMap.asMap().map(
            (key, value) =>
                value is MapEntry ? value : MapEntry(value.runtimeType, value),
          );
    } else if (valueOrListOrMap is Map) {
      zoneValues = valueOrListOrMap;
    } else if (valueOrListOrMap is MapEntry) {
      zoneValues = {valueOrListOrMap.key: valueOrListOrMap.value};
    } else {
      zoneValues = {valueOrListOrMap.runtimeType: valueOrListOrMap};
    }

    return _ValuesContext(zoneValues);
  }

  /// returns the value associated with this context for key or matched type
  ///
  /// ```dart
  /// var ctx = Context.withValue(
  ///     MapEntry("comparable-key", "value will put into context"),
  /// );
  ///
  /// ctx.run(() {
  ///   Context.value("comparable-key")
  /// });
  /// ```
  static T? value<T>([dynamic key]) {
    return Zone.current[key ??= T];
  }

  /// returns a Stream that's closed when work done on behalf of this context should be canceled.
  static BehaviorStream<Exception>? get done {
    return value<CancelableContext>()?.done;
  }

  static CancelableContext withCancel() {
    return _CancelContext();
  }

  /// Executes [action] in this context.
  R run<R>(R Function() action);

  static CancelableContext withTimeout(Duration timeout) {
    return _TimerContext(DateTime.now().add(timeout));
  }

  static CancelableContext withDeadline(DateTime deadline) {
    return _TimerContext(deadline);
  }
}

abstract class CancelableContext extends Context {
  /// cancel context may with Exception
  ///
  /// the Exception notice to Stream's subscription from Context.done();
  /// the default Exception is exceptionCanceled.
  cancel([Exception? reason]);

  /// returns a Stream that's closed when work done on behalf of this context should be canceled.
  BehaviorStream<Exception>? get done;
}

class _ValuesContext implements Context {
  final Map _zoneValues;

  _ValuesContext(this._zoneValues);

  @override
  R run<R>(R Function() action) {
    return runZoned<R>(action, zoneValues: _zoneValues);
  }
}

class _CancelContext with _CancelableContext {
  _CancelContext() {
    _unsubscribe ??= _subscribeCancelsIfExists(cancel: _cancel);
  }
}

mixin _CancelableContext implements CancelableContext {
  Function()? _unsubscribe;

  final _BehaviorSubject<Exception> _done$ = _BehaviorSubject();

  @override
  cancel([Exception? reason]) {
    _cancel(reason ?? exceptionCanceled);
    if (_unsubscribe != null) {
      _unsubscribe!();
      _unsubscribe = null;
    }
  }

  _cancel(Exception reason) {
    if (_done$.value != null) {
      return;
    }
    _done$.add(reason);
    _done$.close();
  }

  @override
  R run<R>(R Function() action) {
    return runZoned<R>(
      action,
      zoneValues: {CancelableContext: this},
      zoneSpecification: ZoneSpecification(
        errorCallback: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Object error,
          StackTrace? stackTrace,
        ) {
          cancel(error is Exception ? error : Exception(error));
          return AsyncError(error, stackTrace);
        },
      ),
    );
  }

  @override
  BehaviorStream<Exception>? get done {
    return _done$;
  }
}

abstract class BehaviorStream<T> extends Stream<T> {
  T? get value;
}

class _BehaviorSubject<T> extends Stream<T> implements BehaviorStream<T> {
  final StreamController<T> _subject = StreamController.broadcast();

  T? _value;

  @override
  T? get value => _value;

  add(T v) {
    _value = v;
    _subject.sink.add(v);
  }

  close() {
    _subject.close();
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _subject.stream
        .transform(StreamTransformer.fromBind(_throwExceptionIfExists))
        .listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  Stream<T> _throwExceptionIfExists(Stream<T> stream) {
    var ctrl = StreamController<T>();

    StreamSubscription? subscription;

    addValueOnce(T v) {
      ctrl.sink.add(v);
      ctrl.close();
    }

    ctrl.onListen = () {
      if (value != null) {
        addValueOnce(value!);
        return;
      }
      subscription = stream.listen(addValueOnce);
    };

    ctrl.onCancel = () {
      subscription?.cancel();
      subscription = null;
    };

    return ctrl.stream;
  }
}

class _TimerContext with _CancelableContext {
  _TimerContext(this._deadline) {
    _unsubscribe ??= _subscribeCancelsIfExists(
      cancel: _cancel,
      cancel$: Stream.periodic(_deadline.difference(DateTime.now()))
          .map((_) => exceptionDeadlineExceeded),
    );
  }

  final DateTime _deadline;
}

_subscribeCancelsIfExists({
  required Function(Exception) cancel,
  Stream<Exception>? cancel$,
}) {
  List<Future<Exception>> cancelFutures = [
    Context.done?.first,
    cancel$?.first,
  ].whereType<Future<Exception>>().toList();

  if (cancelFutures.isEmpty) {
    return () => {};
  }

  var sub = Future.any(cancelFutures).asStream().listen(
        cancel,
        onError: (err) => err is Exception ? cancel(err) : null,
      );

  return () => sub.cancel();
}
