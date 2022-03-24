import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:roundtripper/roundtripbuilders/request_body_convert.dart';
import 'package:roundtripper/roundtripbuilders/request_log.dart';
import 'package:roundtripper/roundtripbuilders/throws_not_2xx_error.dart';
import 'package:roundtripper/roundtripper.dart';

var c = Client(roundTripBuilders: [
  ThrowsNot2xxError(),
  RequestBodyConvert(),
  RequestLog(),
]);

var l = Logger(StdLogSink("roundtripper"));

void main() async {
  var ctx = Logger.withLogger(l);

  ctx.run(() async {
    var resp = await c.fetch(Request.uri(
      "https://httpbin.org/anything",
      queryParameters: {
        "int": 1,
        "slice": [1, 2],
      },
      headers: {
        "x-int": 1,
        "x-slice": [1, 2],
      },
    ));

    try {
      await resp.json();
    } on ResponseException catch (_) {
      //
    }
  });
}
