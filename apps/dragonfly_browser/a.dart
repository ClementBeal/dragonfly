import 'dart:io';

import 'package:dragonfly/browser/css/css_parser.dart';
import 'package:dragonfly/browser/css/cssom_builder.dart';

void main() {
  final css = File("style.css").readAsStringSync();

  // final s = CssomBuilder().parse(css);
  // final a = Stopwatch()..start();
  final s = CssParser(css).parse();
  // print(a.elapsedMicroseconds);

  for (var rule in s.rules) {
    print("${rule.selector}");
  }
  // print(s.find("body"));
}
