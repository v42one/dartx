import 'package:logr/trace/trace.dart';
import 'package:test/test.dart';

main() {
  test("#IDGenerator", () {
    var gen = IDGenerator();

    var traceID = gen.traceID();

    // ignore: avoid_print
    print("traceID $traceID");
    // ignore: avoid_print
    print("spanID ${gen.spanID(traceID)}");
    // ignore: avoid_print
    print("spanID ${gen.spanID(traceID)}");
  });
}
