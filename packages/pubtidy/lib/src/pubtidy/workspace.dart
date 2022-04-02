import 'dart:io';

import 'package:pubtidy/patchfixer.dart';

import '_path_extension.dart';

class Workspace {
  Directory root;

  Workspace(this.root) {}

  Future<void> run() async {
    var pkgName = await _pkgName();

    await _generateEntryFiles();

    var pf = PathFixer(pkgName, pkgRoot: root);

    await (await _walk(root.dir("lib/src"))).forEach((f) async {
      await pf.fix(f.path, apply: true);
    });

    await (await _walk(root.dir("test"))).forEach((f) async {
      await pf.fix(f.path, apply: true);
    });
  }

  Future<void> _generateEntryFiles() async {
    var src = root.dir("lib/src");

    Map<String, List<String>> exportFiles = {};

    await (await _walk(root.dir("lib/src"))).forEach((f) async {
      if (f.extname != ".dart") {
        return;
      }

      var rp = src.relative(f.path);

      var parts = rp.split("/");

      // skip src/*.dart and private files
      if (parts.length == 1 || parts.any((p) => p.startsWith("_"))) {
        return;
      }

      var exportFile = "${parts.first}.dart";

      if (!exportFiles.containsKey(exportFile)) {
        exportFiles[exportFile] = [];
      }

      exportFiles[exportFile]!.add("src/${rp}");
    });

    _sync(exportFiles);
  }

  Future<void> _sync(Map<String, List<String>> exportFiles) async {
    final lib = root.dir("lib");

    await Future.forEach<MapEntry<String, List<String>>>(
      exportFiles.entries,
      (e) async {
        var f = lib.file(e.key);

        await f.create(recursive: true);

        return await f.writeAsString(
          e.value.map((f) => "export '${f}';").join("\n"),
        );
      },
    );

    return;
  }

  Future<Stream<File>> _walk(Directory base) async {
    final file$ = await base.list(recursive: true, followLinks: false);
    return file$.where((f) => f is File).cast<File>();
  }

  Future<String> _pkgName() async {
    final pubspecYamlFile = root.file("pubspec.yaml");
    if (!(await pubspecYamlFile.exists())) {
      throw Exception(
          "pubspec.yaml not found, do you run command in the root of a dart pub ");
    }

    var lines = await pubspecYamlFile.readAsLines();

    for (var i = 0; i < lines.length; i++) {
      var l = lines[i];

      if (l.startsWith("name:")) {
        return l.substring("name:".length).trim();
      }
    }

    return "";
  }
}
