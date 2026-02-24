import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Compile-time evaluability annotation', () {
    test('parse annotates root node metadata', () {
      final texpr = Texpr();
      final expr = texpr.parse('x + 1');

      final info = expr.compileTimeEvaluabilityInfo;
      expect(info, isNotNull);
      expect(info!.evaluability, equals(Evaluability.unevaluable));
      expect(info.freeVariables, equals({'x'}));
    });

    test('parse annotates child nodes metadata', () {
      final texpr = Texpr();
      final expr = texpr.parse('x + 1') as BinaryOp;

      final leftInfo = expr.left.compileTimeEvaluabilityInfo;
      final rightInfo = expr.right.compileTimeEvaluabilityInfo;

      expect(leftInfo, isNotNull);
      expect(rightInfo, isNotNull);
      expect(leftInfo!.evaluability, equals(Evaluability.unevaluable));
      expect(leftInfo.freeVariables, equals({'x'}));
      expect(rightInfo!.evaluability, equals(Evaluability.numeric));
      expect(rightInfo.freeVariables, isEmpty);
    });

    test('getEvaluability uses compile-time metadata with context', () {
      final texpr = Texpr();
      final expr = texpr.parse('x + 1');

      expect(expr.getEvaluability(), equals(Evaluability.unevaluable));
      expect(expr.getEvaluability({'x'}), equals(Evaluability.numeric));
      expect(expr.getEvaluability({'y'}), equals(Evaluability.unevaluable));
    });

    test('symbolic classification is stable even with variable context', () {
      final texpr = Texpr();
      final expr = texpr.parse(r'\nabla f');

      final info = expr.compileTimeEvaluabilityInfo;
      expect(info, isNotNull);
      expect(info!.evaluability, equals(Evaluability.symbolic));
      expect(expr.getEvaluability({'f'}), equals(Evaluability.symbolic));
    });
  });
}
