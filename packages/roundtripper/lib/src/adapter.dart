export 'package:dio/dio.dart' show HttpClientAdapter, RequestOptions;
export 'package:dio/src/adapters/io_adapter.dart'
    if (dart.library.html) 'package:dio/src/adapters/browser_adapter.dart'
    show createAdapter;
