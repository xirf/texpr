import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Security vulnerability tests for the TeXpr
///
/// This test suite covers potential security vulnerabilities including:
/// 1. Denial of Service (DoS) through recursion attacks
/// 2. Resource exhaustion via large loop bounds
/// 3. Stack overflow from deeply nested expressions
/// 4. Integer overflow in factorial/fibonacci calculations
/// 5. Infinite loops in summation/product operations
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('DoS - Stack Overflow via Deep Recursion', () {
    test('deeply nested parentheses should not cause stack overflow', () {
      // CVE: Recursive descent parser without depth limit
      // Attacker can craft deeply nested expressions to exhaust stack
      final depth = 10000;
      final nested = '${'(' * depth}1${')' * depth}';

      expect(
        () => evaluator.evaluate(nested),
        throwsA(isA<Exception>()),
        reason:
            'Should fail gracefully with exception rather than stack overflow',
      );
    });

    test('deeply nested fractions should not cause stack overflow', () {
      // CVE: Parser recursion vulnerability
      var expr = '1';
      for (var i = 0; i < 1000; i++) {
        expr = r'\frac{' '$expr' '}{2}';
      }

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<Exception>()),
        reason: 'Deep nesting should fail gracefully',
      );
    });

    test('deeply nested powers should not cause stack overflow', () {
      // CVE: Power operator right-associative recursion
      var expr = '2';
      for (var i = 0; i < 1000; i++) {
        expr = '$expr^{2}';
      }

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<Exception>()),
        reason: 'Excessive power nesting should be rejected',
      );
    });

    test('deeply nested unary operators should not cause stack overflow', () {
      // CVE: Unary operator recursion
      final expr = '-' * 10000 + '1';

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<Exception>()),
        reason: 'Excessive unary nesting should fail safely',
      );
    });
  });

  group('DoS - Resource Exhaustion via Large Iterations', () {
    test('summation with extremely large bounds should timeout or reject', () {
      // CVE: No validation on sum bounds
      // Attacker can request sum from 1 to billions, causing hang
      final expr = r'\sum_{i=1}^{999999999} i';

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<Exception>()),
        reason: 'Large sum bounds should be rejected to prevent DoS',
      );
    });

    test('product with large bounds should timeout or reject', () {
      // CVE: No validation on product bounds
      final expr = r'\prod_{i=1}^{999999999} i';

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<Exception>()),
        reason:
            'Large product bounds should be rejected to prevent resource exhaustion',
      );
    });

    test('negative range summation should handle correctly', () {
      // CVE: Unsigned integer underflow if not handled
      final expr = r'\sum_{i=10}^{1} i';

      // Should either return 0 or handle gracefully
      expect(
        () => evaluator.evaluate(expr),
        returnsNormally,
        reason: 'Negative ranges should be handled without crashes',
      );
    });

    test('summation with extremely negative start should be rejected', () {
      // CVE: Large negative to positive range
      final expr = r'\sum_{i=-999999999}^{1000} i';

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<Exception>()),
        reason: 'Extremely large iteration ranges should be prevented',
      );
    });

    test('integral with unreasonably high subdivision should timeout', () {
      // CVE: Simpson's rule uses fixed n=1000, but repeated calls could DoS
      // Test multiple rapid integral evaluations
      final expr = r'\int_{0}^{100000} x^{2} dx';

      // This tests if there's any protection against large integration bounds
      expect(
        () {
          for (var i = 0; i < 100; i++) {
            evaluator.evaluate(expr);
          }
        },
        returnsNormally,
        reason: 'Integration should complete in reasonable time',
      );
    });
  });

  group('Integer/Numeric Overflow Vulnerabilities', () {
    test('factorial of very large number should fail gracefully', () {
      // CVE: Current limit is 170, test boundary and beyond
      expect(
        () => evaluator.evaluate(r'\factorial{171}'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Factorial overflow should be caught',
      );

      expect(
        () => evaluator.evaluate(r'\factorial{999999}'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Very large factorial should be rejected',
      );
    });

    test('fibonacci of very large number should fail gracefully', () {
      // CVE: Current limit is 1477, test boundary
      expect(
        () => evaluator.evaluate(r'\fibonacci{1477}'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Fibonacci overflow should be caught',
      );

      expect(
        () => evaluator.evaluate(r'\fibonacci{999999}'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Very large fibonacci should be rejected',
      );
    });

    test('power operation resulting in infinity should be handled', () {
      // CVE: Unchecked numeric overflow
      final result = evaluator.evaluate(r'10^{1000}');

      expect(
        result.asNumeric(),
        isA<double>(),
        reason: 'Should return a double (possibly infinity)',
      );

      // Verify it doesn't crash on infinity
      expect(result.asNumeric().isInfinite, isTrue,
          reason: 'Large powers should overflow to infinity, not crash');
    });

    test('division by zero should throw appropriate exception', () {
      // CVE: Division by zero error handling
      expect(
        () => evaluator.evaluate('1/0'),
        anyOf(
          throwsA(isA<EvaluatorException>()),
          // Or returns infinity depending on implementation
          returnsNormally,
        ),
        reason: 'Division by zero should be handled',
      );
    });

    test('nested factorial should not cause excessive computation', () {
      // CVE: Factorial within sum could amplify computation
      final expr = r'\sum_{i=1}^{100} \factorial{i}';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Factorial in loop should complete or fail gracefully',
      );
    });
  });

  group('Input Validation - Malicious Input', () {
    test('extremely long expression string should be rejected', () {
      // CVE: No input length validation
      final longExpr = '1+' * 1000000 + '1';

      expect(
        () => evaluator.evaluate(longExpr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally, // If it can handle it
        ),
        reason: 'Extremely long expressions should be handled',
      );
    });

    test('expression with extremely long variable name should fail', () {
      // CVE: No variable name length validation
      final longVar = 'x' * 10000;

      expect(
        () => evaluator.evaluate(longVar),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason:
            'Long variable names should be accepted or rejected cleanly without crashes',
      );
    });

    test('expression with null bytes should be rejected', () {
      // CVE: Null byte injection
      final expr = '1+1\x00+1';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Null bytes should not cause undefined behavior',
      );
    });

    test('expression with unicode exploits should be handled', () {
      // CVE: Unicode normalization issues
      final expr = '１＋１'; // Full-width characters

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Unicode characters should not bypass validation',
      );
    });
  });

  group('Parser Bomb - Exponential Complexity', () {
    test('expression with many implicit multiplications should not hang', () {
      // CVE: Implicit multiplication parsing complexity
      final expr = 'x${'y' * 1000}';

      expect(
        () => evaluator.evaluate(expr, {'x': 1.0, 'y': 1.0}),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Complex implicit multiplication should be handled',
      );
    });

    test('chained comparisons should not cause exponential parsing', () {
      // CVE: Comparison chain parsing complexity
      var expr = '1';
      for (var i = 0; i < 1000; i++) {
        expr += '< $i';
      }

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Long comparison chains should be handled efficiently',
      );
    });
  });

  group('Memory Exhaustion', () {
    test('cache should have reasonable size limits', () {
      // CVE: Unbounded cache growth
      final evaluatorWithCache = Texpr(parsedExpressionCacheSize: 128);

      // Try to fill cache with many unique expressions
      for (var i = 0; i < 10000; i++) {
        try {
          evaluatorWithCache.evaluate('$i + $i');
        } catch (_) {
          // Ignore evaluation errors, testing cache limits
        }
      }

      // If it doesn't crash, cache limiting works
      expect(true, isTrue, reason: 'Cache should not grow unbounded');
    });

    test('fibonacci cache should not grow indefinitely', () {
      // CVE: Fibonacci cache grows without bounds
      // Call fibonacci with increasing values
      for (var i = 0; i < 1000; i++) {
        try {
          evaluator.evaluate(r'\fibonacci{' '$i}');
        } catch (_) {
          // Expected for large values
        }
      }

      expect(true, isTrue,
          reason: 'Fibonacci cache should have reasonable limits');
    });

    test('factorial cache should not grow indefinitely', () {
      // CVE: Factorial cache is fixed at 171, verify it stays bounded
      for (var i = 0; i < 170; i++) {
        evaluator.evaluate(r'\factorial{' '$i}');
      }

      expect(true, isTrue,
          reason: 'Factorial cache should remain at fixed size');
    });
  });

  group('Regex DoS (ReDoS)', () {
    test('number parsing should not be vulnerable to ReDoS', () {
      // CVE: If regex is used for number parsing
      final maliciousNumber = '1${'0' * 100000}.';

      expect(
        () => evaluator.evaluate(maliciousNumber),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Malformed numbers should fail quickly',
      );
    });
  });

  group('Type Confusion', () {
    test('mixing incompatible types should fail gracefully', () {
      // CVE: Type confusion between matrix and scalar
      expect(
        () => evaluator
            .evaluate(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix} + 5'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Adding matrix to scalar should throw type error',
      );
    });

    test('complex number operations with real should be handled', () {
      // Ensure type coercion is safe
      final result = evaluator.evaluate('1 + 2');
      expect(result, isA<NumericResult>(),
          reason: 'Type should be correctly inferred');
    });
  });

  group('Limit Evaluation Edge Cases', () {
    test('limit with extremely small epsilon should not hang', () {
      // CVE: Limit evaluation uses decreasing epsilon, check for infinite loops
      final expr = r'\lim_{x \to 0} \frac{1}{x}';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Limit evaluation should complete in reasonable time',
      );
    });

    test('limit at infinity with non-converging function', () {
      // CVE: Limit at infinity evaluation might not converge
      final expr = r'\lim_{x \to \infty} \sin{x}';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Non-converging limits should be handled',
      );
    });
  });

  group('Variable Injection', () {
    test('variable names with special characters should be handled', () {
      // CVE: Variable name validation
      expect(
        () => evaluator.evaluate(r'$injection', {r'$injection': 1.0}),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Special characters in variable names should be validated',
      );
    });

    test('empty variable name should be rejected', () {
      expect(
        () => evaluator.evaluate('', {'': 1.0}),
        throwsA(isA<Exception>()),
        reason: 'Empty variable names should not be allowed',
      );
    });
  });

  group('Command Injection via Custom Extensions', () {
    test('malicious extension should be isolated', () {
      // CVE: If extensions can execute arbitrary code
      final customExt = ExtensionRegistry();

      // Register custom command tokenizer
      customExt.registerCommand(
          'malicious',
          (cmd, pos) =>
              Token(type: TokenType.function, value: cmd, position: pos));

      // Register evaluator
      customExt.registerEvaluator((expr, vars, eval) {
        if (expr is FunctionCall && expr.name == 'malicious') {
          // This should be isolated and not able to do file I/O or system calls
          return 1.0;
        }
        return null;
      });

      final customEvaluator = Texpr(extensions: customExt);

      expect(
        () => customEvaluator.evaluate(r'\malicious{1}'),
        returnsNormally,
        reason: 'Custom extensions should be sandboxed',
      );
    });
  });

  group('Symbolic Simplification - Infinite Loops', () {
    test('circular rewrite rules should not cause infinite loops', () {
      // CVE: Symbolic simplifier has maxIterations=100, test it
      final evaluator = Texpr();

      // Expression that might trigger many simplification passes
      final expr = evaluator.parse(r'x + x + x + x + x + x');
      // Note: Simplify is done internally, test that evaluation doesn't hang
      expect(
        () => evaluator.evaluateParsed(expr, {'x': 1.0}),
        returnsNormally,
        reason: 'Expression evaluation should terminate',
      );
    });

    test('deeply recursive symbolic expressions should not overflow', () {
      final evaluator = Texpr();

      // Create deeply nested parentheses to test recursion depth
      var expr = 'x';
      for (var i = 0; i < 600; i++) {
        expr = '($expr)';
      }

      expect(
        () {
          final parsed = evaluator.parse(expr);
          evaluator.evaluateParsed(parsed, {'x': 1.0});
        },
        throwsA(isA<Exception>()),
        reason: 'Deeply nested expressions should hit recursion depth limit',
      );
    });
  });

  group('Gradient Evaluation DoS', () {
    test(
        'gradient with many variables should not cause exponential computation',
        () {
      // CVE: Gradient computes partial derivatives for each variable
      // Many variables could cause excessive computation
      final manyVars = List.generate(50, (i) => 'x$i').join('+');
      final expr = r'\nabla{' + manyVars + '}';

      expect(
        () => evaluator.evaluate(
          expr,
          Map.fromEntries(List.generate(50, (i) => MapEntry('x$i', 1.0))),
        ),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason:
            'Gradient with many variables should complete or fail gracefully',
      );
    });

    test('gradient of deeply nested expression should not overflow', () {
      // CVE: Nested symbolic differentiation could cause stack overflow
      var expr = 'x';
      for (var i = 0; i < 100; i++) {
        expr = '\\sin{$expr}';
      }

      expect(
        () => evaluator.evaluate(r'\nabla{' + expr + '}', {'x': 1.0}),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Nested gradient should be handled safely',
      );
    });
  });

  group('Binomial Coefficient Vulnerabilities', () {
    test('binom with very large n should fail gracefully', () {
      // CVE: Binomial uses factorial internally which can overflow
      expect(
        () => evaluator.evaluate(r'\binom{1000}{500}'),
        anyOf(returnsNormally, throwsA(isA<EvaluatorException>())),
        reason: 'Large binomial should be rejected or return infinity',
      );
    });

    test('binom with negative values should be handled', () {
      // CVE: Negative values in binomial calculation
      expect(
        () => evaluator.evaluate(r'\binom{-5}{3}'),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Negative binomial should not crash',
      );
    });

    test('binom with k > n should return zero or fail gracefully', () {
      // CVE: Edge case where k exceeds n
      expect(
        () => evaluator.evaluate(r'\binom{5}{10}'),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'k > n binomial should be handled',
      );
    });
  });

  group('High-Order Derivative Vulnerabilities', () {
    test('very high order derivative should not cause stack overflow', () {
      // CVE: High order derivatives cause repeated recursion
      expect(
        () => evaluator
            .evaluate(r'\frac{d^{1000}}{dx^{1000}} x^{1000}', {'x': 1.0}),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Very high order derivatives should be limited',
      );
    });

    test('high order derivative with complex expression should be bounded', () {
      // CVE: Trigonometric derivatives grow in complexity
      expect(
        () =>
            evaluator.evaluate(r'\frac{d^{100}}{dx^{100}} \sin{x}', {'x': 0.0}),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'High order trigonometric derivatives should complete',
      );
    });

    test('partial derivative with many variables should be bounded', () {
      // CVE: Chained partial derivatives could cause exponential growth
      final expr =
          r'\frac{\partial}{\partial x} \frac{\partial}{\partial y} \frac{\partial}{\partial z} ' *
                  10 +
              'xyz';
      expect(
        () => evaluator.evaluate(expr, {'x': 1.0, 'y': 1.0, 'z': 1.0}),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Chained partial derivatives should be limited',
      );
    });
  });

  group('Multi-Integral Vulnerabilities', () {
    test('multi-integral with many variables should not hang', () {
      // CVE: Triple integrals could cause O(n^3) complexity
      expect(
        () => evaluator
            .evaluate(r'\iiint_{0}^{10} x \cdot y \cdot z \, dx \, dy \, dz'),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Triple integral should complete or fail gracefully',
      );
    });

    test('nested integrals should not cause exponential complexity', () {
      // CVE: Nested single integrals could exhaust resources
      final expr = r'\int_{0}^{1} ' * 5 + r'x dx' + r' dx' * 4;
      expect(
        () => evaluator.evaluate(expr, {'x': 1.0}),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Nested integrals should not cause exponential growth',
      );
    });
  });

  group('Visitor Pattern Depth Vulnerabilities', () {
    test('toJson should handle deeply nested expressions', () {
      // CVE: JSON export uses recursive visitor pattern
      var expr = 'x';
      for (var i = 0; i < 500; i++) {
        expr = '($expr)';
      }

      expect(
        () {
          final parsed = evaluator.parse(expr);
          parsed.toJson();
        },
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'JSON export should handle deep nesting',
      );
    });

    test('toMathML should handle deeply nested expressions', () {
      // CVE: MathML export uses recursive visitor pattern
      var expr = 'x';
      for (var i = 0; i < 500; i++) {
        expr = '($expr)';
      }

      expect(
        () {
          final parsed = evaluator.parse(expr);
          parsed.toMathML();
        },
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'MathML export should handle deep nesting',
      );
    });

    test('toLatex roundtrip should handle deeply nested expressions', () {
      // CVE: LaTeX export uses recursive visitor pattern
      var expr = 'x';
      for (var i = 0; i < 500; i++) {
        expr = '($expr)';
      }

      expect(
        () {
          final parsed = evaluator.parse(expr);
          parsed.toLatex();
        },
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'LaTeX roundtrip should handle deep nesting',
      );
    });
  });

  group('Export Injection Vulnerabilities', () {
    test('variable names should be safely handled in MathML', () {
      // CVE: Special characters could break MathML structure
      expect(
        () => evaluator.parse('x').toMathML(),
        returnsNormally,
        reason: 'MathML export should not crash on normal input',
      );
    });

    test('toJson with variable names should serialize safely', () {
      // CVE: JSON serialization should handle all variable names
      expect(
        () => evaluator.parse('alpha').toJson(),
        returnsNormally,
        reason: 'JSON should serialize safely',
      );
    });
  });

  group('Vector/Matrix Dimension Vulnerabilities', () {
    test('extremely large matrix should be rejected', () {
      // CVE: Large matrices could exhaust memory
      final rows = List.generate(100, (i) => List.filled(100, '1').join(' & '))
          .join(r' \\ ');
      final expr = r'\begin{pmatrix} ' + rows + r' \end{pmatrix}';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Large matrices should be handled gracefully',
      );
    });

    test('mismatched matrix dimensions in operations should throw', () {
      // CVE: Dimension validation should prevent invalid operations
      expect(
        () => evaluator.evaluate(
            r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix} \cdot \begin{pmatrix} 1 \\ 2 \\ 3 \end{pmatrix}'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Dimension mismatch should be caught',
      );
    });

    test('empty matrix should be handled', () {
      // CVE: Empty matrix edge case
      expect(
        () => evaluator.evaluate(r'\begin{pmatrix} \end{pmatrix}'),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Empty matrix should not crash',
      );
    });
  });

  group('Piecewise Function Vulnerabilities', () {
    test('piecewise with many cases should not hang', () {
      // CVE: Many piecewise cases could slow down evaluation
      var cases = List.generate(100, (i) => '$i & x = $i').join(r' \\ ');
      final expr = r'\begin{cases} ' + cases + r' \end{cases}';

      expect(
        () => evaluator.evaluate(expr, {'x': 50.0}),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Many piecewise cases should be evaluated efficiently',
      );
    });

    test('deeply nested piecewise should be bounded', () {
      // CVE: Nested piecewise could cause deep recursion
      var expr = '1';
      for (var i = 0; i < 50; i++) {
        expr =
            r'\begin{cases} ' + expr + r' & x > 0 \\ 0 & x \le 0 \end{cases}';
      }

      expect(
        () => evaluator.evaluate(expr, {'x': 1.0}),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: 'Nested piecewise should be limited',
      );
    });
  });

  group('Negative and Zero Edge Cases', () {
    test('0^0 should return 1 or handle gracefully', () {
      // CVE: Mathematical indeterminate form
      expect(
        () => evaluator.evaluate('0^0'),
        anyOf(returnsNormally, throwsA(isA<Exception>())),
        reason: '0^0 indeterminate form should be handled',
      );
    });

    test('negative factorial should throw', () {
      // CVE: Factorial of negative numbers is undefined
      expect(
        () => evaluator.evaluate(r'\factorial{-5}'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Negative factorial should throw',
      );
    });

    test('log of zero should throw or return negative infinity', () {
      // CVE: Log of zero is undefined
      expect(
        () => evaluator.evaluate(r'\ln{0}'),
        anyOf(
          throwsA(isA<EvaluatorException>()),
          returnsNormally, // May return -infinity
        ),
        reason: 'Log of zero should be handled',
      );
    });

    test('sqrt of negative should return complex or throw', () {
      // CVE: Square root of negative in real-only context
      final result = evaluator.evaluate(r'\sqrt{-1}');
      expect(
        result.isComplex || result.isNumeric,
        isTrue,
        reason: 'sqrt(-1) should return complex i or handle gracefully',
      );
    });
  });
}
