import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('StepTrace', () {
    late Texpr texpr;

    setUp(() {
      texpr = Texpr();
    });

    group('Differentiation with steps', () {
      test('records power rule step', () {
        final result = texpr.differentiateWithSteps('x^3', 'x');

        expect(result.result.toLatex(), contains('x'));
        expect(result.hasSteps, isTrue);
        expect(
          result.steps.any((s) => s.type == StepType.differentiation),
          isTrue,
        );
        expect(
          result.steps.any((s) => s.ruleName == 'power_rule'),
          isTrue,
        );
      });

      test('records sum rule step', () {
        final result = texpr.differentiateWithSteps('x^2 + x', 'x');

        expect(result.hasSteps, isTrue);
        expect(
          result.steps.any((s) => s.ruleName == 'sum_rule'),
          isTrue,
        );
      });

      test('records product rule step', () {
        final result = texpr.differentiateWithSteps('x * sin(x)', 'x');

        expect(result.hasSteps, isTrue);
        expect(
          result.steps.any((s) => s.ruleName == 'product_rule'),
          isTrue,
        );
      });

      test('records chain rule for trig functions', () {
        final result = texpr.differentiateWithSteps('sin(x)', 'x');

        expect(result.hasSteps, isTrue);
        expect(
          result.steps
              .any((s) => s.ruleName?.startsWith('chain_rule') ?? false),
          isTrue,
        );
      });

      test('constant rule for numbers', () {
        final result = texpr.differentiateWithSteps('5', 'x');

        expect(result.result.toLatex(), equals('0'));
        expect(result.hasSteps, isTrue);
        expect(
          result.steps.any((s) => s.ruleName == 'constant_rule'),
          isTrue,
        );
      });
    });

    group('Polynomial expansion with steps', () {
      test('records binomial expansion step', () {
        final result = texpr.expandWithSteps(r'(x + 1)^{2}');

        expect(result.hasSteps, isTrue);
        expect(
          result.steps.any((s) => s.type == StepType.expansion),
          isTrue,
        );
        expect(
          result.steps.any((s) => s.ruleName == 'binomial_theorem'),
          isTrue,
        );
      });

      test('formats steps correctly', () {
        final result = texpr.expandWithSteps(r'(x + 1)^{2}');

        final formatted = result.formatSteps();
        expect(formatted, contains('[Expansion]'));
        expect(formatted, contains('Binomial theorem'));
      });
    });

    group('TracedResult', () {
      test('stepCount returns correct count', () {
        final result = texpr.differentiateWithSteps('x^2 + x + 1', 'x');
        expect(result.stepCount, greaterThan(0));
      });

      test('hasSteps is false for trivial cases', () {
        // Variable with no transformation
        final result = TracedResult.unchanged(const NumberLiteral(0));
        expect(result.hasSteps, isFalse);
        expect(result.stepCount, equals(0));
      });

      test('formatSteps with and without LaTeX', () {
        final result = texpr.differentiateWithSteps('x^3', 'x');

        final withLatex = result.formatSteps(includeLatex: true);
        expect(withLatex, contains('→'));

        final withoutLatex = result.formatSteps(includeLatex: false);
        expect(withoutLatex, isNot(contains('→')));
      });

      test('toString provides summary', () {
        final result = texpr.differentiateWithSteps('x^2', 'x');
        expect(result.toString(), contains('TracedResult'));
        expect(result.toString(), contains('steps'));
      });
    });

    group('Step', () {
      test('format includes type and description', () {
        final step = Step(
          type: StepType.differentiation,
          description: 'Power rule: d/dx(x^n) = n·x^(n-1)',
          before: BinaryOp(
            const Variable('x'),
            BinaryOperator.power,
            const NumberLiteral(3),
          ),
          after: BinaryOp(
            const NumberLiteral(3),
            BinaryOperator.multiply,
            BinaryOp(
              const Variable('x'),
              BinaryOperator.power,
              const NumberLiteral(2),
            ),
          ),
          ruleName: 'power_rule',
        );

        final formatted = step.format();
        expect(formatted, contains('[Differentiation]'));
        expect(formatted, contains('Power rule'));
        expect(formatted, contains('→'));
      });
    });

    group('StepType', () {
      test('has correct display names', () {
        expect(StepType.differentiation.displayName, equals('Differentiation'));
        expect(StepType.simplification.displayName, equals('Simplification'));
        expect(StepType.expansion.displayName, equals('Expansion'));
        expect(StepType.factorization.displayName, equals('Factorization'));
        expect(StepType.identity.displayName, equals('Identity'));
      });
    });
  });
}
