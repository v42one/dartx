import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:roundtripper/roundtripbuilders/request_body_convert.dart';
import 'package:roundtripper/roundtripbuilders/request_log.dart';
import 'package:roundtripper/roundtripbuilders/throws_not_2xx_error.dart';
import 'package:roundtripper/roundtripper.dart';
import 'package:test/test.dart';

var logger = Logger(StdLogSink("roundtripper"));

var httpBinEndpoint = "https://httpbin.org";

class FormDataExtra extends FormData implements RequestBodyEncoder {
  FormDataExtra() : super();

  factory FormDataExtra.fromMap(
    Map<String, dynamic> m, [
    ListFormat collectionFormat = ListFormat.multi,
  ]) {
    var fd = FormData.fromMap(m, collectionFormat);

    return (FormDataExtra()
      ..fields.addAll(fd.fields)
      ..files.addAll(fd.files));
  }

  @override
  MediaType get contentType => MediaType(
        'multipart',
        'form-data',
        {
          "boundary": boundary,
        },
      );
}

void main() async {
  var c = Client(roundTripBuilders: [
    ThrowsNot2xxError(),
    RequestBodyConvert(),
    RequestLog(),
  ]);

  var ctx = Logger.withLogger(logger);

  test("form data", () async {
    var fd = FormDataExtra.fromMap({
      "field": "f",
      "file": MultipartFile.fromString("123"),
    });

    await ctx.run(() async {
      var resp = await c.fetch(Request.uri(
        "$httpBinEndpoint/anything",
        method: "POST",
        body: fd,
      ));

      expect(resp.statusCode, 200);

      var json = await resp.json();

      expect(json["form"], {"field": "f", "file": "123"});
    });
  });
}
