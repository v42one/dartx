import 'dart:async';

import 'package:contextdart/contextdart.dart';
import "package:test/test.dart";

class Int1 {}

class Int2 {}

void main() {
  test("#value", () {
    Context.withValue({
      "1": 11,
      "2": 22,
    }).run(() {
      expect(Context.value("2"), 22);
      expect(Context.value("1"), 11);
      expect(Context.value("x"), null);
    });
  });

  test("#value type match only", () {
    var int1 = Int1();
    var int2 = Int2();
    var int11 = Int1();

    Context.withValue([
      int1,
      int2,
    ]).run(() {
      Context.withValue(int11).run(() {
        expect(Context.value<Int1>(), int11);
        expect(Context.value<Int2>(), int2);
      });
    });
  });

  group("#withCancel", () {
    doChildJob() async {
      var childCCtx = Context.withCancel();

      return await childCCtx.run(() async => await Future.any([
            Context.done?.first,
            Stream.periodic(const Duration(seconds: 1))
                .map((e) => Exception("bomb!"))
                .first,
          ].whereType<Future>()));
    }

    doChildJobNested(int depth) {
      if (depth > 0) {
        return doChildJobNested(depth - 1);
      }
      return doChildJob();
    }

    test("#cancel", () async {
      var cctx = Context.withCancel();

      var cancel = Exception("cancel");

      doJob() async {
        var jobs = Future.any([
          Context.done?.first,
          Stream.periodic(const Duration(seconds: 1))
              .map((e) => Exception("bomb!"))
              .first,
        ].whereType<Future>());

        var ret = await jobs;
        expect(ret, cancel);
      }

      await cctx.run(() async {
        Future(() => cctx.cancel(cancel));
        await doJob();
      });
    });

    test("#withCancel should cancel children if exists", () async {
      var parentCCtx = Context.withCancel();

      await parentCCtx.run(() async {
        var job1 = doChildJob();
        var job2 = doChildJob();

        var cancel = Exception("parent cancel");

        parentCCtx.cancel(cancel);

        expect(await job1, cancel);
        expect(await job2, cancel);

        var jobAfterCancel = doChildJob();
        expect(await jobAfterCancel, cancel);
      });
    });

    test("#withCancel should cancel deep nested children", () async {
      var parentCCtx = Context.withCancel();

      await parentCCtx.run(() async {
        var job1 = doChildJobNested(10);

        var cancel = Exception("parent cancel");
        parentCCtx.cancel(cancel);

        expect(await job1, cancel);

        var jobAfterCancel = doChildJob();
        expect(await jobAfterCancel, cancel);
      });
    });
  });

  test("#withTimeout", () async {
    var cctx = Context.withTimeout(const Duration(milliseconds: 500));

    await cctx.run(() async {
      var jobs = Future.any([
        Context.done?.first,
        Stream.periodic(const Duration(seconds: 1))
            .map((e) => Exception("bomb!"))
            .first,
      ].whereType<Future>());

      var ret = await jobs;
      expect(ret, exceptionDeadlineExceeded);
    });
  });

  test("#withDeadline", () async {
    var cctx = Context.withDeadline(
      DateTime.now().add(const Duration(milliseconds: 500)),
    );

    await cctx.run(() async {
      var jobs = Future.any([
        Context.done?.first,
        Stream.periodic(const Duration(seconds: 1))
            .map((e) => Exception("bomb!"))
            .first,
      ].whereType<Future>());

      var ret = await jobs;
      expect(ret, exceptionDeadlineExceeded);
    });
  });
}
