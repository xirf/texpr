/// Error suggestion utilities for parser and evaluator errors.
///
/// Provides did-you-mean suggestions and common mistake detection.
library;

import 'dart:math' as math;

/// Known LaTeX commands for did-you-mean suggestions.
const knownCommands = <String>{
  // Functions
  'sin', 'cos', 'tan', 'cot', 'sec', 'csc',
  'asin', 'acos', 'atan', 'arcsin', 'arccos', 'arctan',
  'sinh', 'cosh', 'tanh', 'asinh', 'acosh', 'atanh',
  'ln', 'log', 'exp', 'sqrt',
  'abs', 'sgn', 'sign', 'factorial', 'fibonacci',
  'min', 'max', 'gcd', 'lcm', 'binom',
  'det', 'trace', 'tr',
  'Re', 'Im', 'conjugate',
  'ceil', 'floor', 'round',
  // Operators
  'frac', 'times', 'div', 'cdot', 'pm', 'mp',
  'sum', 'prod', 'int', 'iint', 'iiint',
  'lim', 'to', 'infty',
  // Delimiters
  'left', 'right',
  'begin', 'end',
  // Greek letters
  'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta',
  'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'pi', 'rho',
  'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',
  'partial', 'nabla',
  // Other
  'text', 'matrix', 'pmatrix', 'bmatrix', 'vmatrix',
};

/// Common LaTeX command aliases and misspellings.
const commandAliases = <String, String>{
  'sine': 'sin',
  'cosine': 'cos',
  'tangent': 'tan',
  'cotangent': 'cot',
  'secant': 'sec',
  'cosecant': 'csc',
  'arcsine': 'asin',
  'arccosine': 'acos',
  'arctangent': 'atan',
  'squareroot': 'sqrt',
  'squarerroot': 'sqrt',
  'sqroot': 'sqrt',
  'logn': 'ln',
  'loge': 'ln',
  'log10': 'log',
  'natural_log': 'ln',
  'absolute': 'abs',
  'signum': 'sgn',
  'fact': 'factorial',
  'fib': 'fibonacci',
  'determinant': 'det',
  'integrate': 'int',
  'integral': 'int',
  'summation': 'sum',
  'product': 'prod',
  'limit': 'lim',
  'infinity': 'infty',
  'fraction': 'frac',
  'multiply': 'times',
  'divide': 'div',
  'binomial': 'binom',
  'realpart': 'Re',
  'imagpart': 'Im',
  'conj': 'conjugate',
  'ceiling': 'ceil',
  'angle': 'theta',
  'partial_derivative': 'partial',
  'gradient': 'nabla',
  'deg': 'degree',
};

/// Computes the Levenshtein distance between two strings.
int levenshteinDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));

  for (int i = 0; i <= a.length; i++) {
    dp[i][0] = i;
  }
  for (int j = 0; j <= b.length; j++) {
    dp[0][j] = j;
  }

  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      dp[i][j] = [
        dp[i - 1][j] + 1, // deletion
        dp[i][j - 1] + 1, // insertion
        dp[i - 1][j - 1] + cost, // substitution
      ].reduce(math.min);
    }
  }

  return dp[a.length][b.length];
}

/// Finds the best matching command for an unknown command.
///
/// Returns null if no good match is found (distance too large).
String? findSimilarCommand(String unknown) {
  // First check aliases
  final lowerUnknown = unknown.toLowerCase();
  if (commandAliases.containsKey(lowerUnknown)) {
    return commandAliases[lowerUnknown];
  }

  // Then check Levenshtein distance
  String? bestMatch;
  int bestDistance = 3; // Maximum distance threshold

  for (final cmd in knownCommands) {
    final distance = levenshteinDistance(lowerUnknown, cmd.toLowerCase());
    if (distance < bestDistance) {
      bestDistance = distance;
      bestMatch = cmd;
    }
  }

  return bestMatch;
}

/// Detects common LaTeX mistakes and returns a suggestion.
///
/// Returns a map with 'pattern' (what was detected) and 'suggestion'.
Map<String, String>? detectCommonMistake(String expression, int? position) {
  if (expression.isEmpty) return null;

  // Pattern: \frac12 instead of \frac{1}{2}
  final fracPattern = RegExp(r'\\frac\s*(\d)(\d)?(?!\s*\{)');
  final fracMatch = fracPattern.firstMatch(expression);
  if (fracMatch != null) {
    final num1 = fracMatch.group(1) ?? '';
    final num2 = fracMatch.group(2) ?? '';
    if (num2.isNotEmpty) {
      return {
        'pattern': '\\frac$num1$num2',
        'suggestion':
            'Use \\frac{$num1}{$num2} with braces around numerator and denominator',
      };
    } else {
      return {
        'pattern': '\\frac$num1',
        'suggestion':
            'Use \\frac{$num1}{...} with braces. Example: \\frac{1}{2}',
      };
    }
  }

  // Pattern: missing backslash before known function
  for (final cmd in ['sin', 'cos', 'tan', 'log', 'exp', 'sqrt', 'abs', 'ln']) {
    final pattern = RegExp('(?<!\\\\)\\b$cmd\\s*\\(');
    if (pattern.hasMatch(expression)) {
      return {
        'pattern': '$cmd(',
        'suggestion': 'Add backslash before function name: \\$cmd{...}',
      };
    }
  }

  // Pattern: using parentheses instead of braces for LaTeX commands
  final parenPattern = RegExp(r'\\(sin|cos|tan|log|exp|sqrt|abs|ln)\s*\(');
  final parenMatch = parenPattern.firstMatch(expression);
  if (parenMatch != null) {
    final func = parenMatch.group(1);
    return {
      'pattern': '\\$func(...)',
      'suggestion':
          'Use braces for LaTeX functions: \\$func{...}. Parentheses work but braces are preferred.',
    };
  }

  // Pattern: unmatched braces (simple check)
  int braceCount = 0;
  for (int i = 0; i < expression.length; i++) {
    if (expression[i] == '{') braceCount++;
    if (expression[i] == '}') braceCount--;
  }
  if (braceCount > 0) {
    return {
      'pattern': 'unmatched braces',
      'suggestion':
          'Missing $braceCount closing brace${braceCount > 1 ? 's' : ''} }',
    };
  } else if (braceCount < 0) {
    return {
      'pattern': 'unmatched braces',
      'suggestion':
          'Extra ${-braceCount} closing brace${-braceCount > 1 ? 's' : ''} } without matching open brace',
    };
  }

  // Pattern: unmatched parentheses
  int parenCount = 0;
  for (int i = 0; i < expression.length; i++) {
    if (expression[i] == '(') parenCount++;
    if (expression[i] == ')') parenCount--;
  }
  if (parenCount > 0) {
    return {
      'pattern': 'unmatched parentheses',
      'suggestion':
          'Missing $parenCount closing parenthesis${parenCount > 1 ? 'es' : ''} )',
    };
  } else if (parenCount < 0) {
    return {
      'pattern': 'unmatched parentheses',
      'suggestion':
          'Extra ${-parenCount} closing parenthesis${-parenCount > 1 ? 'es' : ''} ) without matching open',
    };
  }

  return null;
}
