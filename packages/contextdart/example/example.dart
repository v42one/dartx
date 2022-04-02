import 'package:contextdart/src/contextdart/contextdart.dart';

class Hello {}

void main() async {
  var ctx = Context.withValue([
    const MapEntry("some comparable key", "value will put into context"),
    Hello(),
  ]);

  ctx.run(() {
    getValueFromContextByKey();
    getValueFromContextByType();
    canceledContext();
  });
}

getValueFromContextByKey() {
  // in deep function;
  var v = Context.value("some comparable key");
  // ignore: avoid_print
  print(v);
}

getValueFromContextByType() {
  // in deep function;
  var v = Context.value<Hello>();
  // ignore: avoid_print
  print(v);
}

canceledContext() {
  var cctx = Context.withCancel();

  cctx.run(() {
    // async action
    Future.any([
      Context.done?.first,
      Stream.periodic(const Duration(seconds: 1))
          .map((e) => Exception("bomb!"))
          .first,
    ].whereType<Future>());

    // cancel cause something like timeout
    cctx.cancel();
  });
}
