import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  group('Parsed expression caching', () {
    test('parse returns identical AST when cached', () {
      final evaluator = LatexMathEvaluator(parsedExpressionCacheSize: 16);
      final expr = r'x^{2} + 2x + 1';

      final ast1 = evaluator.parse(expr);
      final ast2 = evaluator.parse(expr);

      expect(identical(ast1, ast2), isTrue);
    });

    test('parse returns different AST when caching disabled', () {
      final evaluator = LatexMathEvaluator(parsedExpressionCacheSize: 0);
      final expr = r'2 + 3';

      final ast1 = evaluator.parse(expr);
      final ast2 = evaluator.parse(expr);

      expect(identical(ast1, ast2), isFalse);
    });

    test('evaluate reuses cached parse result', () {
      final evaluator = LatexMathEvaluator(parsedExpressionCacheSize: 8);
      final expr = r'x^{2} + 1';

      final r1 = evaluator.evaluate(expr, {'x': 2}).asNumeric();
      final r2 = evaluator.evaluate(expr, {'x': 3}).asNumeric();

      expect(r1, 5.0);
      expect(r2, 10.0);
    });
  });
}
