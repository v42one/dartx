import 'package:http_parser/http_parser.dart';

import 'request.dart';
import 'response.dart';

abstract class RoundTripBuilder {
  RoundTrip build(RoundTrip next);
}

typedef RoundTrip = Future<Response> Function(Request request);

abstract class RequestBodyEncoder {
  MediaType get contentType;
  Stream<List<int>> finalize();
}
