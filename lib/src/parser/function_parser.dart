import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin FunctionParserMixin on BaseParser {
  @override
  Expression parseFunctionCall() {
    enterRecursion();
    try {
      // Note: function token was already consumed by match1(TokenType.function) in parsePrimary
      final name = tokens[position - 1].value;
      Expression? base;
      Expression? optionalParam;
      Expression? functionPower;

      // Check for optional parameter in square brackets (e.g., \sqrt[3]{x})
      if (match1(TokenType.lbracket)) {
        optionalParam = parseExpression();
        consume(TokenType.rbracket, "Expected ']' after optional parameter");
      }

      // Check for power notation on function itself: \sin^2{x} -> (\sin{x})^2
      // This is common textbook notation
      if (match1(TokenType.power)) {
        if (match1(TokenType.lparen)) {
          functionPower = parseExpression();
          consume(TokenType.rparen, "Expected '}' after power");
        } else {
          functionPower = parsePrimary();
        }
      }

      // Special handling for \vec{} and \hat{}
      if (name == 'vec' || name == 'hat') {
        consume(TokenType.lparen, "Expected '{' after \\$name");
        final components = <Expression>[];
        components.add(parseExpression());
        while (match1(TokenType.comma)) {
          components.add(parseExpression());
        }
        consume(TokenType.rparen, "Expected '}' after vector components");
        registerNode();
        Expression result = VectorExpr(components, isUnitVector: name == 'hat');
        if (functionPower != null) {
          result = BinaryOp(result, BinaryOperator.power, functionPower);
        }
        return result;
      }

      // Special handling for decoration functions \dot{}, \ddot{}, \bar{}
      // These are display-only decorations; evaluate to just the inner expression
      if (name == 'dot' || name == 'ddot' || name == 'bar') {
        consume(TokenType.lparen, "Expected '{' after \\$name");
        final arg = parseExpression();
        consume(TokenType.rparen, "Expected '}' after $name argument");
        registerNode();
        // Return as a function call that will evaluate to the argument value
        Expression result = FunctionCall(name, arg);
        if (functionPower != null) {
          result = BinaryOp(result, BinaryOperator.power, functionPower);
        }
        return result;
      }

      if (match1(TokenType.underscore)) {
        consume(TokenType.lparen, "Expected '{' after '_'");
        base = parseExpression();
        consume(TokenType.rparen, "Expected '}' after base");
      }

      List<Expression> args = [];
      if (check(TokenType.lparen)) {
        advance();
        args.add(parseExpression());
        while (match1(TokenType.comma)) {
          args.add(parseExpression());
        }
        consume(TokenType.rparen,
            "Expected closing brace/paren after function argument");
      } else {
        args.add(parseUnary());
      }

      Expression result;
      if (args.length == 1) {
        result = FunctionCall(name, args[0],
            base: base, optionalParam: optionalParam);
      } else {
        result = FunctionCall.multivar(name, args,
            base: base, optionalParam: optionalParam);
      }

      // Apply power if present: \sin^2{x} -> (\sin{x})^2
      if (functionPower != null) {
        result = BinaryOp(result, BinaryOperator.power, functionPower);
      }

      registerNode();
      return result;
    } finally {
      exitRecursion();
    }
  }

  @override
  Expression parseLimitExpr() {
    consume(TokenType.underscore, "Expected '_' after \\lim");
    consume(TokenType.lparen, "Expected '{' after '_'");

    final varToken = consume(TokenType.variable, "Expected variable in limit");
    final variable = varToken.value;

    consume(TokenType.to, "Expected '\\to' in limit");

    final target = parseWithDelimiter('}', parseExpression);

    consume(TokenType.rparen, "Expected '}' after limit subscript");

    final body = parseExpression();
    registerNode();
    return LimitExpr(variable, target, body);
  }

  @override
  Expression parseSumExpr() {
    enterRecursion();
    try {
      consume(TokenType.underscore, "Expected '_' after \\sum");
      consume(TokenType.lparen, "Expected '{' after '_'");

      final varToken = consume(TokenType.variable, "Expected variable in sum");
      final variable = varToken.value;

      consume(TokenType.equals, "Expected '=' after variable");

      final start = parseExpression();

      consume(TokenType.rparen, "Expected '}' after start value");

      consume(TokenType.power, "Expected '^' after sum subscript");
      consume(TokenType.lparen, "Expected '{' after '^'");

      final end = parseExpression();

      consume(TokenType.rparen, "Expected '}' after end value");

      final body = parseExpression();
      registerNode();
      return SumExpr(variable, start, end, body);
    } finally {
      exitRecursion();
    }
  }

  @override
  Expression parseProductExpr() {
    enterRecursion();
    try {
      consume(TokenType.underscore, "Expected '_' after \\prod");
      consume(TokenType.lparen, "Expected '{' after '_'");

      final varToken =
          consume(TokenType.variable, "Expected variable in product");
      final variable = varToken.value;

      consume(TokenType.equals, "Expected '=' after variable");

      final start = parseExpression();

      consume(TokenType.rparen, "Expected '}' after start value");

      consume(TokenType.power, "Expected '^' after product subscript");
      consume(TokenType.lparen, "Expected '{' after '^'");

      final end = parseExpression();

      consume(TokenType.rparen, "Expected '}' after end value");

      final body = parseExpression();
      registerNode();
      return ProductExpr(variable, start, end, body);
    } finally {
      exitRecursion();
    }
  }

  @override
  Expression parseIntegralExpr() {
    // Check if the PREVIOUS token was \oint
    bool isClosed = false;
    if (position > 0 && tokens[position - 1].type == TokenType.oint) {
      isClosed = true;
    }

    Expression? lower;
    Expression? upper;

    // Handle bounds (optional, loop to allow _ then ^ or ^ then _)
    while (check(TokenType.underscore) || check(TokenType.power)) {
      if (match1(TokenType.underscore)) {
        if (check(TokenType.lparen) && current.value == '{') {
          advance();
          lower = parseExpression();
          consume(TokenType.rparen, "Expected '}' after lower bound");
        } else {
          lower = parsePrimary();
        }
      } else if (match1(TokenType.power)) {
        if (check(TokenType.lparen) && current.value == '{') {
          advance();
          upper = parseExpression();
          consume(TokenType.rparen, "Expected '}' after upper bound");
        } else {
          upper = parsePrimary();
        }
      }
    }

    final fullBody = parsePlusMinus();

    // Attempt to extract body and variable from "body * d * variable" structure
    Expression? body;
    String? variable;

    if (fullBody is BinaryOp && fullBody.operator == BinaryOperator.multiply) {
      final right = fullBody.right;
      final left = fullBody.left;

      // Handle simple case: \int d \mathbf{A} -> d * A
      // structure: left=d, right=A
      if (left is Variable && left.name == 'd' && right is Variable) {
        body = NumberLiteral(1.0);
        variable = right.name;
      }
      // Handle standard case: \int ... * d * x
      // structure: (left * d) * x
      else if (right is Variable) {
        final potentialVar = right.name;

        if (left is Variable && left.name == 'd') {
          // Case: \int dx -> d * x
          // What about \int A dx -> A * d * x -> (A*d)*x
          // Here left is (A*d)
          body = NumberLiteral(1.0);
        } else if (left is BinaryOp &&
            left.operator == BinaryOperator.multiply) {
          // Case: \int f(x) dx -> f(x) * d * x
          // left is (f(x) * d)
          if (left.right is Variable && (left.right as Variable).name == 'd') {
            body = left.left;
            variable = potentialVar;
          }
        }
      }
    }

    if (body == null || variable == null) {
      // Fallback: If heuristic fails, treat strict \int f(x) dx
      // If the last term is ANY valid variable and second last is 'd'
      // But we only have the expression tree.
      // Let's implement a 'trailing differential' extractor?
      // Too complex for now.
      // Reuse the exception logic but maybe hint about multiplication.

      throw ParserException(
        "Expected differential (e.g., 'dx') at the end of integral",
        position: tokens[position - 1].position,
        expression: sourceExpression,
        suggestion:
            'Add dx, dy, or another differential at the end of the integral',
      );
    }

    registerNode();
    return IntegralExpr(lower, upper, body, variable, isClosed: isClosed);
  }
}
