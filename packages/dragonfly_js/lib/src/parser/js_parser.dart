import 'package:dragonfly_js/src/parser/js_ast.dart';
import 'package:petitparser/petitparser.dart';

class JavascriptGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(compilationUnit).star().end().castList<Tree>().map(
        (value) => ProgramNode(
          children: value,
        ),
      );

  Parser compilationUnit() =>
      (ref0(expression) | ref0(parentheses) | ref0(numberPrimitive))
          .map((value) => value);

  // Top-level expression parser considering precedence
  Parser expression() => ref0(additiveExpression);

  // Addition and subtraction (lower precedence)
  Parser additiveExpression() => ref0(multiplicativeExpression)
      .plusSeparated(ref0(additiveOperator))
      .map((value) => _buildExpressionTree(value.sequential.toList()));

  // Multiplication and division (higher precedence)
  Parser multiplicativeExpression() => ref0(atomicExpression)
      .plusSeparated(ref0(multiplicativeOperator))
      .map((value) => _buildExpressionTree(value.sequential.toList()));

  // Atomic expressions (numbers or expressions within parentheses)
  Parser atomicExpression() => ref0(numberPrimitive) | ref0(parentheses);

  // Parentheses to handle grouped expressions
  Parser parentheses() => (char('(') & ref0(expression) & char(')'))
      .pick(1)
      .map((value) => ParenthesesNode(child: value));

  // Operator parsers with different precedence
  Parser additiveOperator() => anyOf('+-').trim().map((value) {
        return OperatorNode(switch (value) {
          "+" => Operator.plus,
          "-" => Operator.minus,
          _ => throw Exception('Unknown operator: $value'),
        });
      });

  Parser multiplicativeOperator() => anyOf('*/').trim().map((value) {
        return OperatorNode(switch (value) {
          "*" => Operator.multiply,
          "/" => Operator.divide,
          _ => throw Exception('Unknown operator: $value'),
        });
      });

  // Number primitive (e.g., 42, -3.14, etc.)
  Parser numberPrimitive() => <Parser>[
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

  // Helper function to build the expression tree
  Tree _buildExpressionTree(List<dynamic> elements) {
    Tree left = elements.first as Tree;

    for (int i = 1; i < elements.length; i += 2) {
      var operatorNode = elements[i] as OperatorNode;
      var right = elements[i + 1] as Tree;
      left = ExpressionNode([left, operatorNode, right]);
    }

    return left;
  }

  // Whitespace and comments

  Parser<void> hiddenWhitespace() => ref0(hiddenStuffWhitespace).plus();
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

  // Newline
  Parser newlineLexicalToken() => pattern('\n\r');
}

class JavascriptParser {
  Tree parse(String code) {
    final a = JavascriptGrammar();
    final parser = a.build();

    return parser.parse(code).value;
  }
}
