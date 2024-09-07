// Base class for all nodes in the AST
abstract class Tree {
  dynamic evaluate();
}

// Enum for the operators
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
  evaluate() {
    final result = [];

    for (var child in children) {
      result.add(child.evaluate());
    }

    return result[0];
  }
}

class NumberNode extends Tree {
  final num value;

  NumberNode(this.value);

  @override
  dynamic evaluate() {
    return value;
  }
}

class UnaryExpressionNode extends Tree {
  final String operator;
  final Tree child;

  UnaryExpressionNode(this.operator, this.child);

  @override
  dynamic evaluate() {
    if (operator == "-") {
      return -child.evaluate();
    } else if (operator == "+") {
      return child.evaluate();
    }

    throw Exception(
        'Wrong operator for the unary expression. Received "$operator" (only "+" and "-" are allowed)');
  }
}

class OperationNode extends Tree {
  final Operator operator;
  final Tree left;
  final Tree right;

  OperationNode({
    required this.operator,
    required this.left,
    required this.right,
  });

  @override
  num evaluate() {
    switch (operator) {
      case Operator.plus:
        return left.evaluate() + right.evaluate();
      case Operator.minus:
        return left.evaluate() - right.evaluate();
      case Operator.multiply:
        return left.evaluate() * right.evaluate();
      case Operator.divide:
        if (right.evaluate() == 0) {
          throw Exception('Division by zero');
        }
        return left.evaluate() / right.evaluate();
      default:
        throw Exception('Unknown operator');
    }
  }
}
