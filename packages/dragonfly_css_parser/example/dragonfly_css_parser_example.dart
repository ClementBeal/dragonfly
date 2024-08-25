import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';

void main() {
  final parser = CssParser();
  final stylesheet = parser.parse("""
body {
  margin: 0; // it's the magin
}
""");

  print(stylesheet.rules.length); // 1 rule
}
