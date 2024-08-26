import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Selector', () {
    final cssParser = CssParser();

    test("", () {
      final css = """.markdown-content ul,
.markdown-content ol {
  margin-top: 1em;
  margin-bottom: 1em;
  padding-left: 2em;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 2);
      expect(result.rules[0].selector, ".markdown-content ul");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "margin-before");
      expect(result.rules[0].declarations[0].value, "0.67em");
      expect(result.rules[1].selector, ".markdown-content ol");
      expect(result.rules[1].declarations.length, 1);
      expect(result.rules[1].declarations[0].property, "margin-before");
      expect(result.rules[1].declarations[0].value, "0.67em");
    });
  });
}
