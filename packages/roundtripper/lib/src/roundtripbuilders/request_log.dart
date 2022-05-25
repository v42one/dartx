import 'package:logr/logr.dart';
import 'package:roundtripper/roundtripper.dart';

class RequestLog implements RoundTripBuilder {
  @override
  RoundTrip build(RoundTrip rt) {
    return (request) async {
      var logger = Logger.current;

      var requestStart = DateTime.now();

      var response = await rt(request);

      if (response.statusCode >= HttpStatus.badRequest) {
        if (response.statusCode >= HttpStatus.internalServerError) {
          logger?.error(
            ResponseException(response.statusCode, response: response),
            _logEntities(response, requestStart),
          );
        } else {
          logger?.info(_logEntities(response, requestStart));
        }
      } else {
        logger?.info(_logEntities(response, requestStart));
      }

      return response;
    };
  }

  Map _logEntities(Response response, DateTime requestStart) {
    var cost = DateTime.now().difference(requestStart);

    return {
      "request": response.request.toString(),
      "status": response.statusCode,
      "cost": _formatDuration(cost),
    };
  }

  String _formatDuration(Duration d) {

    var microseconds = d.inMicroseconds;
    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);
    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    var milliseconds = microseconds ~/ Duration.millisecondsPerSecond;

    return [
      hours > 0 ? "${hours}h" : "",
      minutes > 0 ? "${minutes}m" : "",
      seconds > 0 ? "${seconds}s" : "",
      milliseconds > 0 ? "${milliseconds}ms" : "",
    ].join("");
  }
}
