import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Recursion Configuration', () {
    test('Default maxRecursionDepth is 500', () {
      final evaluator = Texpr();
      expect(evaluator.maxRecursionDepth, 500);
    });

    test('Can configure custom maxRecursionDepth', () {
      final evaluator = Texpr(maxRecursionDepth: 100);
      expect(evaluator.maxRecursionDepth, 100);
    });

    test('Low recursion limit prevents deep nesting', () {
      // Set a very low limit
      final evaluator = Texpr(maxRecursionDepth: 10);

      // Create an expression deeper than 10 levels
      // 1+(1+(1+(...)))
      final sb = StringBuffer();
      for (int i = 0; i < 20; i++) {
        sb.write('1+(');
      }
      sb.write('1');
      for (int i = 0; i < 20; i++) {
        sb.write(')');
      }
      final deepExpr = sb.toString();

      // Should fail parsing
      expect(
        () => evaluator.parse(deepExpr),
        throwsA(isA<ParserException>().having(
            (e) => e.message, 'message', contains('nesting depth exceeded'))),
      );
    });

    test('High recursion limit allows deep nesting', () {
      // Set a higher limit
      final evaluator = Texpr(maxRecursionDepth: 2000);

      // Create an expression deeper than default but within new limit
      final sb = StringBuffer();
      // 550 levels > default 500
      for (int i = 0; i < 550; i++) {
        sb.write('1+(');
      }
      sb.write('1');
      for (int i = 0; i < 550; i++) {
        sb.write(')');
      }
      final deepExpr = sb.toString();

      // Should succeed parsing
      expect(() => evaluator.parse(deepExpr), returnsNormally);

      // Should succeed evaluation
      // Note: evaluation also has depth checks
      expect(evaluator.evaluate(deepExpr).asNumeric(), isA<double>());
    }, timeout: const Timeout(Duration(seconds: 2)));
  });
}
