import 'dart:io';

import 'package:path/path.dart' as p;

extension DirectoryUtils on Directory {
  File file(String filename) {
    return File(p.join(this.path, filename));
  }

  Directory dir(String path) {
    return Directory(p.join(this.path, path));
  }

  String relative(String path) {
    return p.relative(path, from: this.path);
  }
}

extension FilePaths on File {
  String get basename {
    return p.basename(this.path);
  }

  String get extname {
    return p.extension(this.path);
  }
}
