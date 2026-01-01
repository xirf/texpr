import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin ExpressionParserMixin on BaseParser {
  @override
  Expression parseExpression() {
    enterRecursion();
    try {
      return parseComparison();
    } finally {
      exitRecursion();
    }
  }

  Expression parseComparison() {
    var left = parsePlusMinus();

    final expressions = <Expression>[left];
    final operators = <ComparisonOperator>[];

    Token? mt;
    while ((mt = matchToken(TokenType.less)) != null ||
        (mt = matchToken(TokenType.greater)) != null ||
        (mt = matchToken(TokenType.lessEqual)) != null ||
        (mt = matchToken(TokenType.greaterEqual)) != null ||
        (mt = matchToken(TokenType.equals)) != null ||
        (mt = matchToken(TokenType.member)) != null) {
      final operator = mt!;
      final right = parsePlusMinus();

      ComparisonOperator op;
      switch (operator.type) {
        case TokenType.less:
          op = ComparisonOperator.less;
          break;
        case TokenType.greater:
          op = ComparisonOperator.greater;
          break;
        case TokenType.lessEqual:
          op = ComparisonOperator.lessEqual;
          break;
        case TokenType.greaterEqual:
          op = ComparisonOperator.greaterEqual;
          break;
        case TokenType.equals:
          op = ComparisonOperator.equal;
          break;
        case TokenType.member:
          op = ComparisonOperator.member;
          break;
        default:
          throw ParserException(
            'Unknown comparison operator',
            position: operator.position,
            expression: sourceExpression,
            suggestion: 'Use valid comparison operators: <, >, <=, >=, =',
          );
      }

      expressions.add(right);
      operators.add(op);
    }

    if (operators.length > 1) {
      registerNode();
      return ChainedComparison(expressions, operators);
    } else if (operators.length == 1) {
      registerNode();
      return Comparison(expressions[0], operators[0], expressions[1]);
    }

    return left;
  }

  @override
  Expression parsePlusMinus() {
    var left = parseTerm();

    Token? mt;
    while ((mt = matchToken(TokenType.plus)) != null ||
        (mt = matchToken(TokenType.minus)) != null) {
      final operator = mt!;
      final right = parseTerm();

      registerNode();
      left = BinaryOp(
        left,
        operator.type == TokenType.plus
            ? BinaryOperator.add
            : BinaryOperator.subtract,
        right,
      );
    }

    return left;
  }

  @override
  Expression parseTerm() {
    var left = parseUnary();

    Token? mt;
    while (true) {
      if ((mt = matchToken(TokenType.multiply)) != null ||
          (mt = matchToken(TokenType.divide)) != null) {
        final operator = mt!;
        final right = parseUnary();

        registerNode();
        left = BinaryOp(
          left,
          operator.type == TokenType.multiply
              ? BinaryOperator.multiply
              : BinaryOperator.divide,
          right,
          sourceToken: operator.value,
        );
      } else if (checkImplicitMultiplication()) {
        final right = parseUnary();
        registerNode();
        left = BinaryOp(left, BinaryOperator.multiply, right);
      } else {
        break;
      }
    }

    return left;
  }

  bool checkImplicitMultiplication() {
    if (isAtEnd) return false;

    // Don't treat expected closing delimiter as start of new operand
    if (delimiterStack.isNotEmpty && current.value == delimiterStack.last) {
      return false;
    }

    return check(TokenType.number) ||
        check(TokenType.variable) ||
        check(TokenType.constant) ||
        check(TokenType.lparen) ||
        check(TokenType.function) ||
        check(TokenType.lim) ||
        check(TokenType.sum) ||
        check(TokenType.prod) ||
        check(TokenType.frac) ||
        check(TokenType.text) ||
        check(TokenType.infty) ||
        check(TokenType.int) ||
        check(TokenType.iint) ||
        check(TokenType.iiint) ||
        check(TokenType.binom) ||
        check(TokenType.begin) ||
        check(TokenType.pipe) ||
        check(TokenType.nabla) ||
        check(TokenType.partial) ||
        check(TokenType.fontCommand);
  }

  @override
  Expression parsePower() {
    enterRecursion();
    try {
      var left = parsePrimary();

      if (match1(TokenType.power)) {
        if (check(TokenType.lparen) && current.value == '{') {
          advance();
          final right = parseExpression();
          consume(TokenType.rparen, "Expected '}' after exponent");
          registerNode();
          return BinaryOp(left, BinaryOperator.power, right);
        } else {
          final right = parsePower();
          registerNode();
          return BinaryOp(left, BinaryOperator.power, right);
        }
      }

      return left;
    } finally {
      exitRecursion();
    }
  }

  @override
  Expression parseUnary() {
    enterRecursion();
    try {
      if (match1(TokenType.minus)) {
        final operand = parseUnary();
        registerNode();
        return UnaryOp(UnaryOperator.negate, operand);
      }

      return parsePower();
    } finally {
      exitRecursion();
    }
  }
}
