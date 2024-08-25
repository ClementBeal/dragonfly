import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Comments', () {
    final cssParser = CssParser();

    test('Ignore multiline comment', () {
      final css = "/* empty css */";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });
    test('Multiline comment spread on few lines', () {
      final css = "/*\n  empty css\n*/";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });

    test('Multiline comment spread on few lines with stars', () {
      final css = "/*\n*  empty css\n*/";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });

    test('Multiline comment spread on few lines with stars', () {
      final css = "/*\n*  empty css\n*/";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });

    test('Multiline comment spread with a rule inside', () {
      final css = "/*\n*  body {} \n*/";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });
    test('Multiline comment spread with a rule outside', () {
      final css = "/*\n* the rule is for body\n*/ body {}";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.isEmpty, true);
    });
  });
}
