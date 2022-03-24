import 'dart:typed_data';

import 'package:contextdart/contextdart.dart';

import 'adapter.dart';
import 'http_status.dart';
import 'interfaces.dart';
import 'request.dart';
import 'response.dart';

typedef Conn = HttpClientAdapter Function();

class Client {
  final List<RoundTripBuilder> roundTripBuilders;
  late Conn conn;

  Client({
    Conn? conn,
    this.roundTripBuilders = const [],
  }) {
    this.conn = conn ?? createAdapter;
  }

  Future<Response> fetch(Request request) {
    RoundTrip rt = _send;
    for (var n = roundTripBuilders.length - 1; n >= 0; n--) {
      rt = roundTripBuilders[n].build(rt);
    }
    return rt(request);
  }

  Future<Response> _send(Request request) async {
    var c = conn();

    try {
      var resp = await c.fetch(
        RequestOptions(
          method: request.method,
          path: request.uri.toString(),
          headers: request.headers?.map(
            (key, value) =>
                MapEntry(key, value is List ? value.join(", ") : value),
          ),
          validateStatus: (i) => true,
        ),
        request.requestBody?.map((list) => Uint8List.fromList(list)),
        Context.done?.map((e) {
          return ResponseException.fromException(
            HttpStatus.clientClosedRequest,
            e,
          );
        }).first,
      );

      return Response(
        request: request,
        statusCode: resp.statusCode ?? -1,
        headers: resp.headers,
        responseBody: resp.stream.map((list) => list.toList()),
      );
    } catch (e) {
      var cancelError = Context.done?.value;
      if (cancelError != null) {
        throw ResponseException.fromException(
          HttpStatus.clientClosedRequest,
          e as Exception,
        );
      }
      rethrow;
    } finally {
      c.close();
    }
  }
}
