import 'dart:convert';

import 'request.dart';

class Response<T> {
  final Request request;
  final int statusCode;
  final Map<String, List<String>> headers;
  final Stream<List<int>> responseBody;

  T? body;

  Response({
    required this.statusCode,
    required this.headers,
    required this.responseBody,
    required this.request,
  });

  int? _contentLength;

  int get contentLength {
    _contentLength ??= int.parse(headers["content-length"]?.first ?? "-1");
    return _contentLength!;
  }

  List<int>? _blob;

  Future<List<int>> blob() async {
    _blob ??= await responseBody.expand((e) => e).toList();
    return _blob!;
  }

  Future<String> text() async {
    return utf8.decode(await blob());
  }

  Future<dynamic> json() async {
    return jsonDecode(utf8.decode(await blob()));
  }
}

class ResponseException<T> implements Exception {
  final int statusCode;
  final String? reason;
  final Response<T>? response;

  static ResponseException fromException(int statusCode, Exception e) {
    return ResponseException(statusCode, reason: e.toString());
  }

  ResponseException(
    this.statusCode, {
    this.response,
    this.reason,
  });

  @override
  String toString() {
    return response?.body?.toString() ?? "$statusCode";
  }
}
