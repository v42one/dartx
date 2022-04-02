import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubtidy/patchfixer.dart';
import 'package:test/test.dart';

void main() async {
  var px = PathFixer("pubtidy", pkgRoot: Directory.current);

  var importedAt =
      p.normalize(p.join(Directory.current.path, "test/imports_test.dart"));

  test("path fix", () {
    expect(
        px.import("package:pubtidy/src/imports/pathfixer.dart", at: importedAt),
        equals("package:pubtidy/imports.dart"));

    expect(px.import("imports.dart", at: importedAt), equals("imports.dart"));

    expect(px.import("../lib/src/imports/pathfixer.dart", at: importedAt),
        equals("package:pubtidy/imports.dart"));
  });

  test("ImportsFormatter 中文测试", () async {
    await px.fix(importedAt, apply: true);
  });
}
