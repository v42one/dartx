import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubtidy/patchfixer.dart';
import 'package:test/test.dart';

void main() async {
  group("layout", () {
    var importedAt = p.normalize(
      p.join(Directory.current.path, "lib/src/patchfixer/patchfixer.dart"),
    );

    var px = PathFixer(
      "pubtidy",
      pkgRoot: Directory.current,
      importPaths: [
        "src/patchfixer",
        "src/pubtidy",
        "domain/account_xx",
        "domain/account",
        "domain/xx",
        "view/account",
      ],
    );

    test("path fix", () {
      expect(
        px.import("package:pubtidy/src/pubtidy/pubtidy.dart", at: importedAt),
        equals("package:pubtidy/src/pubtidy.dart"),
      );

      expect(
        px.import("../pubtidy.dart", at: importedAt),
        equals("package:pubtidy/src/pubtidy.dart"),
      );

      expect(
        px.import("../account.dart",
            at: p.normalize(
              p.join(Directory.current.path, "lib/domain/xx/a.dart"),
            )),
        equals("package:pubtidy/domain/account.dart"),
      );

      expect(
        px.import("relative.dart", at: importedAt),
        equals("relative.dart"),
      );
    });

    test("ImportsFormatter 中文测试", () async {
      var importedAt = p.normalize(
        p.join(Directory.current.path, "test/patchfixer_test.dart"),
      );

      await px.fix(importedAt, apply: true);
    });
  });
}
