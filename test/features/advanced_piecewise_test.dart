import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Advanced Piecewise Tests', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Complex Conditions', () {
      test('cases with logical AND', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            1 & x > 0 \land x < 10 \\
            0 & \text{otherwise}
          \end{cases}
        ''');

        expect(evaluator.evaluateParsed(expr, {'x': 5}).asNumeric(), 1.0);
        expect(evaluator.evaluateParsed(expr, {'x': 15}).asNumeric(), 0.0);
        expect(evaluator.evaluateParsed(expr, {'x': -5}).asNumeric(), 0.0);
      });

      test('cases with logical OR', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            1 & x < 0 \lor x > 10 \\
            0 & \text{otherwise}
          \end{cases}
        ''');

        expect(evaluator.evaluateParsed(expr, {'x': -5}).asNumeric(), 1.0);
        expect(evaluator.evaluateParsed(expr, {'x': 15}).asNumeric(), 1.0);
        expect(evaluator.evaluateParsed(expr, {'x': 5}).asNumeric(), 0.0);
      });

      test('cases with logical NOT', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            1 & \neg(x > 0) \\
            2 & x > 0
          \end{cases}
        ''');

        expect(evaluator.evaluateParsed(expr, {'x': -5}).asNumeric(), 1.0);
        expect(evaluator.evaluateParsed(expr, {'x': 5}).asNumeric(), 2.0);
      });
    });

    group('Function Composition', () {
      test('piecewise inside standard function', () {
        final expr = evaluator.parse(r'''
          \sin(\begin{cases}
            0 & x < 0 \\
            \pi/2 & x \geq 0
          \end{cases})
        ''');

        // sin(0) = 0
        expect(evaluator.evaluateParsed(expr, {'x': -1}).asNumeric(),
            closeTo(0, 0.0001));
        // sin(pi/2) = 1
        expect(evaluator.evaluateParsed(expr, {'x': 1}).asNumeric(),
            closeTo(1, 0.0001));
      });

      test('piecewise inside sqrt', () {
        final expr = evaluator.parse(r'''
          \sqrt{\begin{cases}
            4 & x < 0 \\
            16 & x \geq 0
          \end{cases}}
        ''');

        expect(evaluator.evaluateParsed(expr, {'x': -1}).asNumeric(), 2.0);
        expect(evaluator.evaluateParsed(expr, {'x': 1}).asNumeric(), 4.0);
      });
    });

    group('Undefined Behavior', () {
      test('returns NaN when no case matches', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            1 & x > 0
          \end{cases}
        ''');

        final result = evaluator.evaluateParsed(expr, {'x': -1});
        expect(result.asNumeric().isNaN, isTrue);
      });
    });
  });
}
