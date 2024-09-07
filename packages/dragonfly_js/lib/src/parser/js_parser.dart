import 'package:dragonfly_js/src/parser/js_ast.dart';
import 'package:petitparser/petitparser.dart';

class JavascriptGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(compilationUnit).end().castList<Tree>().map(
        (value) => ProgramNode(
          children: value,
        ),
      );

  Parser compilationUnit() =>
      (ref0(mathExpression) | ref0(unaryExpression) | ref0(numberPrimitive))
          .star();

  // Math

  Parser mathExpression() =>
      ref0(numberPrimitive) &
      hiddenWhitespace() &
      mathOperator() &
      hiddenWhitespace() &
      ref0(numberPrimitive);

  Parser unaryExpression() =>
      (ref0(negativeOperator) & ref0(numberPrimitive)).map(
        (value) {
          return UnaryExpressionNode(
            value[0],
            value[1],
          );
        },
      );

  Parser negativeOperator() => char('-');

  Parser mathOperator() => char("+").map(
        (value) => switch (value) {
          _ => Operator.plus,
        },
      );

  // Tokens

  Parser<void> numberPrimitive() => <Parser<void>>[
        char('-').optional(),
        [char('0'), digit().plus()].toChoiceParser(),
        [char('.'), digit().plus()].toSequenceParser().optional(),
        [anyOf('eE'), anyOf('-+').optional(), digit().plus()]
            .toSequenceParser()
            .optional()
      ].toSequenceParser().flatten().map(
            (value) => NumberNode(
              num.parse(value),
            ),
          );

  // Tokens

  Parser newlineLexicalToken() => pattern('\n\r');

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------
  Parser hiddenWhitespace() => ref0(hiddenStuffWhitespace).plus();

  Parser hiddenStuffWhitespace() =>
      ref0(visibleWhitespace) |
      ref0(singleLineComment) |
      ref0(multiLineComment);

  Parser visibleWhitespace() => whitespace();

  Parser singleLineComment() =>
      string('//') &
      ref0(newlineLexicalToken).neg().star() &
      ref0(newlineLexicalToken).optional();

  Parser multiLineComment() =>
      string('/*') &
      (ref0(multiLineComment) | string('*/').neg()).star() &
      string('*/');
}

class JavascriptGrammarDefinition extends JavascriptGrammar {
  @override
  Parser mathExpression() => super.mathExpression().map(
        (value) => OperationNode(
          operator: value[2],
          left: value[0],
          right: value[4],
        ),
      );
}

class JavascriptParser {
  Tree parse(String code) {
    final a = JavascriptGrammarDefinition();
    final parser = a.build();

    return parser.parse(code).value;
  }
}
