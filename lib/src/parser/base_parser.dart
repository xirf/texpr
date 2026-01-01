import '../ast.dart';
import '../exceptions.dart';
import '../token.dart';

abstract class BaseParser {
  final List<Token> tokens;
  String? sourceExpression;
  int position = 0;
  final List<String> delimiterStack = [];
  final bool recoverOnError;
  final List<ParserException> errors = [];

  final int maxRecursionDepth;

  BaseParser(this.tokens,
      [this.sourceExpression,
      this.recoverOnError = false,
      this.maxRecursionDepth = 500]);

  bool get isAtEnd => position >= tokens.length;

  Token get current => tokens[position];

  int _recursionDepth = 0;

  int _nodeCount = 0;
  static const int maxNodeCount = 10000;

  void registerNode() {
    if (++_nodeCount > maxNodeCount) {
      throw ParserException(
        'Expression complexity limit exceeded (too many nodes)',
        position: isAtEnd ? null : current.position,
        expression: sourceExpression,
        suggestion: 'Simplify your expression to reduce its size',
      );
    }
  }

  void enterRecursion() {
    if (++_recursionDepth > maxRecursionDepth) {
      throw ParserException(
        'Maximum nesting depth exceeded',
        position: isAtEnd ? null : current.position,
        expression: sourceExpression,
        suggestion: 'Simplify your expression or check for infinite recursion',
      );
    }
  }

  void exitRecursion() {
    _recursionDepth--;
  }

  Token advance() {
    if (!isAtEnd) position++;
    return tokens[position - 1];
  }

  bool check(TokenType type) => !isAtEnd && current.type == type;

  bool match(List<TokenType> types) {
    for (final type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  bool match1(TokenType type) {
    if (check(type)) {
      advance();
      return true;
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  Token? matchToken(TokenType type) {
    if (check(type)) {
      final t = current;
      advance();
      return t;
    }
    return null;
  }

  Token consume(TokenType type, String message) {
    if (check(type)) return advance();

    final exception = ParserException(
      message,
      position: isAtEnd
          ? (tokens.isNotEmpty ? tokens.last.position : 0)
          : current.position,
      expression: sourceExpression,
      suggestion: _getSuggestion(type, message),
    );

    if (recoverOnError) {
      errors.add(exception);
      // Construct a synthetic token to satisfy the consumer
      // This allows the parser to continue as if it found the token
      return Token(
        type: type,
        value: type == TokenType.lparen
            ? '{'
            : (type == TokenType.rparen ? '}' : ''),
        position: isAtEnd
            ? (tokens.isNotEmpty ? tokens.last.position : 0)
            : current.position,
      );
    }

    throw exception;
  }

  String? _getSuggestion(TokenType expectedType, String message) {
    if (message.contains("Expected '{'")) {
      return 'Add an opening brace {';
    } else if (message.contains("Expected '}'")) {
      return 'Add a closing brace } or check for matching braces';
    } else if (message.contains("Expected '('")) {
      return 'Add an opening parenthesis (';
    } else if (message.contains("Expected ')'")) {
      return 'Add a closing parenthesis ) or check for matching parentheses';
    }
    return null;
  }

  Expression parseWithDelimiter(
      String delimiter, Expression Function() parser) {
    delimiterStack.add(delimiter);
    try {
      return parser();
    } finally {
      delimiterStack.removeLast();
    }
  }

  String parseLatexArgument() {
    consume(TokenType.lparen, "Expected '{'");
    final buffer = StringBuffer();
    while (!check(TokenType.rparen) && !isAtEnd) {
      buffer.write(advance().value);
    }
    consume(TokenType.rparen, "Expected '}'");
    return buffer.toString();
  }

  Expression parseLatexArgumentExpr() {
    consume(TokenType.lparen, "Expected '{'");
    final expr = parseExpression();
    consume(TokenType.rparen, "Expected '}'");
    return expr;
  }

  // Abstract methods for mutual recursion
  Expression parseExpression();
  Expression parsePlusMinus();
  Expression parsePrimary();
  Expression parseUnary();
  Expression parseTerm();
  Expression parsePower();

  Expression parseFunctionCall();
  Expression parseLimitExpr();
  Expression parseSumExpr();
  Expression parseProductExpr();
  Expression parseIntegralExpr();
  Expression parseMatrix();
}
