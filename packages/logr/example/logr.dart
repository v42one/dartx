import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';

main() {
  var log = Logger(StdLogSink("logr"));

  log.info("info");
  log.v(0).info("v(0).info");
  log.v(1).info("v(1).info");
  log.error(Exception("error"), "error");
  log.withName("testing").info("with prefix");

  Logger.withLogger(log).run(_someAction);
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
