/// Custom exceptions for the TeXpr library.
library;

/// Base exception for all TeXpr errors.
sealed class TexprException implements Exception {
  final String message;
  final int? position;
  final String? expression;
  final String? suggestion;

  const TexprException(
    this.message, {
    this.position,
    this.expression,
    this.suggestion,
  });

  /// Formats the error with position markers showing where the error occurred.
  String _formatWithPositionMarker() {
    if (expression == null || position == null) {
      return message;
    }

    final buffer = StringBuffer();
    buffer.writeln(message);
    buffer.writeln();

    // Show expression with position marker
    final snippetStart = (position! - 20).clamp(0, expression!.length);
    final snippetEnd = (position! + 20).clamp(0, expression!.length);
    final snippet = expression!.substring(snippetStart, snippetEnd);
    final markerPos = position! - snippetStart;

    if (snippetStart > 0) buffer.write('...');
    buffer.write(snippet);
    if (snippetEnd < expression!.length) buffer.write('...');
    buffer.writeln();

    // Add position marker (^)
    if (snippetStart > 0) buffer.write('   '); // account for "..."
    buffer.write(' ' * markerPos);
    buffer.write('^');

    return buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType');

    if (position != null) {
      buffer.write(' at position $position');
    }

    buffer.write(': ');
    buffer.write(_formatWithPositionMarker());

    if (suggestion != null) {
      buffer.write('\nSuggestion: $suggestion');
    }

    return buffer.toString();
  }
}

/// Exception thrown during tokenization.
class TokenizerException extends TexprException {
  const TokenizerException(
    super.message, {
    super.position,
    super.expression,
    super.suggestion,
  });
}

/// Exception thrown during parsing.
class ParserException extends TexprException {
  const ParserException(
    super.message, {
    super.position,
    super.expression,
    super.suggestion,
  });
}

/// Exception thrown during evaluation.
class EvaluatorException extends TexprException {
  const EvaluatorException(
    super.message, {
    super.position,
    super.expression,
    super.suggestion,
  });
}

/// Result of validating a Texpr math expression.
///
/// Contains information about whether the expression is valid and,
/// if not, details about the error including position and suggestions.
///
/// Example:
/// ```dart
/// final result = evaluator.validate(r'\sin{x');
/// if (!result.isValid) {
///   print('Error: ${result.errorMessage}');
///   print('Position: ${result.position}');
///   if (result.suggestion != null) {
///     print('Suggestion: ${result.suggestion}');
///   }
/// }
/// ```
class ValidationResult {
  /// Whether the expression is valid.
  final bool isValid;

  /// Error message if the expression is invalid, null otherwise.
  final String? errorMessage;

  /// Position where the error occurred, null if valid or position unknown.
  final int? position;

  /// Suggested fix for the error, null if no suggestion available.
  final String? suggestion;

  /// The exception type that occurred, null if valid.
  final Type? exceptionType;

  /// List of additional errors found during validation.
  final List<ValidationResult> subErrors;

  /// Creates a validation result.
  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.position,
    this.suggestion,
    this.exceptionType,
    this.subErrors = const [],
  });

  /// Creates a successful validation result.
  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null,
        position = null,
        suggestion = null,
        exceptionType = null,
        subErrors = const [];

  /// Creates a failed validation result from an exception.
  ///
  /// Analyzes the error message and provides context-aware suggestions.
  factory ValidationResult.fromException(
    TexprException exception, {
    String? expression,
  }) {
    String? suggestion = exception.suggestion;
    final expr = expression ?? exception.expression;

    // If no suggestion from exception, generate one
    if (suggestion == null) {
      final message = exception.message.toLowerCase();

      // Unknown function/command with did-you-mean
      final unknownMatch = RegExp(r'unknown\s+(?:function|command):\s*(\w+)',
              caseSensitive: false)
          .firstMatch(exception.message);
      if (unknownMatch != null) {
        final unknown = unknownMatch.group(1)!;
        // Try to find similar command (would need error_suggestions import)
        suggestion =
            'Verify that "$unknown" is a supported function or check spelling';
      }

      // Specific error patterns
      else if (message.contains('unexpected end')) {
        suggestion = 'Check for unclosed braces {} or parentheses ()';
      } else if (message.contains('undefined variable')) {
        final varMatch =
            RegExp(r'undefined variable[:\s]+(\w+)', caseSensitive: false)
                .firstMatch(exception.message);
        if (varMatch != null) {
          suggestion =
              'Provide a value for "${varMatch.group(1)}" in the variables map';
        } else {
          suggestion = 'Provide a value for this variable in the variables map';
        }
      } else if (message.contains('division by zero')) {
        suggestion = 'Ensure the denominator is not zero';
      } else if (message.contains("expected '}'") ||
          message.contains("expected \"}\"")) {
        suggestion = 'Missing closing brace } - check for unmatched {';
      } else if (message.contains("expected ')'") ||
          message.contains("expected \")\"")) {
        suggestion = 'Missing closing parenthesis ) - check for unmatched (';
      } else if (message.contains("expected '{'") ||
          message.contains("expected \"{\"")) {
        suggestion =
            'Missing opening brace { - Commands require braces: \\func{arg}';
      } else if (message.contains('expected expression')) {
        suggestion =
            'Check for missing operands or invalid syntax near this position';
      } else if (message.contains('invalid') && message.contains('base')) {
        suggestion = 'Logarithm base must be positive and not equal to 1';
      } else if (message.contains('domain') ||
          message.contains('out of range')) {
        suggestion =
            'Input value is outside the valid domain for this function';
      }
      // Gradient and symbolic evaluation errors
      else if (message.contains('gradient') || message.contains('nabla')) {
        suggestion =
            'The gradient operator (∇) requires a concrete expression like "∇{x² + y²}". '
            'Symbolic gradients like "∇f" cannot be evaluated numerically';
      } else if (message.contains('symbolic') ||
          message.contains('cannot be evaluated')) {
        suggestion =
            'This expression contains symbolic notation that cannot be computed numerically. '
            'Replace abstract symbols with concrete expressions';
      } else if (message.contains('tensor') || message.contains('index')) {
        suggestion =
            'Tensor notation is supported for parsing but not for numerical evaluation. '
            'TeXpr treats subscripted variables as composite names';
      } else if (message.contains('matrix') && message.contains('dimension')) {
        suggestion = 'Matrix dimensions must be compatible for this operation. '
            'Check that row and column counts match';
      } else if (message.contains('expected')) {
        suggestion = 'Check syntax near this position';
      }

      // Try common mistake detection if we have the expression
      if (suggestion == null && expr != null) {
        // Simple check for frac without braces
        if (expr.contains(r'\frac') && RegExp(r'\\frac\d').hasMatch(expr)) {
          suggestion =
              'Use \\frac{numerator}{denominator} with braces, not \\frac12';
        }
      }
    }

    return ValidationResult(
      isValid: false,
      errorMessage: exception.message,
      position: exception.position,
      suggestion: suggestion,
      exceptionType: exception.runtimeType,
    );
  }

  /// Creates a failed validation result from a list of exceptions.
  factory ValidationResult.fromExceptions(
    List<TexprException> exceptions, {
    String? expression,
  }) {
    if (exceptions.isEmpty) return const ValidationResult.valid();

    final subErrors = exceptions
        .map((e) => ValidationResult.fromException(e, expression: expression))
        .toList();

    // Use the first exception as the main error, but include all in subErrors
    final primary = subErrors.first;

    return ValidationResult(
      isValid: false,
      errorMessage: primary.errorMessage,
      position: primary.position,
      suggestion: primary.suggestion,
      exceptionType: primary.exceptionType,
      subErrors: subErrors,
    );
  }

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult: valid';
    }

    final buffer = StringBuffer('ValidationResult: invalid\n');
    buffer.write('  Error: $errorMessage');

    if (position != null) {
      buffer.write('\n  Position: $position');
    }

    if (suggestion != null) {
      buffer.write('\n  Suggestion: $suggestion');
    }

    if (exceptionType != null) {
      buffer.write('\n  Type: $exceptionType');
    }

    return buffer.toString();
  }

  /// Returns a formatted string with all errors.
  String toStringWithErrors() {
    if (isValid) return toString();

    final buffer = StringBuffer(toString());
    if (subErrors.length > 1) {
      buffer.writeln('\n\nOther errors:');
      for (var i = 1; i < subErrors.length; i++) {
        buffer.writeln('${i + 1}. ${subErrors[i].errorMessage}');
        if (subErrors[i].position != null) {
          buffer.writeln('   at position ${subErrors[i].position}');
        }
      }
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResult &&
          runtimeType == other.runtimeType &&
          isValid == other.isValid &&
          errorMessage == other.errorMessage &&
          position == other.position &&
          suggestion == other.suggestion &&
          exceptionType == other.exceptionType &&
          _listEquals(subErrors, other.subErrors);

  @override
  int get hashCode =>
      isValid.hashCode ^
      errorMessage.hashCode ^
      position.hashCode ^
      suggestion.hashCode ^
      exceptionType.hashCode ^
      Object.hashAll(subErrors);
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
