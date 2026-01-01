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
    if (tokens.length > 4 &&
        tokens[0].type == TokenType.variable &&
        tokens[1].type == TokenType.lparen &&
        tokens[2].type == TokenType.variable &&
        tokens[3].type == TokenType.rparen &&
        tokens[4].type == TokenType.equals) {
      position += 5;
    }

    var expr = parseExpression();

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
