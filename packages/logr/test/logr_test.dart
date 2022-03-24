import 'package:contextdart/contextdart.dart';
import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:test/test.dart';

main() {
  var log = Logger(StdLogSink("logr"));

  test("log", () {
    log.info("info");
    log.v(0).info("v(0).info");
    log.v(1).info("v(1).info");
    log.error(Exception("error"), "error");
    log.withName("testing").info("with prefix");
  });

  test("sub actions", () {
    Logger.withLogger(log).run(_someAction);
  });

  test("tracing", () {
    var ctx = Context.withValue(log);

    var ret = ctx.run(() => Logger.span("action", () {
          Logger.current?.info("tracing action");

          return Logger.span("sub action", () {
            Logger.current?.info("tracing action");
            return 1;
          });
        }));

    expect(ret, 1);
  });
}

_someAction() {
  var log = Logger.current?.withName("someAction");
  log?.info("info");

  try {
    _throw();
  } catch (e, stackTrace) {
    log?.error(e as Exception, "do failed", stackTrace: stackTrace);
  }
}

_throw() {
  throw Exception("ops!");
}
