import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Custom Environments', () {
    late Texpr texpr;

    setUp(() {
      texpr = Texpr();
    });

    test('parses and evaluates let assignment', () {
      final expr = texpr.parse(r'let x = 5');
      expect(expr, isA<AssignmentExpr>());

      final result = texpr.evaluateParsed(expr);
      expect(result.asNumeric(), 5.0);
    });

    test('assignments persist in environment', () {
      texpr.evaluateParsed(texpr.parse(r'let x = 10'));
      final result = texpr.evaluateParsed(texpr.parse('x + 5'));
      expect(result.asNumeric(), 15.0);
    });

    test('parses and evaluates function definition', () {
      final expr = texpr.parse(r'f(x) = x^2');
      expect(expr, isA<FunctionDefinitionExpr>());

      final result = texpr.evaluateParsed(expr);
      expect(result, isA<FunctionResult>());
    });

    test('function definition persistence check', () {
      // This checks if we can simply define it without error.
      expect(() => texpr.evaluateParsed(texpr.parse(r'g(x) = x + 1')),
          returnsNormally);
    });

    test('shadowing global variables', () {
      texpr.evaluateParsed(texpr.parse(r'let a = 100'));
      // Pass local variable that shadows global 'a'
      final result = texpr.evaluateParsed(texpr.parse('a'), {'a': 5.0});
      expect(result.asNumeric(), 5.0);

      // Global should remain unchanged
      final globalResult = texpr.evaluateParsed(texpr.parse('a'));
      expect(globalResult.asNumeric(), 100.0);
    });

    test('overwriting global variables', () {
      texpr.evaluateParsed(texpr.parse(r'let b = 1'));
      expect(texpr.evaluateParsed(texpr.parse('b')).asNumeric(), 1.0);

      texpr.evaluateParsed(texpr.parse(r'let b = 2'));
      expect(texpr.evaluateParsed(texpr.parse('b')).asNumeric(), 2.0);
    });

    test('clear environment', () {
      texpr.evaluateParsed(texpr.parse(r'let z = 99'));
      expect(texpr.evaluateParsed(texpr.parse('z')).asNumeric(), 99.0);

      texpr.clearEnvironment();
      expect(() => texpr.evaluateParsed(texpr.parse('z')),
          throwsA(isA<EvaluatorException>()));
    });
  });

  group('AST Visitors', () {
    test('assignment to logic string', () {
      final texpr = Texpr();
      final expr = texpr.parse(r'let x = 7');
      expect(expr, isA<AssignmentExpr>());
    });

    test('assignment to JSON', () {
      final texpr = Texpr();
      final expr = texpr.parse(r'let a = 1');
      final json = expr.toJson();
      expect(json['type'], 'AssignmentExpr');
      expect(json['variable'], 'a');
    });

    test('assignment to SymPy', () {
      final texpr = Texpr();
      final expr = texpr.parse(r'let b = 2');
      // Expect Eq(b, 2) (integer) instead of 2.0
      expect(expr.toSymPy(), contains('Eq(b, 2)'));
    });

    test('assignment to MathML', () {
      final texpr = Texpr();
      final expr = texpr.parse(r'let c = 3');
      final mathml = expr.toMathML(includeWrapper: false);
      // Expect 3 instead of 3.0
      expect(mathml, contains('<mi>c</mi><mo>=</mo><mn>3</mn>'));
    });
  });
}
