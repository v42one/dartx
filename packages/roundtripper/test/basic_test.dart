import 'dart:async';
import 'dart:convert';

import 'package:contextdart/contextdart.dart';
import 'package:filesize/filesize.dart';
import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:roundtripper/roundtripbuilders/request_body_convert.dart';
import 'package:roundtripper/roundtripbuilders/request_log.dart';
import 'package:roundtripper/roundtripbuilders/throws_not_2xx_error.dart';
import 'package:roundtripper/roundtripper.dart';
import 'package:test/test.dart';

var logger = Logger(StdLogSink("roundtripper"));

var httpBinEndpoint = "https://httpbin.org";

void main() async {
  var c = Client(roundTripBuilders: [
    ThrowsNot2xxError(),
    RequestBodyConvert(),
    RequestLog(),
  ]);

  var ctx = Logger.withLogger(logger);

  test("get", () async {
    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "$httpBinEndpoint/anything",
        queryParameters: {
          "int": 1,
          "slice": [1, 2],
        },
        headers: {
          "x-int": 1,
          "x-slice": [1, 2],
        },
      ));

      expect(resp.statusCode, 200);

      var json = await resp.json();

      expect(json["url"], "$httpBinEndpoint/anything?int=1&slice=1&slice=2");
      expect(json["headers"]["X-Int"], "1");
      expect(json["headers"]["X-Slice"], "1, 2"); // ?
    });
  });

  test("post", () async {
    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "$httpBinEndpoint/anything",
        method: "POST",
        body: {
          "a": 1,
          "b": "s",
        },
      ));

      expect(resp.statusCode, 200);

      var json = await resp.json();

      expect(jsonDecode(json["data"]), {
        "a": 1,
        "b": "s",
      });

      expect(
          json["headers"]["Content-Type"], "application/json; charset=utf-8");
    });
  });

  test("download & progress", () async {
    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "$httpBinEndpoint/bytes/102400",
        method: "GET",
      ));

      expect(resp.statusCode, 200);

      var complete = 0;
      var len = resp.contentLength;

      var f = StreamController(sync: true);

      f.stream.listen((event) {});

      await f.addStream(
        resp.responseBody.transform(
          StreamTransformer<List<int>, List<int>>.fromHandlers(
            handleData: (data, sink) {
              sink.add(data);
              complete += data.length;
              logger.info("receive ${filesize(complete)} / ${filesize(len)}");
            },
          ),
        ),
      );

      f.close();
    });
  });

  test("throws not 2xx error", () async {
    await ctx.run(() async {
      await expectLater(
        c.fetch(Request.uri("$httpBinEndpoint/status/401")),
        throwsA(
          (e) => e is ResponseException && e.statusCode == 401,
        ),
      );
    });
  });

  test("cancel", () async {
    await ctx.run(() async {
      final cc = Context.withTimeout(const Duration(milliseconds: 1));

      await expectLater(
        cc.run(() => c.fetch(Request.uri("$httpBinEndpoint/status/200"))),
        throwsA(
          (e) => e is ResponseException && e.statusCode == 499,
        ),
      );
    });
  }, testOn: "vm"); // todo remove when upstream PR merged.
}
