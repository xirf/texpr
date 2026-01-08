import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';

void main() {
  group('Evaluability enum', () {
    test('has three values', () {
      expect(Evaluability.values.length, equals(3));
      expect(Evaluability.values, contains(Evaluability.numeric));
      expect(Evaluability.values, contains(Evaluability.symbolic));
      expect(Evaluability.values, contains(Evaluability.unevaluable));
    });
  });

  group('EvaluabilityVisitor', () {
    group('numeric expressions', () {
      test('NumberLiteral is numeric', () {
        final expr = NumberLiteral(42.0);
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('BinaryOp with literals is numeric', () {
        final expr = BinaryOp(
          NumberLiteral(2.0),
          BinaryOperator.add,
          NumberLiteral(3.0),
        );
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('UnaryOp with literal is numeric', () {
        final expr = UnaryOp(UnaryOperator.negate, NumberLiteral(5.0));
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('known constants are numeric', () {
        expect(
          Variable('pi').getEvaluability(),
          equals(Evaluability.numeric),
        );
        expect(
          Variable('e').getEvaluability(),
          equals(Evaluability.numeric),
        );
        expect(
          Variable('i').getEvaluability(),
          equals(Evaluability.numeric),
        );
        expect(
          Variable('π').getEvaluability(),
          equals(Evaluability.numeric),
        );
      });

      test('FunctionCall with numeric arg is numeric', () {
        final expr = FunctionCall('sin', NumberLiteral(0.0));
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('AbsoluteValue with numeric arg is numeric', () {
        final expr = AbsoluteValue(NumberLiteral(-5.0));
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('MatrixExpr with all literals is numeric', () {
        final expr = MatrixExpr([
          [NumberLiteral(1.0), NumberLiteral(2.0)],
          [NumberLiteral(3.0), NumberLiteral(4.0)],
        ]);
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('VectorExpr with all literals is numeric', () {
        final expr = VectorExpr([
          NumberLiteral(1.0),
          NumberLiteral(2.0),
          NumberLiteral(3.0),
        ]);
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('IntervalExpr with literals is numeric', () {
        final expr = IntervalExpr(NumberLiteral(0.0), NumberLiteral(1.0));
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });
    });

    group('unevaluable expressions', () {
      test('Variable without context is unevaluable', () {
        final expr = Variable('x');
        expect(expr.getEvaluability(), equals(Evaluability.unevaluable));
      });

      test('Variable with context becomes numeric', () {
        final expr = Variable('x');
        expect(expr.getEvaluability({'x'}), equals(Evaluability.numeric));
      });

      test('BinaryOp with undefined variable is unevaluable', () {
        final expr = BinaryOp(
          Variable('x'),
          BinaryOperator.add,
          NumberLiteral(1.0),
        );
        expect(expr.getEvaluability(), equals(Evaluability.unevaluable));
      });

      test('BinaryOp with defined variable is numeric', () {
        final expr = BinaryOp(
          Variable('x'),
          BinaryOperator.add,
          NumberLiteral(1.0),
        );
        expect(expr.getEvaluability({'x'}), equals(Evaluability.numeric));
      });
    });

    group('symbolic expressions', () {
      test('indefinite integral is symbolic', () {
        final expr = IntegralExpr(null, null, Variable('x'), 'x');
        expect(expr.getEvaluability(), equals(Evaluability.symbolic));
      });

      test('definite integral with bounds is numeric', () {
        final expr = IntegralExpr(
          NumberLiteral(0.0),
          NumberLiteral(1.0),
          Variable('x'),
          'x',
        );
        // x is bound by the integral variable
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('multi-integral is symbolic', () {
        final expr = MultiIntegralExpr(
          2,
          null, // lower bound
          null, // upper bound
          Variable('f'),
          ['x', 'y'],
        );
        expect(expr.getEvaluability(), equals(Evaluability.symbolic));
      });

      test('partial derivative of bare symbol is symbolic', () {
        final expr = PartialDerivativeExpr(Variable('f'), 'x');
        expect(expr.getEvaluability(), equals(Evaluability.symbolic));
      });

      test('gradient of bare symbol is symbolic', () {
        final expr = GradientExpr(Variable('f'));
        expect(expr.getEvaluability(), equals(Evaluability.symbolic));
      });

      test('gradient of concrete expression is evaluable', () {
        // ∇(x^2 + y^2) - if x and y are defined
        final expr = GradientExpr(
          BinaryOp(
            BinaryOp(Variable('x'), BinaryOperator.power, NumberLiteral(2.0)),
            BinaryOperator.add,
            BinaryOp(Variable('y'), BinaryOperator.power, NumberLiteral(2.0)),
          ),
        );
        expect(expr.getEvaluability({'x', 'y'}), equals(Evaluability.numeric));
      });
    });

    group('calculus expressions with bound variables', () {
      test('SumExpr binds its variable', () {
        // Σ_{i=1}^{10} i
        final expr = SumExpr(
          'i',
          NumberLiteral(1.0),
          NumberLiteral(10.0),
          Variable('i'),
        );
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('ProductExpr binds its variable', () {
        // Π_{i=1}^{5} i
        final expr = ProductExpr(
          'i',
          NumberLiteral(1.0),
          NumberLiteral(5.0),
          Variable('i'),
        );
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('LimitExpr binds its variable', () {
        // lim_{x→0} sin(x)/x
        final expr = LimitExpr(
          'x',
          NumberLiteral(0.0),
          BinaryOp(
            FunctionCall('sin', Variable('x')),
            BinaryOperator.divide,
            Variable('x'),
          ),
        );
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('DerivativeExpr binds its variable', () {
        // d/dx (x^2)
        final expr = DerivativeExpr(
          BinaryOp(Variable('x'), BinaryOperator.power, NumberLiteral(2.0)),
          'x',
        );
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });
    });

    group('combined evaluability', () {
      test('symbolic trumps unevaluable', () {
        // Indefinite integral with undefined variable in bounds (if any)
        // Actually simpler: combine symbolic + unevaluable
        final indefiniteIntegral = IntegralExpr(null, null, Variable('x'), 'x');
        expect(indefiniteIntegral.getEvaluability(),
            equals(Evaluability.symbolic));
      });

      test('unevaluable trumps numeric', () {
        final expr = BinaryOp(
          NumberLiteral(1.0),
          BinaryOperator.add,
          Variable('undefined'),
        );
        expect(expr.getEvaluability(), equals(Evaluability.unevaluable));
      });
    });

    group('piecewise and conditional', () {
      test('PiecewiseExpr with numeric cases is numeric', () {
        final expr = PiecewiseExpr([
          PiecewiseCase(
            NumberLiteral(1.0),
            Comparison(
                Variable('x'), ComparisonOperator.less, NumberLiteral(0.0)),
          ),
          PiecewiseCase(NumberLiteral(2.0), null),
        ]);
        expect(expr.getEvaluability({'x'}), equals(Evaluability.numeric));
      });

      test('ConditionalExpr propagates evaluability', () {
        final expr = ConditionalExpr(
          Variable('x'),
          Comparison(
              Variable('x'), ComparisonOperator.greater, NumberLiteral(0.0)),
        );
        expect(expr.getEvaluability(), equals(Evaluability.unevaluable));
        expect(expr.getEvaluability({'x'}), equals(Evaluability.numeric));
      });
    });

    group('environment expressions', () {
      test('AssignmentExpr evaluability depends on value', () {
        final expr = AssignmentExpr('y', NumberLiteral(5.0));
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });

      test('FunctionDefinitionExpr evaluability depends on body', () {
        // f(x) = x^2
        final expr = FunctionDefinitionExpr(
          'f',
          ['x'],
          BinaryOp(Variable('x'), BinaryOperator.power, NumberLiteral(2.0)),
        );
        expect(expr.getEvaluability(), equals(Evaluability.numeric));
      });
    });
  });
}
