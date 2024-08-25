import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Rule', () {
    final cssParser = CssParser();

    test('Empty rule', () {
      final css = "body {}";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.isEmpty, true);
    });
    test('Rule with one declaration', () {
      final css = "body { margin: 0; }";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "margin");
      expect(result.rules[0].declarations[0].value, "0");
    });
    test('Rule with multiple declarations', () {
      final css = "body { margin: 0;margin-top: 0; }";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 2);
      expect(result.rules[0].declarations[0].property, "margin");
      expect(result.rules[0].declarations[0].value, "0");
      expect(result.rules[0].declarations[1].property, "margin-top");
      expect(result.rules[0].declarations[1].value, "0");
    });

    test('Class rule', () {
      final css = ".body { margin: 0;margin-top: 0; }";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, ".body");
      expect(result.rules[0].declarations.length, 2);
      expect(result.rules[0].declarations[0].property, "margin");
      expect(result.rules[0].declarations[0].value, "0");
      expect(result.rules[0].declarations[1].property, "margin-top");
      expect(result.rules[0].declarations[1].value, "0");
    });
  });
}
