import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Comments', () {
    final cssParser = CssParser();

    test('Ignore single line comment', () {
      final css = "// empty css";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });
    test(
        'Ignore single line comment with no space between the separator and the comment',
        () {
      final css = "//empty css";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });
    test('Ignore single line comment with endline', () {
      final css = "// empty css\n";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });

    test('Multiple single line comments', () {
      final css = "// empty css\n// another comment";
      final result = cssParser.parse(css);

      expect(result.rules.isEmpty, true);
    });

    test('Single line comments with a rule in the middle', () {
      final css = "// empty css\nbody {}\n// another comment";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.isEmpty, true);
    });

    test('Single line commentright after a rule', () {
      final css = "body {} // another comment";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.isEmpty, true);
    });
    test('Single line comment right after a rule', () {
      final css = "body {}// another comment";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.isEmpty, true);
    });

    test('Single line in a rule\'s declaration', () {
      final css = "body {// another comment}";
      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.isEmpty, true);
    });
  });
}
