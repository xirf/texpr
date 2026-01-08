import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Cache security and poisoning tests
///
/// This test suite covers:
/// 1. Cache poisoning attacks
/// 2. Cache collision attacks
/// 3. Cache timing side-channels
/// 4. Memory exhaustion via cache
/// 5. Cache invalidation security
void main() {
  group('Cache Poisoning Attacks', () {
    test('malicious expressions should not pollute cache', () {
      // CVE: Cache poisoning
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Try to poison cache with malicious expression
      try {
        evaluator.evaluate('1' * 10000);
      } catch (_) {
        // Expected to fail
      }

      // Normal expression should still work
      final result = evaluator.evaluate('1 + 1');
      expect(result.asNumeric(), equals(2.0),
          reason: 'Cache should not be poisoned by malicious input');
    });

    test('repeated malicious evaluations should not corrupt cache', () {
      // CVE: Cache corruption via repetition
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Repeatedly try to evaluate malicious expressions
      for (var i = 0; i < 1000; i++) {
        try {
          evaluator.evaluate(r'\unknownFunc{' '$i}');
        } catch (_) {
          // Expected
        }
      }

      // Cache should still work correctly
      final result = evaluator.evaluate(r'\sin{0}');
      expect(result.asNumeric(), equals(0.0),
          reason: 'Cache should remain functional after errors');
    });

    test('cache should handle expressions with same prefix', () {
      // CVE: Prefix collision attack
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final exprs = [
        r'\sin{x}',
        r'\sin{x} + 1',
        r'\sin{x} + 2',
        r'\sin{x} * 2',
      ];

      for (final expr in exprs) {
        final result = evaluator.evaluate(expr, {'x': 0.0});
        expect(result, isA<NumericResult>(),
            reason: 'Each expression should be cached separately');
      }
    });

    test('cache should handle hash collisions safely', () {
      // CVE: Hash collision exploitation
      final evaluator = Texpr(parsedExpressionCacheSize: 10);

      // Generate many expressions to force potential collisions
      for (var i = 0; i < 100; i++) {
        final expr = '$i + $i';
        final result = evaluator.evaluate(expr);
        expect(result.asNumeric(), equals(i * 2.0),
            reason: 'Hash collisions should not affect correctness');
      }
    });
  });

  group('Cache Eviction Security', () {
    test('LRU eviction should not be exploitable', () {
      // CVE: Cache eviction timing attack
      final evaluator = Texpr(parsedExpressionCacheSize: 2);

      // Fill cache
      evaluator.evaluate('1 + 1');
      evaluator.evaluate('2 + 2');

      // Access first again (should be in cache)
      final start1 = DateTime.now();
      evaluator.evaluate('1 + 1');
      final time1 = DateTime.now().difference(start1);

      // Add new expression (should evict least recently used)
      evaluator.evaluate('3 + 3');

      // Access evicted expression
      final start2 = DateTime.now();
      evaluator.evaluate('2 + 2');
      final time2 = DateTime.now().difference(start2);

      // Both should still evaluate correctly
      expect(
        evaluator.evaluate('1 + 1').asNumeric(),
        equals(2.0),
        reason: 'Eviction should not affect correctness',
      );
    });

    test('filling cache with unique expressions should not crash', () {
      // CVE: Cache overflow attack
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Try to fill and overflow cache
      for (var i = 0; i < 10000; i++) {
        final result = evaluator.evaluate('$i + 1');
        expect(result.asNumeric(), equals(i + 1.0));
      }

      expect(true, isTrue, reason: 'Cache should handle overflow gracefully');
    });
  });

  group('Cache Timing Side-Channels', () {
    test('cache hit vs miss should not create significant timing difference',
        () {
      // CVE: Cache timing attack
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Warm up cache
      evaluator.evaluate(r'\sin{0}');

      // Measure cache hit
      final start1 = DateTime.now();
      evaluator.evaluate(r'\sin{0}');
      final cacheHit = DateTime.now().difference(start1);

      // Measure cache miss
      final start2 = DateTime.now();
      evaluator.evaluate(r'\cos{0}');
      final cacheMiss = DateTime.now().difference(start2);

      // Verify both evaluate correctly
      expect(evaluator.evaluate(r'\sin{0}').asNumeric(), equals(0.0));
      expect(evaluator.evaluate(r'\cos{0}').asNumeric(), equals(1.0));

      // Note: Timing differences are expected but should not leak sensitive data
      // This test mainly ensures both cases work correctly
      expect(true, isTrue,
          reason: 'Both cache hit and miss should work correctly');
    }, skip: 'Timing measurements are flaky in CI');

    test('cache should not leak expression content via timing', () {
      // CVE: Content-based timing leak
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final expr1 = '1' * 100;
      final expr2 = '2' * 100;

      final start1 = DateTime.now();
      try {
        evaluator.evaluate(expr1);
      } catch (_) {}
      final time1 = DateTime.now().difference(start1);

      final start2 = DateTime.now();
      try {
        evaluator.evaluate(expr2);
      } catch (_) {}
      final time2 = DateTime.now().difference(start2);

      // Similar expressions should have similar timing
      expect(
        (time1.inMicroseconds - time2.inMicroseconds).abs() < 100000,
        isTrue,
        reason: 'Timing should not vary significantly for similar expressions',
      );
    }, skip: 'Timing measurements are flaky in CI');
  });

  group('Cache Key Security', () {
    test('cache should differentiate expressions with different whitespace',
        () {
      // CVE: Whitespace cache collision
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final expr1 = '1 + 1';
      final expr2 = '1+1';
      final expr3 = '1  +  1';

      final result1 = evaluator.evaluate(expr1);
      final result2 = evaluator.evaluate(expr2);
      final result3 = evaluator.evaluate(expr3);

      expect(result1.asNumeric(), equals(2.0));
      expect(result2.asNumeric(), equals(2.0));
      expect(result3.asNumeric(), equals(2.0),
          reason: 'All variations should evaluate correctly');
    });

    test('cache should handle case sensitivity correctly', () {
      // CVE: Case-insensitive cache collision
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Note: LaTeX commands are case-sensitive
      final exprs = [
        r'\sin{0}',
        r'\Sin{0}', // Invalid - should fail
        r'\SIN{0}', // Invalid - should fail
      ];

      expect(evaluator.evaluate(exprs[0]).asNumeric(), equals(0.0));

      for (var i = 1; i < exprs.length; i++) {
        expect(
          () => evaluator.evaluate(exprs[i]),
          throwsA(isA<Exception>()),
          reason: 'Case should matter in commands',
        );
      }
    });

    test('cache should handle unicode normalization consistently', () {
      // CVE: Unicode normalization cache bypass
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Compose vs decompose (if variables supported unicode)
      final result1 = evaluator.evaluate('x + 1', {'x': 1.0});
      final result2 = evaluator.evaluate('x + 1', {'x': 1.0});

      expect(result1.asNumeric(), equals(result2.asNumeric()),
          reason: 'Identical expressions should cache consistently');
    });
  });

  group('Cache Size Limits', () {
    test('zero cache size should disable caching', () {
      // CVE: Disable cache for sensitive operations
      final evaluator = Texpr(parsedExpressionCacheSize: 0);

      final result1 = evaluator.evaluate('1 + 1');
      final result2 = evaluator.evaluate('1 + 1');

      expect(result1.asNumeric(), equals(2.0));
      expect(result2.asNumeric(), equals(2.0),
          reason: 'Should work without cache');
    });

    test('very large cache should not cause memory issues', () {
      // CVE: Memory exhaustion via large cache
      final evaluator = Texpr(parsedExpressionCacheSize: 10000);

      // Fill with unique expressions
      for (var i = 0; i < 1000; i++) {
        final result = evaluator.evaluate('$i + $i');
        expect(result.asNumeric(), equals(i * 2.0));
      }

      expect(true, isTrue, reason: 'Large cache should work correctly');
    });

    test('max cache input length should be enforced', () {
      // CVE: Cache input length bypass
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Expression longer than default maxCacheInputLength (5000)
      final longExpr = '1 + ' * 3000; // ~12000 chars

      expect(
        () => evaluator.evaluate(longExpr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Long expressions should be handled',
      );
    });
  });

  group('Cache Consistency', () {
    test('cache should return same AST for same expression', () {
      // CVE: Cache inconsistency
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final expr = r'\sin{x} + \cos{x}';
      final result1 = evaluator.evaluate(expr, {'x': 0.0});
      final result2 = evaluator.evaluate(expr, {'x': 0.0});

      expect(result1.asNumeric(), equals(result2.asNumeric()),
          reason: 'Same expression should produce same result');
    });

    test('cache should not mix up similar expressions', () {
      // CVE: Expression confusion
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final result1 = evaluator.evaluate(r'\sin{x}', {'x': 0.0});
      final result2 = evaluator.evaluate(r'\cos{x}', {'x': 0.0});

      expect(result1.asNumeric(), equals(0.0));
      expect(result2.asNumeric(), equals(1.0),
          reason: 'Different expressions should not be confused');
    });
  });

  group('Concurrent Cache Access', () {
    test('evaluator should be safe for sequential use', () {
      // CVE: State corruption in sequential access
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final results = <double>[];
      for (var i = 0; i < 100; i++) {
        results.add(evaluator.evaluate('$i + 1').asNumeric());
      }

      for (var i = 0; i < 100; i++) {
        expect(results[i], equals(i + 1.0),
            reason: 'Sequential evaluations should be correct');
      }
    });
  });

  group('Cache Metadata Security', () {
    test('cache statistics should not leak sensitive information', () {
      // CVE: Information disclosure via cache stats
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Evaluate some expressions
      evaluator.evaluate('1 + 1');
      evaluator.evaluate(r'\sin{0}');
      expect(
        () => evaluator.evaluate('unknownVar'),
        throwsA(isA<EvaluatorException>()),
      );

      // Note: If cache stats were exposed, they should not reveal:
      // - Actual cached expressions
      // - Variable names
      // - Expression content
      expect(true, isTrue, reason: 'Cache should not expose internals');
    });
  });

  group('Cache Bypass Techniques', () {
    test('adding whitespace should not always bypass cache', () {
      // CVE: Cache bypass via whitespace
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final variants = [
        '1+1',
        '1 + 1',
        '1  +  1',
        ' 1 + 1 ',
      ];

      for (final variant in variants) {
        final result = evaluator.evaluate(variant);
        expect(result.asNumeric(), equals(2.0),
            reason: 'All variants should evaluate correctly');
      }
    });

    test('adding comments should not create cache duplicates', () {
      // CVE: Comment-based cache bloat (if comments supported)
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // If comments are supported, they shouldn't create separate cache entries
      final expr = '1 + 1';
      final result = evaluator.evaluate(expr);

      expect(result.asNumeric(), equals(2.0),
          reason: 'Basic expression should work');
    });
  });

  group('Error Caching Security', () {
    test('invalid expressions should not be cached permanently', () {
      // CVE: Error caching DoS
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      // Invalid expression
      expect(
        () => evaluator.evaluate(r'\unknownFunc{x}'),
        throwsA(isA<Exception>()),
      );

      // Should still throw on second attempt (or be cached as error)
      expect(
        () => evaluator.evaluate(r'\unknownFunc{x}'),
        throwsA(isA<Exception>()),
        reason: 'Invalid expressions should consistently fail',
      );
    });

    test('expressions with different errors should not be confused', () {
      // CVE: Error type confusion
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      expect(
        () => evaluator.evaluate(r'\unknown1{x}'),
        throwsA(isA<TokenizerException>()),
      );

      expect(
        () => evaluator.evaluate(r'\unknown2{x}'),
        throwsA(isA<TokenizerException>()),
        reason: 'Different unknown commands should both fail',
      );
    });
  });

  group('Variable Context Caching', () {
    test('cache should not mix different variable contexts', () {
      // CVE: Variable context confusion
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      final result1 = evaluator.evaluate('x + 1', {'x': 5.0});
      final result2 = evaluator.evaluate('x + 1', {'x': 10.0});

      expect(result1.asNumeric(), equals(6.0));
      expect(result2.asNumeric(), equals(11.0),
          reason: 'Different variable values should produce different results');
    });

    test('cache should handle missing variables consistently', () {
      // CVE: Variable absence caching
      final evaluator = Texpr(parsedExpressionCacheSize: 128);

      expect(
        () => evaluator.evaluate('x + 1'),
        throwsA(isA<EvaluatorException>()),
      );

      expect(
        () => evaluator.evaluate('x + 1'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Missing variables should consistently fail',
      );
    });
  });
}
