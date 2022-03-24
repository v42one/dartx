import 'dart:async';
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:roundtripper/roundtripper.dart';

class RequestBodyConvert implements RoundTripBuilder {
  RequestBodyConvert();

  @override
  RoundTrip build(RoundTrip next) {
    return (request) async {
      if (request.requestBody != null) {
        return await next(request.copyWith(
          headers: {
            ...?request.headers,
            "Content-Type": request.headers?["Content-Type"] ??
                MediaType("application", "octet-stream").toString(),
          },
        ));
      }

      if (request.body == null) {
        return await next(request);
      }

      RequestBodyEncoder encoder = request.body is RequestBodyEncoder
          ? request.body
          : RequestBodyJsonEncoder(request.body!);

      return await next(request.copyWith(
        headers: {
          ...?request.headers,
          "Content-Type": "${encoder.contentType}",
        },
        requestBody: encoder.finalize(),
      ));
    };
  }
}

class RequestBodyJsonEncoder implements RequestBodyEncoder {
  Object data;

  RequestBodyJsonEncoder(this.data);

  final MediaType _contentType =
      MediaType("application", "json", {"charset": "utf-8"});

  @override
  MediaType get contentType => _contentType;

  @override
  Stream<List<int>> finalize() {
    return Stream.fromFuture(Future.value(data)).transform(
      StreamTransformer.fromBind(JsonUtf8Encoder().bind),
    );
  }
}
