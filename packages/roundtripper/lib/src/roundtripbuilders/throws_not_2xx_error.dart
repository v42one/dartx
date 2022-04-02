import 'package:roundtripper/roundtripper.dart';

class ThrowsNot2xxError implements RoundTripBuilder {
  ThrowsNot2xxError();

  @override
  RoundTrip build(RoundTrip next) {
    return (request) async {
      var resp = await next(request);
      if (resp.statusCode >= HttpStatus.badRequest) {
        throw ResponseException(resp.statusCode, response: resp);
      }
      return resp;
    };
  }
}
