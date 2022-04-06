import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubtidy/patchfixer.dart';

import '_path_extension.dart';

class Workspace {
  Directory root;

  Workspace(this.root) {}

  Future<void> run() async {
    var pkgName = await _pkgName();

    var lib = root.dir("lib");

    List<String>? bases;

    if (await root.dir("src").exists()) {
      await _generateEntryFiles(root.dir("src"));
    } else {
      await (await lib.list(recursive: false))
          .where((f) => f is Directory)
          .cast<Directory>()
          .forEach(
        (dir) async {
          bases = [...?bases, p.basenameWithoutExtension(dir.path)];

          await _generateEntryFiles(dir);
        },
      );
    }

    var pf = PathFixer(pkgName, pkgRoot: root, bases: bases);

    await Future.forEach<String>([
      "lib",
      "test",
      "bin",
      "example",
    ], (src) async {
      var base = root.dir(src);

      if (await base.exists()) {
        await (await _walkDartFiles(base)).forEach((f) async {
          await pf.fix(f.path, apply: true);
        });
      }
    });
  }

  Future<void> _generateEntryFiles(Directory namespace) async {
    Map<String, List<String>> exportFiles = {};

    await (await _walkDartFiles(namespace)).forEach((f) async {
      var relPath = namespace.relative(f.path);

      var parts = relPath.split("/");

      // skip <base>/*.dart and private files
      if (parts.length == 1 || parts.any((p) => p.startsWith("_"))) {
        return;
      }

      var base = p.basenameWithoutExtension(namespace.path);

      var exportFile =
          base == "src" ? "${parts.first}.dart" : "${base}/${parts.first}.dart";

      if (!exportFiles.containsKey(exportFile)) {
        exportFiles[exportFile] = [];
      }

      exportFiles[exportFile]!.add(
        base == "src" ? "src/${relPath}" : relPath,
      );
    });

    await _sync(exportFiles);
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

  Future<Stream<File>> _walkDartFiles(Directory base) async {
    if (!(await base.exists())) {
      await base.create(recursive: true);
    }
    final file$ = await base.list(recursive: true, followLinks: false);
    return file$.where((f) => f is File && f.extname == ".dart").cast<File>();
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
