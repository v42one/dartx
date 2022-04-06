import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

class PathFixer {
  String pkgName;
  Directory pkgRoot;
  List<String>? importPaths;

  PathFixer(
    this.pkgName, {
    required this.pkgRoot,
    this.importPaths,
  });

  Future<void> fix(String filename, {bool? apply}) async {
    var ast = parseFile(
      path: filename,
      featureSet: FeatureSet.latestLanguageVersion(),
    );

    var patcher = ImportsPatcher(this, filename: filename);

    patcher.visit(ast.unit);

    if (patcher.hasChanges && (apply ?? false)) {
      print("[pubtidy] ${p.relative(filename, from: pkgRoot.path)} fixed.");

      await File(filename).writeAsBytes(
        patcher.apply(ast.content.codeUnits),
      );
    }
  }

  String import(String i, {required String at}) {
    var u = Uri.parse(i);

    var atPkg = _resolve("${pkgName}/${p.relative(at, from: pkgRoot.path)}");

    if (u.scheme == "package") {
      var importPkg = _resolve(u.path);

      if (importPkg == atPkg ||
          importPkg == atPkg.replaceFirst("${pkgName}/src/", "${pkgName}/")) {
        print("[pubtidy] should not import entry `${importPkg}` at ${at}");
      }

      return "${u.scheme}:${_resolve(u.path)}";
    }

    if (u.scheme != "") {
      return i;
    }

    if (i.startsWith("../")) {
      var fullPath = p.relative(
        p.normalize(p.join(p.dirname(at), i)),
        from: pkgRoot.path,
      );

      var importPkg = _resolve("${pkgName}/${fullPath}");

      print("[${atPkg}] ${at}");
      print("[${importPkg}] ${fullPath}");

      if (importPkg != atPkg) {
        return "package:${importPkg}";
      }
    }

    return i;
  }

  String _resolve(String path) {
    var parts = path.split("/");

    if (parts.length > 2 && parts.first == pkgName) {
      // ignore pkgName
      parts.removeAt(0);

      // ignore lib if exists
      if (parts.first == "lib") {
        parts.removeAt(0);
      }

      var path = parts.join("/");

      var i = importPaths?.indexWhere((importPath) =>
              path.startsWith("${importPath}.dart") ||
              path.startsWith("${importPath}/")) ??
          -1;

      if (i > -1) {
        return "${pkgName}/${importPaths![i]}.dart";
      }

      return "${pkgName}/${path}";
    }

    return path;
  }
}

class ImportsPatcher extends SimpleAstVisitor<ImportDirective> {
  final PathFixer fixer;
  String filename;

  ImportsPatcher(
    this.fixer, {
    required this.filename,
  }) : super();

  Map<int, Patch> _patches = {};
  Map<String, bool> _fixedImportPaths = {};

  bool get hasChanges => _patches.isNotEmpty;

  List<int> apply(List<int> contents) {
    var buf = StringBuffer();

    var i = 0;
    while (i < contents.length) {
      var c = contents[i];

      if (_patches.containsKey(i)) {
        var patch = _patches[i]!;
        buf.write(patch.replaceTo);
        i = i + patch.length;
        continue;
      }

      buf.writeCharCode(c);
      i++;
    }

    return utf8.encode(buf.toString());
  }

  void visit(CompilationUnit unit) {
    unit.visitChildren(this);
  }

  @override
  ImportDirective? visitImportDirective(ImportDirective node) {
    var sl = node.uri;

    var importPath = sl.stringValue ?? "";
    var fixedImportPath = fixer.import(importPath, at: filename);

    if (fixedImportPath != importPath) {
      if (_fixedImportPaths.containsKey(fixedImportPath)) {
        addPatch(Patch.fromAstNode(node, replaceTo: ""));
        return null;
      }
      addPatch(Patch.fromAstNode(sl, replaceTo: "'${fixedImportPath}'"));
      _fixedImportPaths[fixedImportPath] = true;
    }

    return null;
  }

  void addPatch(Patch patch) {
    _patches[patch.offset] = patch;
  }
}

class Patch {
  factory Patch.fromAstNode(
    AstNode astNode, {
    required String replaceTo,
  }) {
    return Patch(
      replaceTo: replaceTo,
      offset: astNode.offset,
      // if Directive should include the `\n`
      length: astNode.length + (astNode is Directive ? 1 : 0),
    );
  }

  int offset;
  int length;
  String replaceTo;

  Patch({
    required this.offset,
    required this.length,
    required this.replaceTo,
  });
}
