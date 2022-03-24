import 'package:freezed_annotation/freezed_annotation.dart';

part '__generated__/request.freezed.dart';

@freezed
class Request<T> with _$Request<T> {
  Request._();

  factory Request({
    required String method,
    required Uri uri,
    Map<String, dynamic>? headers,
    T? body,
    Stream<List<int>>? requestBody,
  }) = _Request<T>;

  factory Request.uri(
    String uri, {
    String method = "GET",
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T? body,
  }) {
    var u = Uri.parse(uri);

    return Request<T>(
      method: method.toUpperCase(),
      uri: Uri(
        scheme: u.scheme,
        host: u.host,
        port: u.port,
        path: u.path,
        fragment: u.fragment != "" ? u.fragment : null,
        queryParameters: {
          ...u.queryParameters,
          ...?queryParameters?.map(
            (key, value) => MapEntry(
                key,
                value is List
                    ? value.map((e) => e.toString())
                    : [value.toString()]),
          ),
        },
      ),
      headers: headers,
      body: body,
    );
  }

  @override
  String toString() {
    return "$method $uri";
  }
}
