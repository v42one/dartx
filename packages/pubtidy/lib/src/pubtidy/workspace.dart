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

    var entries = await _collectEntries(lib);

    await _syncExportFiles(entries);

    var importPaths = entries.keys
        .where((e) => e != "src.dart")
        .map((e) => e.substring(0, e.length - ".dart".length))
        .toList()
      ..sort((a, b) => b.split("/").length.compareTo(a.split("/").length));

    var pf = PathFixer(
      pkgName,
      pkgRoot: root,
      importPaths: importPaths,
    );

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

  Future<Map<String, List<String>>> _collectEntries(
    Directory base, {
    String? entry,
  }) async {
    Map<String, List<String>> entries = {};

    var paths = await base.list(recursive: false).toList();

    await Future.forEach<FileSystemEntity>(paths, (path) async {
      var relPath = base.relative(path.path);

      // skip  private files
      if (relPath.startsWith("_")) {
        return;
      }

      if (path is Directory) {
        var subEntries = await _collectEntries(
          path,
          entry: "${root.dir("lib").relative(path.path)}.dart",
        );

        entries = {
          ...entries,
          ...subEntries,
        };

        if (entry != null) {
          entries[entry] = [
            ...?entries[entry],
            "${p.basenameWithoutExtension(base.path)}/${relPath}.dart",
          ];
        }
        return;
      }

      if (entry != null && path is File && path.extname == ".dart") {
        entries[entry] = [
          ...?entries[entry],
          "${p.basenameWithoutExtension(base.path)}/${relPath}",
        ];
      }

      return;
    });

    return entries;
  }

  Future<void> _syncExportFiles(Map<String, List<String>> exportFiles) async {
    final lib = root.dir("lib");

    await Future.forEach<MapEntry<String, List<String>>>(
      exportFiles.entries,
      (e) async {
        var depth = e.key.split("/").length - 1;

        if (depth < 1) {
          return null;
        }

        var f = lib.file(e.key);
        await f.create(recursive: true);
        await f.writeAsString(
          e.value.toSet().map((f) => "export '${f}';").join("\n"),
        );

        if (e.key.startsWith("src/") && depth == 1) {
          var f = lib.file(e.key.substring("src/".length));
          await f.create(recursive: true);
          await f.writeAsString("export '${e.key}';");
        }
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
