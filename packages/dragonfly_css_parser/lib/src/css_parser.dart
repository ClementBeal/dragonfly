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
  Parser rule() => (ref0(selector) & ref0(declarations) & whitespaceOptional());

  Parser declarations() =>
      char("{") &
      ref0(whitespaceOptional) &
      ref0(declaration).star() &
      ref0(whitespaceOptional) &
      char("}");

  Parser declaration() =>
      ref0(property) &
      ref0(colon) &
      (ref0(propertyValue) & whitespaceOptional()).plus().flatten() &
      ref0(semicolon);

  Parser property() => ref0(identifier) & ref0(whitespaceOptional);

  Parser propertyValue() => ref0(propertyList).plus().flatten();

  Parser propertyList() =>
      ref0(fontFamilyValue) |
      ref0(propertyKeyWord) |
      ref0(propertyLength) |
      ref0(propertyColor) |
      ref0(propertyNumber);

  Parser fontFamilyValue() {
    return (ref0(quoteString).map((value) => value[1]) | ref0(unquotedFont))
        .plusSeparated(char(',').trim())
        .flatten();
  }

  Parser quotedFont() => ref0(quoteString);
  Parser unquotedFont() => ref0(identifier);

  Parser quoteString() {
    final quote = char('"');
    final quotedContent = any().starLazy(quote).flatten();
    return quote & quotedContent & quote;
  }

  /*
    Property value here
  */

  Parser propertyKeyWord() => (letter() | char('-')).plus();
  Parser propertyLength() => ref0(decimalNumber) | ref0(lengthUnit);
  Parser lengthUnit() =>
      string('px') | string('rem') | string('em') | string('%');
  Parser propertyColor() => ref0(propertyKeyWord) | ref0(hexColor);
  Parser propertyNumber() => ref0(decimalNumber) | digit().plus();

  Parser colon() => char(':') & ref0(whitespaceOptional);
  Parser semicolon() => char(';') & ref0(whitespaceOptional);

  Parser selector() =>
      ref0(selectorIdentifier) &
      pseudoClass().optional() &
      ref0(whitespaceOptional);
  Parser pseudoClass() => colon() & (letter()).plus();
  Parser selectorIdentifier() =>
      char('*') | ref0(identifier) | ref0(classSelector);
  Parser classSelector() => (char('.') & ref0(identifier)).flatten();

  /*
    White space
  */
  Parser whitespaceOptional() =>
      (whitespace() | comment() | multiLineComment()).star();
  Parser comment() => string("//") & pattern("\n").neg().star();
  Parser multiLineComment() =>
      string("/*") &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string("*/");

  /* 
    Specials  
  */
  Parser identifier() =>
      (letter() | char('-') | char('_') | digit()).plus().flatten();
  Parser hexColor() =>
      string('#') &
      (pattern('0-9a-fA-F').times(3) | pattern('0-9a-fA-F').times(6));
  Parser decimalNumber() => ref0(digit).star() & char('.') & ref0(digit).star();
  Parser number() => ref0(digit).plus();
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
