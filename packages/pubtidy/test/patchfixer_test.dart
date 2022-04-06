import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubtidy/patchfixer.dart';
import 'package:test/test.dart';

void main() async {
  var importedAt =
      p.normalize(p.join(Directory.current.path, "test/patchfixer_test.dart"));

  group("flutter layout", () {
    var px = PathFixer("pubtidy", pkgRoot: Directory.current, bases: [
      "domain",
      "view",
    ]);

    test("path fix", () {
      expect(
        px.import("package:pubtidy/domain/account/account.dart",
            at: importedAt),
        equals("package:pubtidy/domain/account.dart"),
      );
    });
  });

  group("lib layout", () {
    var px = PathFixer("pubtidy", pkgRoot: Directory.current);

    test("path fix", () {
      expect(
        px.import("package:pubtidy/src/imports/pathfixer.dart", at: importedAt),
        equals("package:pubtidy/imports.dart"),
      );

      expect(
        px.import("imports.dart", at: importedAt),
        equals("imports.dart"),
      );

      expect(
        px.import("../lib/src/imports/pathfixer.dart", at: importedAt),
        equals("package:pubtidy/imports.dart"),
      );

      expect(
        px.import("../lib/pathfixer.dart", at: importedAt),
        equals("package:pubtidy/pathfixer.dart"),
      );
    });

    test("ImportsFormatter 中文测试", () async {
      await px.fix(importedAt, apply: true);
    });
  });
}
