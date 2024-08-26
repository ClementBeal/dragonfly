import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Pseudo class', () {
    final cssParser = CssParser();

    test('Empty rule', () {
      final css = "a:active {}";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "a");
      expect(result.rules[0].declarations.isEmpty, true);
    });
  });
}
