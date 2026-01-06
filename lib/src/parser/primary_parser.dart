import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

const _partial = 'partial';
const _d = 'd';

mixin PrimaryParserMixin on BaseParser {
  @override
  Expression parsePrimary() {
    final t = matchToken(TokenType.number);
    if (t != null) {
      registerNode();
      return NumberLiteral(t.numberValue!);
    }

    if (match1(TokenType.lbracket)) {
      final expr = parseExpression();
      consume(TokenType.rbracket, "Expected ']'");
      registerNode();
      return expr;
    }

    if (match1(TokenType.langle)) {
      final args = <Expression>[];
      args.add(parseExpression());
      while (match1(TokenType.comma)) {
        args.add(parseExpression());
      }
      consume(TokenType.rangle, "Expected '\\rangle'");
      registerNode();
      if (args.length == 1) return args[0]; // just grouping
      // For now, return a function call to 'inner_product' or 'vector'
      // Given the context of <u,v>, inner_product is likely intended.
      // But \langle x \rangle is expectation value.
      return FunctionCall.multivar('inner_product', args);
    }

    final vt = matchToken(TokenType.variable);
    if (vt != null) {
      String varName = vt.value;

      // Check for subscript to create composite variable name (e.g., H_0, R_{crit})
      if (match1(TokenType.underscore)) {
        if (check(TokenType.lparen) && current.value == '{') {
          // Handle _{...} - extract content as part of name
          final sub = parseLatexArgument();
          varName += '_$sub';
        } else if (check(TokenType.number)) {
          // Handle _0
          varName += '_${current.value}';
          advance();
        } else if (check(TokenType.variable)) {
          // Handle _x
          varName += '_${current.value}';
          advance();
        } else {
          // Fallback or error - simplistic handling for now
          // We could throw, but let's see if we can perform a simple consume
          // If it's a Greek letter or command, it might be tricky.
          // For now, assume simple tokens.
          throw ParserException(
            'Expected number, variable, or {expression} after underscore',
            position: current.position,
            expression: sourceExpression,
          );
        }
      }

      // Check for function call notation: f(x,y) where f is a variable name
      // followed by parenthesized arguments with COMMAS (textbook notation)
      // Only parse as function call if there are multiple arguments (commas),
      // otherwise it's implicit multiplication like x(x+1) = x * (x+1)
      if (check(TokenType.lparen) && current.value == '(') {
        // Look ahead to check for comma - if found, parse as function call
        int parenDepth = 1;
        bool hasComma = false;
        int scanPos = position + 1; // position is at '(', so start after

        // Scan ahead to check if there's a comma at this paren level
        while (scanPos < tokens.length && parenDepth > 0) {
          final tok = tokens[scanPos];
          if (tok.type == TokenType.lparen) {
            parenDepth++;
          } else if (tok.type == TokenType.rparen) {
            parenDepth--;
          } else if (tok.type == TokenType.comma && parenDepth == 1) {
            hasComma = true;
            break;
          }
          scanPos++;
        }

        if (hasComma) {
          // Parse as function call with multiple arguments
          advance(); // consume '('
          final args = <Expression>[];
          if (!check(TokenType.rparen)) {
            args.add(parseExpression());
            while (match1(TokenType.comma)) {
              args.add(parseExpression());
            }
          }
          consume(TokenType.rparen, "Expected ')' after function arguments");
          registerNode();
          return FunctionCall.multivar(varName, args);
        }
        // No comma - let implicit multiplication handle x(expr)
      }
      registerNode();
      return Variable(varName);
    }

    final ct = matchToken(TokenType.constant);
    if (ct != null) {
      registerNode();
      return Variable(ct.value);
    }

    if (match1(TokenType.infty)) {
      registerNode();
      return Variable('infty');
    }

    if (match1(TokenType.function)) {
      return parseFunctionCall();
    }

    if (match1(TokenType.lim)) {
      return parseLimitExpr();
    }

    if (match1(TokenType.sum)) {
      return parseSumExpr();
    }

    if (match1(TokenType.prod)) {
      return parseProductExpr();
    }

    if (match1(TokenType.int) || match1(TokenType.oint)) {
      return parseIntegralExpr();
    }

    final mt = matchToken(TokenType.iint) ?? matchToken(TokenType.iiint);
    if (mt != null) {
      final order = mt.type == TokenType.iint ? 2 : 3;
      return parseMultiIntegralExpr(order);
    }

    if (match1(TokenType.frac)) {
      return parseFraction();
    }

    if (match1(TokenType.binom)) {
      return parseBinom();
    }

    if (match1(TokenType.partial)) {
      registerNode();
      return Variable(_partial);
    }

    if (match1(TokenType.nabla)) {
      registerNode();

      // Check for nabla^2 (Laplacian operator) - treat as special symbol for now
      // since Laplacian is not the same as gradient squared
      if (check(TokenType.power)) {
        advance(); // consume ^
        // Parse the exponent - handle both braced {2} and bare 2
        if (check(TokenType.lparen) && current.value == '{') {
          parseLatexArgumentExpr(); // consume braced exponent
        } else {
          parsePrimary(); // consume bare exponent like 2
        }
        // Laplacian: nabla^2 - for now treat as variable for backwards compatibility
        // When followed by an expression, it becomes nabla^2 f
        // Return as Variable so implicit multiplication handles the rest
        return Variable('laplacian');
      }

      // Parse the following expression as the body of the gradient
      // Handle braced arguments: \nabla{f} or \nabla(f)
      Expression body;
      if (check(TokenType.lparen) && current.value == '{') {
        body = parseLatexArgumentExpr();
      } else {
        // Parse a primary expression (handles \nabla f, \nabla x^2, etc.)
        body = parsePrimary();
        // Handle powers: \nabla f^2 means \nabla(f^2), not (\nabla f)^2
        if (match1(TokenType.power)) {
          final exponent = parseLatexArgumentExpr();
          body = BinaryOp(body, BinaryOperator.power, exponent);
        }
      }
      return GradientExpr(body);
    }

    if (match1(TokenType.text)) {
      final text = parseLatexArgument();
      registerNode();
      return Variable(text);
    }

    // Handle font commands like \mathbf{E}, \mathcal{F}
    final fontToken = matchToken(TokenType.fontCommand);
    if (fontToken != null) {
      final content = parseLatexArgument();
      registerNode();
      // Store font style as prefix for LaTeX round-trip
      return Variable('${fontToken.value}:$content');
    }

    if (match1(TokenType.begin)) {
      return parseMatrix();
    }

    if (match1(TokenType.pipe)) {
      delimiterStack.add('|');
      final expr = parseExpression();
      delimiterStack.removeLast();
      consume(TokenType.pipe, "Expected closing |");
      registerNode();
      return AbsoluteValue(expr);
    }

    final pt = matchToken(TokenType.lparen);
    if (pt != null) {
      final char = pt.value;
      final expr = parseExpression();

      if (!check(TokenType.rparen) && !check(TokenType.rbracket)) {
        throw ParserException(
          "Expected '${char == '(' ? ')' : '}'}'",
          position: current.position,
          expression: sourceExpression,
          suggestion: char == '('
              ? 'Add a closing parenthesis ) to match the opening'
              : char == '{'
                  ? 'Add a closing brace } to match the opening'
                  : 'Add a closing bracket ] to match the opening',
        );
      }
      advance();

      if (char == '{' && check(TokenType.lparen) && current.value == '{') {
        advance();
        final condition = parseExpression();
        consume(TokenType.rparen, "Expected '}' after condition");
        registerNode();
        return ConditionalExpr(expr, condition);
      }

      return expr;
    }

    if (match1(TokenType.sqrt)) {
      registerNode();
      // Check for [n]
      if (match1(TokenType.lbracket)) {
        final n = parseExpression();
        consume(TokenType.rbracket, "Expected ']' after root order");
        final argument = parseLatexArgumentExpr();
        return FunctionCall.multivar('sqrt', [argument, n]);
      }
      final argument = parseLatexArgumentExpr();
      return FunctionCall.multivar('sqrt', [argument]);
    }

    final exception = ParserException(
      'Expected expression, got: ${isAtEnd ? "EOF" : current.type.readableName}',
      position: isAtEnd ? null : current.position,
      expression: sourceExpression,
      suggestion: 'Check for missing operands or invalid syntax',
    );

    if (recoverOnError) {
      errors.add(exception);
      // Synchronize: consume the bad token if not EOF
      if (!isAtEnd) advance();
      return Variable('__ERROR__');
    }

    throw exception;
  }

  /// Parses a fraction \frac{numerator}{denominator}.
  ///
  /// Also supports braceless fractions like `\frac12` (exactly 2 single-char tokens).
  /// Throws an error for ambiguous cases like `\frac123`.
  Expression parseFraction() {
    // Check if this looks like derivative notation: \frac{d}{dx} or \frac{d^n}{dx^n}
    // We need to check the raw tokens before parsing
    if (_isDerivativeNotation()) {
      return _parseDerivative();
    }

    // Detect ambiguous braceless fractions: \frac123 is ambiguous
    if (_hasAmbiguousBracelessFraction()) {
      throw ParserException(
        'Ambiguous braceless fraction: unable to determine numerator/denominator split',
        position: current.position,
        expression: sourceExpression,
        suggestion: r'Use braces to clarify: \frac{1}{23} or \frac{12}{3}',
      );
    }

    // Support braceless fractions: \frac12 to \frac{1}{2} (exactly 2 single-char tokens)
    final numerator = _parseFracArgument();
    final denominator = _parseFracArgument();
    registerNode();
    return BinaryOp(numerator, BinaryOperator.divide, denominator);
  }

  /// Checks if we have 3+ consecutive single-digit/variable chars after \frac (ambiguous case).
  ///
  /// Handles multi-digit number tokens by counting their digit count.
  bool _hasAmbiguousBracelessFraction() {
    if (check(TokenType.lparen)) return false; // Braced, not ambiguous

    // Count total digits/variables in consecutive tokens
    int count = 0;
    int scanPos = position;
    while (scanPos < tokens.length) {
      final tok = tokens[scanPos];
      if (tok.type == TokenType.number) {
        // Count each digit in the number
        count += tok.value.length;
      } else if (tok.type == TokenType.variable && tok.value.length == 1) {
        count++;
      } else {
        break;
      }
      scanPos++;
    }
    return count > 2; // 3+ is ambiguous
  }

  /// Parses a single fraction argument (braced or braceless single-char).
  ///
  /// For braceless: takes exactly one digit or one variable.
  /// Multi-digit numbers like "12" are split: first call takes "1", second takes "2".
  Expression _parseFracArgument() {
    // Standard braced argument
    if (check(TokenType.lparen) && current.value == '{') {
      return parseLatexArgumentExpr();
    }
    // Braceless: number token (may be multi-digit, take first digit only)
    if (check(TokenType.number)) {
      final token = current;
      if (token.value.length == 1) {
        // Single digit, consume entire token
        advance();
        registerNode();
        return NumberLiteral(token.numberValue!);
      } else {
        // Multi-digit: take first digit, modify token in-place for rest
        final firstDigit = double.parse(token.value[0]);
        final remaining = token.value.substring(1);
        // Update the token to contain only the remaining digits
        tokens[position] = Token(
          type: TokenType.number,
          value: remaining,
          position: token.position + 1,
          numberValue: double.parse(remaining),
        );
        registerNode();
        return NumberLiteral(firstDigit);
      }
    }
    // Braceless: single variable (exactly 1 char)
    if (check(TokenType.variable) && current.value.length == 1) {
      final token = advance();
      registerNode();
      return Variable(token.value);
    }
    // Fallback to regular parsing (will error with helpful message)
    return parseLatexArgumentExpr();
  }

  /// Checks if the current fraction represents derivative notation by examining tokens.
  bool _isDerivativeNotation() {
    int i = position;
    if (i >= tokens.length) return false;

    // Consume '{'
    if (tokens[i].type != TokenType.lparen) return false;
    i++;
    if (i >= tokens.length) return false;

    bool isPartial = tokens[i].type == TokenType.partial;
    bool isD = tokens[i].type == TokenType.variable && tokens[i].value == _d;
    if (!isPartial && !isD) return false;
    i++;

    if (i < tokens.length && tokens[i].type == TokenType.power) {
      i++;
      if (i < tokens.length && tokens[i].type == TokenType.lparen) {
        i++;
        if (i < tokens.length && tokens[i].type != TokenType.number) {
          return false;
        }
        i++;
        if (i < tokens.length && tokens[i].type != TokenType.rparen) {
          return false;
        }
        i++;
      } else {
        if (i < tokens.length && tokens[i].type != TokenType.number) {
          return false;
        }
        i++;
      }
    }

    if (i >= tokens.length || tokens[i].type != TokenType.rparen) return false;
    i++;
    if (i >= tokens.length || tokens[i].type != TokenType.lparen) return false;
    i++;

    final dType = isPartial ? TokenType.partial : TokenType.variable;
    if (i >= tokens.length || tokens[i].type != dType) return false;
    if (!isPartial && tokens[i].value != _d) {
      return false; // Ensure it's 'd' if not partial
    }
    i++;

    if (i >= tokens.length || tokens[i].type != TokenType.variable) {
      return false;
    }

    return true;
  }

  /// Parses a derivative from \frac{d}{dx} or \frac{d^n}{dx^n} notation.
  Expression _parseDerivative() {
    // Consume the initial '{' for the fraction
    consume(TokenType.lparen, "Expected '{' after \\frac");

    // Parse numerator to get order
    int order = 1;

    // Should be 'd' or '\partial'
    final isPartial = match1(TokenType.partial);
    if (!isPartial) {
      consume(TokenType.variable,
          "Expected 'd' or '\\partial' in derivative numerator");
    }

    // Check for ^n
    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
        if (check(TokenType.number)) {
          order = int.parse(current.value);
          advance();
        }
        consume(TokenType.rparen, "Expected '}' after exponent");
      } else if (check(TokenType.number)) {
        order = int.parse(current.value);
        advance();
      }
    }

    consume(TokenType.rparen, "Expected '}' after derivative numerator");
    consume(TokenType.lparen, "Expected '{' for denominator");

    // Parse denominator to get variable
    if (isPartial) {
      consume(
          TokenType.partial, "Expected '\\partial' in derivative denominator");
    } else {
      consume(TokenType.variable, "Expected 'd' in derivative denominator");
    }

    if (!check(TokenType.variable)) {
      throw ParserException(
        'Expected variable after d in derivative notation',
        position: current.position,
        expression: sourceExpression,
        suggestion: 'Use \\frac{d}{dx} where x is the variable',
      );
    }

    final variable = current.value;
    advance();

    // Check for optional ^n in denominator (should match numerator order)
    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
        if (check(TokenType.number)) {
          // We could validate this matches the numerator order, but we'll ignore for now
          advance();
        }
        consume(TokenType.rparen, "Expected '}' after exponent");
      } else if (check(TokenType.number)) {
        advance();
      }
    }

    consume(TokenType.rparen, "Expected '}' after derivative denominator");

    // Parse body: \frac{d}{dx}(x^2) or \frac{d}{dx} x^2
    Expression body;
    if (match1(TokenType.lparen)) {
      body = parseExpression();
      consume(TokenType.rparen, "Expected ')' after derivative body");
    } else {
      // Allow implicit application to next term: \frac{d}{dx} x^2
      // Using parseTerm() to capture multiplication (e.g. d/dx x * y)
      // but stop at +/=.
      body = parseTerm();
    }

    registerNode();
    if (isPartial) {
      return PartialDerivativeExpr(body, variable, order: order);
    }
    return DerivativeExpr(body, variable, order: order);
  }

  Expression parseBinom() {
    final n = parseLatexArgumentExpr();
    final k = parseLatexArgumentExpr();

    registerNode();
    return BinomExpr(n, k);
  }

  /// Parses an integral with optional bounds \int_{lower}^{upper} body dx.
  @override
  Expression parseIntegralExpr() {
    // Check if the PREVIOUS token was \oint (since it was consumed by caller)
    // tokens[position-1]
    bool isClosed = false;
    if (position > 0 && tokens[position - 1].type == TokenType.oint) {
      isClosed = true;
    }

    Expression? lower;
    Expression? upper;

    // Parse optional bounds
    if (match1(TokenType.underscore)) {
      if (match1(TokenType.lparen)) {
        lower = parseExpression();
        consume(TokenType.rparen, "Expected '}' after lower bound");
      } else {
        lower = parsePrimary();
      }
    }

    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
        upper = parseExpression();
        consume(TokenType.rparen, "Expected '}' after upper bound");
      } else {
        upper = parsePrimary();
      }
    }

    // Parse expression body
    final body = parseExpression();

    // Parse variable (e.g., dx)
    String variable = 'x';
    final dt = matchToken(TokenType.variable);
    if (dt != null && dt.value == _d) {
      final vt = matchToken(TokenType.variable);
      if (vt != null) {
        variable = vt.value;
      }
    }

    registerNode();
    registerNode();
    return IntegralExpr(lower, upper, body, variable, isClosed: isClosed);
  }

  Expression parseMultiIntegralExpr(int order) {
    Expression? lower;
    Expression? upper;

    // Parse optional bounds: \iint_{a}^{b}
    if (match1(TokenType.underscore)) {
      if (match1(TokenType.lparen)) {
        lower = parseExpression();
        consume(TokenType.rparen, "Expected '}' after lower bound");
      } else {
        lower = parsePrimary();
      }
    }

    if (match1(TokenType.power)) {
      if (match1(TokenType.lparen)) {
        upper = parseExpression();
        consume(TokenType.rparen, "Expected '}' after upper bound");
      } else {
        upper = parsePrimary();
      }
    }

    // Parse body
    final body = parseExpression();

    // Pre-size with defaults: 'x', 'y' for iint and 'x', 'y', 'z' for iiint
    final variables = order == 2 ? <String>['x', 'y'] : <String>['x', 'y', 'z'];

    // Try to parse explicit variables: dx dy ...
    int varIndex = 0;
    while (
        check(TokenType.variable) && current.value == _d && varIndex < order) {
      advance(); // consume 'd'
      if (check(TokenType.variable)) {
        variables[varIndex] = current.value;
        advance();
        varIndex++;
      }
    }

    registerNode();
    return MultiIntegralExpr(order, lower, upper, body, variables);
  }
}
