import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:test/test.dart';

void main() {
  group('Test  how we get the rule\'s properties', () {
    final cssParser = CssParser();

    test("Simple keyword", () {
      final css = """body {
  color: red;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "color");
      expect(result.rules[0].declarations[0].value, "red");
    });

    test("Color hex with 3 numbers", () {
      final css = """body {
  color: #fff;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "color");
      expect(result.rules[0].declarations[0].value, "#fff");
    });

    test("Color hex with 6 numbers", () {
      final css = """body {
  color: #ffeeaa;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "color");
      expect(result.rules[0].declarations[0].value, "#ffeeaa");
    });

    test("Color hex mixing caps and lowers", () {
      final css = """body {
  color: #ffEEaa;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "color");
      expect(result.rules[0].declarations[0].value, "#ffEEaa");
    });

    test("Units", () {
      final units = [
        "px",
        "rem",
        "em",
        "vw",
        "vh",
        "%",
        "in",
        "cm",
        "mm",
        "pt",
        "pc",
        "ex",
        "ch",
        "vmin",
        "vmax"
      ];

      for (var unit in units) {
        final css = """body {
  font-size: $unit;
}""";

        final result = cssParser.parse(css);

        expect(result.rules.length, 1);
        expect(result.rules[0].selector, "body");
        expect(result.rules[0].declarations.length, 1);
        expect(result.rules[0].declarations[0].property, "font-size");
        expect(result.rules[0].declarations[0].value, unit);
      }
    });

    test("Number", () {
      final css = """body {
  line-height: 1.4;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "line-height");
      expect(result.rules[0].declarations[0].value, "1.4");
    });

    test("List", () {
      final css = """body {
  font-family: Georgia, serif;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "font-family");
      expect(result.rules[0].declarations[0].value, "Georgia, serif");
    });
    test("List with quotes", () {
      final css = """body {  
      font-family: "Roboto", sans-serif;
}""";

      final result = cssParser.parse(css);

      expect(result.rules.length, 1);
      expect(result.rules[0].selector, "body");
      expect(result.rules[0].declarations.length, 1);
      expect(result.rules[0].declarations[0].property, "font-family");
      expect(result.rules[0].declarations[0].value, '"Roboto", sans-serif');
    });
  });
}
