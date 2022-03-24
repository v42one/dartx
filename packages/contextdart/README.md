## pure golang `context.Context` implements in dart

[![pub package](https://img.shields.io/pub/v/contextdart.svg)](https://pub.dev/packages/contextdart)
[![ci](https://github.com/v42one/contextdart/actions/workflows/ci.yaml/badge.svg)](https://github.com/v42one/contextdart/actions/workflows/ci.yaml)

Totally inspected by [context.Context](https://pkg.go.dev/context) from golang, and dart style fit.

### Usage

#### inject value or singleton in context

```dart
import 'package:contextdart/contextdart.dart';

class Logger {
  info(String msg) {
    
  }
}

void main() async {
  var ctx = Context.withValue(Logger());

  ctx.run(() {
    var log = Context.value<Logger>();

    log?.info("log");
  });
}
```

### Cancelable context.

```dart
import 'package:contextdart/contextdart.dart';

class Logger {
  info(String msg);
}

void main() async {
  var cctx = Context.withCancel();

  cctx.run(() {
    doAction();
    doDBAction();

    // cancel 
    cctx.cancel();
  });
}

doAction() async {
  return await Future.any([
    // if canceled, should ignore real action
    Context.done?.fisrt,
    Future(() => "do action"),
  ].whereType<Future>());
}

doDBAction() async {
  Context.done?.listen(() {
    // do some think like db rollback.
  });
}
```