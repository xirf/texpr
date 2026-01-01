import '../ast.dart';
import '../token.dart';
import '../exceptions.dart';
import 'base_parser.dart';

mixin MatrixParserMixin on BaseParser {
  @override
  Expression parseMatrix() {
    final env = parseLatexArgument();

    // Handle cases environment for piecewise functions
    if (env == 'cases') {
      return _parseCases(env);
    }

    if (!['matrix', 'pmatrix', 'bmatrix', 'vmatrix', 'align', 'aligned']
        .contains(env)) {
      throw ParserException(
        'Unsupported environment: $env',
        position: position,
        expression: sourceExpression,
        suggestion: 'Use matrix, pmatrix, bmatrix, vmatrix, align, or cases',
      );
    }

    final rows = <List<Expression>>[];
    var currentRow = <Expression>[];

    while (!check(TokenType.end) && !isAtEnd) {
      if (check(TokenType.ampersand) ||
          check(TokenType.backslash) ||
          check(TokenType.end)) {
        registerNode();
        currentRow.add(NumberLiteral(0.0));
      } else {
        currentRow.add(parseExpression());
      }

      if (match1(TokenType.ampersand)) {
        continue;
      } else if (match1(TokenType.backslash)) {
        rows.add(currentRow);
        currentRow = [];
      } else if (!check(TokenType.end)) {
        throw ParserException(
          'Expected & or \\\\ or \\end',
          position: current.position,
          expression: sourceExpression,
          suggestion: 'Use & to separate columns or \\\\ to start a new row',
        );
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    consume(TokenType.end, "Expected \\end after matrix body");
    final endEnv = parseLatexArgument();

    if (endEnv != env) {
      throw ParserException(
        'Environment mismatch: \\begin{$env} ... \\end{$endEnv}',
        position: position,
        expression: sourceExpression,
        suggestion: 'Use \\end{$env} to match \\begin{$env}',
      );
    }

    registerNode();
    return MatrixExpr(rows);
  }

  /// Parses a cases environment for piecewise functions.
  ///
  /// Format: `\begin{cases} expr1 & cond1 \\ expr2 & cond2 \end{cases}`
  Expression _parseCases(String env) {
    final cases = <PiecewiseCase>[];

    while (!check(TokenType.end) && !isAtEnd) {
      // Skip leading whitespace/newlines
      if (check(TokenType.backslash)) {
        advance();
        continue;
      }

      // Parse the expression part (before the &)
      final expression = parseExpression();

      // Check for & separator
      Expression? condition;
      if (match1(TokenType.ampersand)) {
        // Parse the condition part (after the &)
        // The condition might be wrapped in \text{...} like "for x < 0"
        // or just a raw condition like "x < 0"
        condition = _parseCondition();
      }

      cases.add(PiecewiseCase(expression, condition));

      // Consume row separator if present
      if (check(TokenType.backslash)) {
        advance();
      }
    }

    consume(TokenType.end, "Expected \\end after cases body");
    final endEnv = parseLatexArgument();

    if (endEnv != env) {
      throw ParserException(
        'Environment mismatch: \\begin{$env} ... \\end{$endEnv}',
        position: position,
        expression: sourceExpression,
        suggestion: 'Use \\end{$env} to match \\begin{$env}',
      );
    }

    if (cases.isEmpty) {
      throw ParserException(
        'Empty cases environment',
        position: position,
        expression: sourceExpression,
        suggestion: 'Add at least one case: expr & condition',
      );
    }

    registerNode();
    return PiecewiseExpr(cases);
  }

  /// Parses a condition in a cases environment.
  ///
  /// Handles various formats:
  /// - Direct comparison: `x < 0`
  /// - With text prefix: `\text{for } x < 0`
  /// - "otherwise": `\text{otherwise}`
  Expression? _parseCondition() {
    // Skip \text{...} prefixes like "for ", "if ", etc.
    while (check(TokenType.text)) {
      advance();
      final text = parseLatexArgument();
      // If it's just "otherwise", return null (catch-all case)
      final normalized = text.toLowerCase().trim();
      if (normalized == 'otherwise' ||
          normalized == 'else' ||
          normalized == 'otherwise.' ||
          normalized == 'else.') {
        return null;
      }
      // Otherwise it's a prefix like "for " or "if ", continue parsing
    }

    // If we're at the end of this row, there's no condition (otherwise case)
    if (check(TokenType.backslash) || check(TokenType.end)) {
      return null;
    }

    // Parse the actual condition expression
    return parseExpression();
  }
}
