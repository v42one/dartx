import 'dart:io';

import 'package:pubtidy/pubtidy.dart';

void main() async {
  var w = Workspace(Directory.current);
  await w.run();
}
