import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:petitparser/petitparser.dart';

class CSSParserException implements Exception {
  String message;

  CSSParserException(this.message);

  @override
  String toString() => message;
}

class CssGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(term).end();

  Parser term() => ref0(styleSheet);

  Parser styleSheet() =>
      (whitespaceOptional() & ref0(rules) & whitespaceOptional()).pick(1);

  Parser rules() => ref0(rule).star();
  Parser rule() => (ref0(selector) & ref0(declarations));

  Parser declarations() =>
      char("{") &
      ref0(whitespaceOptional) &
      ref0(declaration).star() &
      ref0(whitespaceOptional) &
      char("}");

  Parser declaration() =>
      ref0(property) & ref0(colon) & ref0(propertyValue) & ref0(semicolon);
  Parser property() => ref0(identifier) & ref0(whitespaceOptional);
  Parser propertyValue() => digit().plus().flatten();

  Parser colon() => char(':') & ref0(whitespaceOptional);
  Parser semicolon() => char(';') & ref0(whitespaceOptional);

  Parser selector() => ref0(identifier) & ref0(whitespaceOptional);
  Parser whitespaceOptional() =>
      (whitespace() | comment() | multiLineComment()).star();

  Parser identifier() =>
      (char('.') | letter() | char('-') | digit()).plus().flatten();

  Parser comment() => string("//") & pattern("\n").neg().star();
  Parser multiLineComment() =>
      string("/*") &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string("*/");
}

class CssEvaluator extends CssGrammar {
  @override
  Parser styleSheet() => super.styleSheet().map(
        (value) => StyleSheet(value),
      );

  @override
  Parser rules() => super.rules().castList<Rule>();

  @override
  Parser rule() => super.rule().map(
        (value) {
          return Rule(value[0], value[1]);
        },
        // value[1]),
      );

  @override
  Parser selector() => super.selector().map(
        (value) => value[0],
      );

  @override
  Parser declarations() => super
      .declarations()
      .map(
        (value) => value[2],
      )
      .castList<Declaration>();

  @override
  Parser declaration() => super.declaration().map(
        (value) {
          print(value[2]);
          return Declaration(value[0], value[2]);
        },
      );

  @override
  Parser property() => super.property().map(
        (value) {
          return value[0];
        },
      );
}

class CssParser {
  final parser = CssEvaluator();

  StyleSheet parse(String input) {
    var result = parser.build().parse(input);

    switch (result) {
      case Success():
        return result.value as StyleSheet;

      case Failure():
        throw CSSParserException(result.message);
    }
  }
}
