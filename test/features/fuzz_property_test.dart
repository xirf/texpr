import 'dart:math' as math;

import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

String _num(math.Random r) {
  final value = (r.nextInt(41) - 20) + r.nextDouble();
  return value.toStringAsFixed(6);
}

String _expr(math.Random r, int depth) {
  if (depth <= 0) return _num(r);

  final choice = r.nextInt(6);
  switch (choice) {
    case 0:
      return '(${_expr(r, depth - 1)})';
    case 1:
      return '${_expr(r, depth - 1)} + ${_expr(r, depth - 1)}';
    case 2:
      return '${_expr(r, depth - 1)} - ${_expr(r, depth - 1)}';
    case 3:
      return '${_expr(r, depth - 1)} \\times ${_expr(r, depth - 1)}';
    case 4:
      final base = _expr(r, depth - 1);
      final exp = r.nextInt(6);
      return '$base^{$exp}';
    case 5:
    default:
      final inner = _expr(r, depth - 1);
      final funcs = <String>['sin', 'cos', 'tan', 'ln', 'abs'];
      final f = funcs[r.nextInt(funcs.length)];
      return '\\$f{$inner}';
  }
}

bool _isExpectedException(Object e) {
  return e is LatexMathException || e is StateError;
}

void main() {
  group('Property-based tests', () {
    test('commutativity of addition (within tolerance)', () {
      final evaluator = LatexMathEvaluator();
      final r = math.Random(1234);

      for (int i = 0; i < 200; i++) {
        final a = _num(r);
        final b = _num(r);
        final left = evaluator.evaluateNumeric('$a + $b');
        final right = evaluator.evaluateNumeric('$b + $a');
        expect(left, closeTo(right, 1e-9));
      }
    });

    test('commutativity of multiplication (within tolerance)', () {
      final evaluator = LatexMathEvaluator();
      final r = math.Random(5678);

      for (int i = 0; i < 200; i++) {
        final a = _num(r);
        final b = _num(r);
        final left = evaluator.evaluateNumeric('$a \\times $b');
        final right = evaluator.evaluateNumeric('$b \\times $a');
        expect(left, closeTo(right, 1e-9));
      }
    });

    test('associativity of addition (within tolerance)', () {
      final evaluator = LatexMathEvaluator();
      final r = math.Random(9012);

      for (int i = 0; i < 200; i++) {
        final a = _num(r);
        final b = _num(r);
        final c = _num(r);
        final left = evaluator.evaluateNumeric('(($a + $b) + $c)');
        final right = evaluator.evaluateNumeric('($a + ($b + $c))');
        expect(left, closeTo(right, 1e-9));
      }
    });

    test('associativity of multiplication (within tolerance)', () {
      final evaluator = LatexMathEvaluator();
      final r = math.Random(3456);

      for (int i = 0; i < 200; i++) {
        final a = _num(r);
        final b = _num(r);
        final c = _num(r);
        final left = evaluator.evaluateNumeric('(($a \\times $b) \\times $c)');
        final right = evaluator.evaluateNumeric('($a \\times ($b \\times $c))');
        expect(left, closeTo(right, 1e-9));
      }
    });
  });

  group('Fuzzing', () {
    test('random expressions do not crash', () {
      final evaluator = LatexMathEvaluator();
      final r = math.Random(424242);

      for (int i = 0; i < 500; i++) {
        final s = _expr(r, 3);
        try {
          final result = evaluator.evaluate(s);
          expect(result, isA<EvaluationResult>());
        } catch (e, st) {
          expect(
            _isExpectedException(e),
            isTrue,
            reason: 'Unexpected exception (${e.runtimeType}) for: $s\n$e\n$st',
          );
        }
      }
    });
  });
}
