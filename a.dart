import 'dart:io';

import 'package:dragonfly/browser/dom_builder.dart';

void main() {
  final html = File(r"a.html").readAsStringSync();

  final dom = DomBuilder().parse(html);

  print(dom.toString());
}
