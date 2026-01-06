import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';
import 'expression_parser.dart';
import 'primary_parser.dart';
import 'function_parser.dart';
import 'matrix_parser.dart';

/// Recursive descent parser for LaTeX math expressions.
class Parser extends BaseParser
    with
        ExpressionParserMixin,
        PrimaryParserMixin,
        FunctionParserMixin,
        MatrixParserMixin {
  Parser(super.tokens,
      [super.sourceExpression,
      super.recoverOnError,
      super.maxRecursionDepth = 500]);

  /// Parses the token stream and returns the root expression.
  Expression parse() {
    // 1. Check for 'let' assignment: let x = ...
    if (match1(TokenType.letKeyword)) {
      final variable =
          consume(TokenType.variable, 'Expected variable name after let').value;
      consume(TokenType.equals, 'Expected = after variable name');
      final value = parseExpression();
      return AssignmentExpr(variable, value);
    }

    // 2. Check for function definition: f(x, y) = ...
    // Lookahead: variable + lparen
    if (tokens.length > 2 &&
        tokens[position].type == TokenType.variable &&
        tokens[position + 1].type == TokenType.lparen) {
      // We need deeper lookahead or speculative parsing to distinguish 'f(x) = ...' from 'f(x) + 1'
      // Simple heuristic: Scan ahead for '=' at the top level (not nested in parens)

      int scanPos = position + 2; // after var + (
      int parenBalance = 1;
      bool validParams = true;

      while (scanPos < tokens.length && parenBalance > 0) {
        final t = tokens[scanPos];
        if (t.type == TokenType.lparen) {
          parenBalance++;
          validParams =
              false; // Nested parens not allowed in implicit definition
        } else if (t.type == TokenType.rparen) {
          parenBalance--;
        } else if (t.type != TokenType.variable && t.type != TokenType.comma) {
          validParams = false; // Only variables and commas allowed
        }
        scanPos++;
      }

      // If we closed parens and the next token is '=', it's a function definition
      if (parenBalance == 0 &&
          validParams &&
          scanPos < tokens.length &&
          tokens[scanPos].type == TokenType.equals) {
        final name =
            consume(TokenType.variable, 'Expected function name').value;
        consume(TokenType.lparen, 'Expected (');

        final params = <String>[];
        if (current.type != TokenType.rparen) {
          do {
            params.add(
                consume(TokenType.variable, 'Expected parameter name').value);
          } while (match1(TokenType.comma));
        }

        consume(TokenType.rparen, 'Expected )');
        consume(TokenType.equals, 'Expected =');

        final body = parseExpression();
        return FunctionDefinitionExpr(name, params, body);
      }
    }

    var expr = parseExpression();

    // Support "expr, condition" syntax (e.g. for piecewise ranges)
    if (match1(TokenType.comma)) {
      final condition = parseExpression();
      expr = ConditionalExpr(expr, condition);
    }

    if (!isAtEnd && current.type != TokenType.eof) {
      final exception = ParserException(
        'Unexpected token: ${current.value}',
        position: current.position,
        expression: sourceExpression,
        suggestion: 'Check for extra operators or misplaced tokens',
      );

      if (recoverOnError) {
        errors.add(exception);
      } else {
        throw exception;
      }
    }

    return expr;
  }
}
