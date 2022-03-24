Another composable, multi-platform HTTP client

[![pub package](https://img.shields.io/pub/v/roundtripper.svg)](https://pub.dev/packages/roundtripper)
[![ci](https://github.com/v42one/roundtripper/actions/workflows/ci.yaml/badge.svg)](https://github.com/v42one/roundtripper/actions/workflows/ci.yaml)

Totally inspected by [http.RoundTripper](https://pkg.go.dev/net/http#RoundTripper) from golang, and dart style fit.
Based on [dio](https://github.com/flutterchina/dio) for crossing-platforms support.

You could do any processing for each request in `RoundTrip`.

* Logging.
* Throws non-2xx Response as Error.
* Request/Response Body Encoding.
