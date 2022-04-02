import 'dart:math';

import 'hex.dart';

abstract class IDGenerator {
  factory IDGenerator() = _RandomIDGenerator;

  String spanID(String traceID);

  String traceID();
}

const _fallbackSpanID = '0000000000000001';
const _invalidSpanID = '0000000000000000';

class _RandomIDGenerator implements IDGenerator {
  @override
  String spanID(String traceID) {
    var spanId = _generateRandomBytes(8);
    if (spanId == _invalidSpanID) {
      return _fallbackSpanID;
    }
    return spanId;
  }

  @override
  String traceID() {
    var unixSeconds = (DateTime.now().toUtc().millisecondsSinceEpoch ~/
        Duration.millisecondsPerSecond);

    return (unixSeconds << 32).toRadixString(16) + _generateRandomBytes(8);
  }

  final _seededIDGen = Random();

  String _generateRandomBytes(int bytes) {
    return (const HexEncoder())
        .convert(List.generate(bytes, (_) => _seededIDGen.nextInt(255)));
  }
}
