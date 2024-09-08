abstract class Tree {
  dynamic evaluate();
}

enum Operator {
  plus,
  minus,
  multiply,
  divide,
}

class ProgramNode extends Tree {
  final List<Tree> children;

  ProgramNode({required this.children});

  @override
  dynamic evaluate() {
    return children.map((child) => child.evaluate()).last;
  }
}

// Node representing a number
class NumberNode extends Tree {
  final num value;

  NumberNode(this.value);

  @override
  dynamic evaluate() {
    return value;
  }
}

// Node representing an expression, which can be a combination of operators and numbers
class ExpressionNode extends Tree {
  final List<dynamic>
      elements; // Mix of numbers, operators, and sub-expressions

  ExpressionNode(this.elements);

  @override
  dynamic evaluate() {
    // Evaluate all elements, handle nested operations
    final values = [];
    var currentOperator;

    for (var element in elements) {
      if (element is OperatorNode) {
        currentOperator = element.operator;
      } else {
        // It's a number or sub-expression
        final value = (element is Tree) ? element.evaluate() : element;
        if (currentOperator != null && values.isNotEmpty) {
          final left = values.removeLast();
          final result = _applyOperator(currentOperator, left, value);
          values.add(result);
          currentOperator = null;
        } else {
          values.add(value);
        }
      }
    }

    if (values.length != 1) {
      throw Exception('Expression evaluation resulted in an unexpected state.');
    }

    return values.first;
  }

  dynamic _applyOperator(Operator operator, num left, num right) {
    switch (operator) {
      case Operator.plus:
        return left + right;
      case Operator.minus:
        return left - right;
      case Operator.multiply:
        return left * right;
      case Operator.divide:
        if (right == 0) throw Exception('Division by zero');
        return left / right;
      default:
        throw Exception('Unknown operator');
    }
  }
}

class OperatorNode extends Tree {
  final Operator operator;

  OperatorNode(this.operator);

  @override
  dynamic evaluate() {
    throw Exception('OperatorNode cannot be evaluated independently.');
  }
}

class ParenthesesNode extends Tree {
  final Tree child;

  ParenthesesNode({required this.child});

  @override
  dynamic evaluate() {
    return child.evaluate();
  }
}
