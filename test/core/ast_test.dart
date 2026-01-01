// ignore_for_file: unrelated_type_equality_checks

import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';

void main() {
  group('Expression base class', () {
    test('Expression can be instantiated through subclasses', () {
      final expr = NumberLiteral(5.0);
      expect(expr, isA<Expression>());
    });
  });

  group('NumberLiteral', () {
    test('creates a number literal with a value', () {
      final num = NumberLiteral(42.5);
      expect(num.value, equals(42.5));
    });

    test('toString returns correct format', () {
      final num = NumberLiteral(3.14);
      expect(num.toString(), equals('NumberLiteral(3.14)'));
    });

    test('equality works correctly', () {
      final num1 = NumberLiteral(10.0);
      final num2 = NumberLiteral(10.0);
      final num3 = NumberLiteral(20.0);

      expect(num1, equals(num2));
      expect(num1, isNot(equals(num3)));
      expect(num1 == num1, isTrue); // identical
    });

    test('hashCode is consistent', () {
      final num1 = NumberLiteral(5.0);
      final num2 = NumberLiteral(5.0);
      final num3 = NumberLiteral(10.0);

      expect(num1.hashCode, equals(num2.hashCode));
      expect(num1.hashCode, isNot(equals(num3.hashCode)));
    });

    test('equality with different types returns false', () {
      final num = NumberLiteral(5.0);
      expect(num == 'not a number literal', isFalse);
    });
  });

  group('Variable', () {
    test('creates a variable with a name', () {
      final variable = Variable('x');
      expect(variable.name, equals('x'));
    });

    test('toString returns correct format', () {
      final variable = Variable('alpha');
      expect(variable.toString(), equals('Variable(alpha)'));
    });

    test('equality works correctly', () {
      final var1 = Variable('x');
      final var2 = Variable('x');
      final var3 = Variable('y');

      expect(var1, equals(var2));
      expect(var1, isNot(equals(var3)));
      expect(var1 == var1, isTrue); // identical
    });

    test('hashCode is consistent', () {
      final var1 = Variable('x');
      final var2 = Variable('x');
      final var3 = Variable('y');

      expect(var1.hashCode, equals(var2.hashCode));
      expect(var1.hashCode, isNot(equals(var3.hashCode)));
    });

    test('equality with different types returns false', () {
      final variable = Variable('x');
      expect(variable == 'not a variable', isFalse);
    });
  });

  group('BinaryOp', () {
    test('creates a binary operation', () {
      final left = NumberLiteral(5.0);
      final right = NumberLiteral(3.0);
      final op = BinaryOp(left, BinaryOperator.add, right);

      expect(op.left, equals(left));
      expect(op.operator, equals(BinaryOperator.add));
      expect(op.right, equals(right));
      expect(op.sourceToken, isNull);
    });

    test('creates a binary operation with source token', () {
      final left = NumberLiteral(2.0);
      final right = NumberLiteral(3.0);
      final op = BinaryOp(left, BinaryOperator.multiply, right,
          sourceToken: r'\times');

      expect(op.sourceToken, equals(r'\times'));
    });

    test('toString returns correct format', () {
      final op = BinaryOp(
        NumberLiteral(1.0),
        BinaryOperator.subtract,
        NumberLiteral(2.0),
      );
      expect(op.toString(), contains('BinaryOp'));
      expect(op.toString(), contains('subtract'));
    });

    test('equality works correctly', () {
      final op1 = BinaryOp(
        NumberLiteral(1.0),
        BinaryOperator.add,
        NumberLiteral(2.0),
      );
      final op2 = BinaryOp(
        NumberLiteral(1.0),
        BinaryOperator.add,
        NumberLiteral(2.0),
      );
      final op3 = BinaryOp(
        NumberLiteral(1.0),
        BinaryOperator.multiply,
        NumberLiteral(2.0),
      );

      expect(op1, equals(op2));
      expect(op1, isNot(equals(op3)));
    });

    test('equality with source token', () {
      final op1 = BinaryOp(
        NumberLiteral(1.0),
        BinaryOperator.multiply,
        NumberLiteral(2.0),
        sourceToken: r'\times',
      );
      final op2 = BinaryOp(
        NumberLiteral(1.0),
        BinaryOperator.multiply,
        NumberLiteral(2.0),
        sourceToken: r'\times',
      );
      final op3 = BinaryOp(
        NumberLiteral(1.0),
        BinaryOperator.multiply,
        NumberLiteral(2.0),
        sourceToken: r'\cdot',
      );

      expect(op1, equals(op2));
      expect(op1, isNot(equals(op3)));
    });

    test('hashCode is consistent', () {
      final op1 = BinaryOp(
        NumberLiteral(5.0),
        BinaryOperator.divide,
        NumberLiteral(2.0),
      );
      final op2 = BinaryOp(
        NumberLiteral(5.0),
        BinaryOperator.divide,
        NumberLiteral(2.0),
      );

      expect(op1.hashCode, equals(op2.hashCode));
    });

    test('all binary operators can be used', () {
      final left = NumberLiteral(1.0);
      final right = NumberLiteral(2.0);

      final add = BinaryOp(left, BinaryOperator.add, right);
      final subtract = BinaryOp(left, BinaryOperator.subtract, right);
      final multiply = BinaryOp(left, BinaryOperator.multiply, right);
      final divide = BinaryOp(left, BinaryOperator.divide, right);
      final power = BinaryOp(left, BinaryOperator.power, right);

      expect(add.operator, equals(BinaryOperator.add));
      expect(subtract.operator, equals(BinaryOperator.subtract));
      expect(multiply.operator, equals(BinaryOperator.multiply));
      expect(divide.operator, equals(BinaryOperator.divide));
      expect(power.operator, equals(BinaryOperator.power));
    });
  });

  group('UnaryOp', () {
    test('creates a unary operation', () {
      final operand = NumberLiteral(5.0);
      final op = UnaryOp(UnaryOperator.negate, operand);

      expect(op.operator, equals(UnaryOperator.negate));
      expect(op.operand, equals(operand));
    });

    test('toString returns correct format', () {
      final op = UnaryOp(UnaryOperator.negate, NumberLiteral(3.0));
      expect(op.toString(), contains('UnaryOp'));
      expect(op.toString(), contains('negate'));
    });

    test('equality works correctly', () {
      final op1 = UnaryOp(UnaryOperator.negate, NumberLiteral(5.0));
      final op2 = UnaryOp(UnaryOperator.negate, NumberLiteral(5.0));
      final op3 = UnaryOp(UnaryOperator.negate, NumberLiteral(10.0));

      expect(op1, equals(op2));
      expect(op1, isNot(equals(op3)));
    });

    test('hashCode is consistent', () {
      final op1 = UnaryOp(UnaryOperator.negate, NumberLiteral(7.0));
      final op2 = UnaryOp(UnaryOperator.negate, NumberLiteral(7.0));

      expect(op1.hashCode, equals(op2.hashCode));
    });
  });

  group('AbsoluteValue', () {
    test('creates an absolute value expression', () {
      final arg = Variable('x');
      final abs = AbsoluteValue(arg);

      expect(abs.argument, equals(arg));
    });

    test('toString returns correct format', () {
      final abs = AbsoluteValue(NumberLiteral(-5.0));
      expect(abs.toString(), contains('AbsoluteValue'));
    });

    test('equality works correctly', () {
      final abs1 = AbsoluteValue(Variable('x'));
      final abs2 = AbsoluteValue(Variable('x'));
      final abs3 = AbsoluteValue(Variable('y'));

      expect(abs1, equals(abs2));
      expect(abs1, isNot(equals(abs3)));
    });

    test('hashCode is consistent', () {
      final abs1 = AbsoluteValue(NumberLiteral(3.0));
      final abs2 = AbsoluteValue(NumberLiteral(3.0));

      expect(abs1.hashCode, equals(abs2.hashCode));
    });
  });

  group('FunctionCall', () {
    test('creates a function call with single argument', () {
      final arg = Variable('x');
      final func = FunctionCall('sin', arg);

      expect(func.name, equals('sin'));
      expect(func.argument, equals(arg));
      expect(func.args.length, equals(1));
      expect(func.base, isNull);
      expect(func.optionalParam, isNull);
    });

    test('creates a function call with base', () {
      final arg = NumberLiteral(8.0);
      final base = NumberLiteral(2.0);
      final func = FunctionCall('log', arg, base: base);

      expect(func.name, equals('log'));
      expect(func.argument, equals(arg));
      expect(func.base, equals(base));
    });

    test('creates a function call with optional parameter', () {
      final arg = NumberLiteral(16.0);
      final param = NumberLiteral(4.0);
      final func = FunctionCall('sqrt', arg, optionalParam: param);

      expect(func.name, equals('sqrt'));
      expect(func.argument, equals(arg));
      expect(func.optionalParam, equals(param));
    });

    test('creates multivar function call', () {
      final args = [NumberLiteral(1.0), NumberLiteral(2.0), NumberLiteral(3.0)];
      final func = FunctionCall.multivar('max', args);

      expect(func.name, equals('max'));
      expect(func.args.length, equals(3));
      expect(func.args, equals(args));
    });

    test('toString returns correct format', () {
      final func = FunctionCall('cos', Variable('theta'));
      expect(func.toString(), contains('FunctionCall'));
      expect(func.toString(), contains('cos'));
    });

    test('toString with base', () {
      final func =
          FunctionCall('log', NumberLiteral(8.0), base: NumberLiteral(2.0));
      expect(func.toString(), contains('base'));
    });

    test('toString with optional parameter', () {
      final func = FunctionCall('sqrt', NumberLiteral(16.0),
          optionalParam: NumberLiteral(4.0));
      expect(func.toString(), contains('optionalParam'));
    });

    test('equality works correctly', () {
      final func1 = FunctionCall('sin', Variable('x'));
      final func2 = FunctionCall('sin', Variable('x'));
      final func3 = FunctionCall('cos', Variable('x'));

      expect(func1, equals(func2));
      expect(func1, isNot(equals(func3)));
    });

    test('equality with base', () {
      final func1 =
          FunctionCall('log', NumberLiteral(8.0), base: NumberLiteral(2.0));
      final func2 =
          FunctionCall('log', NumberLiteral(8.0), base: NumberLiteral(2.0));
      final func3 =
          FunctionCall('log', NumberLiteral(8.0), base: NumberLiteral(10.0));

      expect(func1, equals(func2));
      expect(func1, isNot(equals(func3)));
    });

    test('hashCode is consistent', () {
      final func1 = FunctionCall('tan', Variable('x'));
      final func2 = FunctionCall('tan', Variable('x'));

      expect(func1.hashCode, equals(func2.hashCode));
    });
  });

  group('LimitExpr', () {
    test('creates a limit expression', () {
      final limit = LimitExpr('x', NumberLiteral(0.0), Variable('x'));

      expect(limit.variable, equals('x'));
      expect(limit.target, equals(NumberLiteral(0.0)));
      expect(limit.body, equals(Variable('x')));
    });

    test('toString returns correct format', () {
      final limit = LimitExpr('x', NumberLiteral(0.0), Variable('x'));
      expect(limit.toString(), contains('LimitExpr'));
      expect(limit.toString(), contains('x'));
      expect(limit.toString(), contains('->'));
    });

    test('equality works correctly', () {
      final limit1 = LimitExpr('x', NumberLiteral(0.0), Variable('x'));
      final limit2 = LimitExpr('x', NumberLiteral(0.0), Variable('x'));
      final limit3 = LimitExpr('y', NumberLiteral(0.0), Variable('y'));

      expect(limit1, equals(limit2));
      expect(limit1, isNot(equals(limit3)));
    });

    test('hashCode is consistent', () {
      final limit1 = LimitExpr('x', NumberLiteral(1.0), Variable('x'));
      final limit2 = LimitExpr('x', NumberLiteral(1.0), Variable('x'));

      expect(limit1.hashCode, equals(limit2.hashCode));
    });
  });

  group('SumExpr', () {
    test('creates a summation expression', () {
      final sum = SumExpr(
        'i',
        NumberLiteral(1.0),
        NumberLiteral(10.0),
        Variable('i'),
      );

      expect(sum.variable, equals('i'));
      expect(sum.start, equals(NumberLiteral(1.0)));
      expect(sum.end, equals(NumberLiteral(10.0)));
      expect(sum.body, equals(Variable('i')));
    });

    test('toString returns correct format', () {
      final sum =
          SumExpr('i', NumberLiteral(1.0), NumberLiteral(5.0), Variable('i'));
      expect(sum.toString(), contains('SumExpr'));
      expect(sum.toString(), contains('i='));
      expect(sum.toString(), contains('to'));
    });

    test('equality works correctly', () {
      final sum1 =
          SumExpr('i', NumberLiteral(1.0), NumberLiteral(10.0), Variable('i'));
      final sum2 =
          SumExpr('i', NumberLiteral(1.0), NumberLiteral(10.0), Variable('i'));
      final sum3 =
          SumExpr('j', NumberLiteral(1.0), NumberLiteral(10.0), Variable('j'));

      expect(sum1, equals(sum2));
      expect(sum1, isNot(equals(sum3)));
    });

    test('hashCode is consistent', () {
      final sum1 =
          SumExpr('i', NumberLiteral(1.0), NumberLiteral(5.0), Variable('i'));
      final sum2 =
          SumExpr('i', NumberLiteral(1.0), NumberLiteral(5.0), Variable('i'));

      expect(sum1.hashCode, equals(sum2.hashCode));
    });
  });

  group('ProductExpr', () {
    test('creates a product expression', () {
      final product = ProductExpr(
        'i',
        NumberLiteral(1.0),
        NumberLiteral(5.0),
        Variable('i'),
      );

      expect(product.variable, equals('i'));
      expect(product.start, equals(NumberLiteral(1.0)));
      expect(product.end, equals(NumberLiteral(5.0)));
      expect(product.body, equals(Variable('i')));
    });

    test('toString returns correct format', () {
      final product = ProductExpr(
          'i', NumberLiteral(1.0), NumberLiteral(3.0), Variable('i'));
      expect(product.toString(), contains('ProductExpr'));
      expect(product.toString(), contains('i='));
      expect(product.toString(), contains('to'));
    });

    test('equality works correctly', () {
      final prod1 = ProductExpr(
          'i', NumberLiteral(1.0), NumberLiteral(5.0), Variable('i'));
      final prod2 = ProductExpr(
          'i', NumberLiteral(1.0), NumberLiteral(5.0), Variable('i'));
      final prod3 = ProductExpr(
          'i', NumberLiteral(2.0), NumberLiteral(5.0), Variable('i'));

      expect(prod1, equals(prod2));
      expect(prod1, isNot(equals(prod3)));
    });

    test('hashCode is consistent', () {
      final prod1 = ProductExpr(
          'i', NumberLiteral(1.0), NumberLiteral(4.0), Variable('i'));
      final prod2 = ProductExpr(
          'i', NumberLiteral(1.0), NumberLiteral(4.0), Variable('i'));

      expect(prod1.hashCode, equals(prod2.hashCode));
    });
  });

  group('IntegralExpr', () {
    test('creates an integral expression', () {
      final integral = IntegralExpr(
        NumberLiteral(0.0),
        NumberLiteral(1.0),
        Variable('x'),
        'x',
      );

      expect(integral.lower, equals(NumberLiteral(0.0)));
      expect(integral.upper, equals(NumberLiteral(1.0)));
      expect(integral.body, equals(Variable('x')));
      expect(integral.variable, equals('x'));
    });

    test('toString returns correct format', () {
      final integral = IntegralExpr(
        NumberLiteral(0.0),
        NumberLiteral(1.0),
        Variable('x'),
        'x',
      );
      expect(integral.toString(), contains('IntegralExpr'));
      expect(integral.toString(), contains('to'));
      expect(integral.toString(), contains('dx'));
    });

    test('equality works correctly', () {
      final int1 = IntegralExpr(
          NumberLiteral(0.0), NumberLiteral(1.0), Variable('x'), 'x');
      final int2 = IntegralExpr(
          NumberLiteral(0.0), NumberLiteral(1.0), Variable('x'), 'x');
      final int3 = IntegralExpr(
          NumberLiteral(0.0), NumberLiteral(2.0), Variable('x'), 'x');

      expect(int1, equals(int2));
      expect(int1, isNot(equals(int3)));
    });

    test('hashCode is consistent', () {
      final int1 = IntegralExpr(
          NumberLiteral(0.0), NumberLiteral(1.0), Variable('x'), 'x');
      final int2 = IntegralExpr(
          NumberLiteral(0.0), NumberLiteral(1.0), Variable('x'), 'x');

      expect(int1.hashCode, equals(int2.hashCode));
    });
  });

  group('DerivativeExpr', () {
    test('creates a first-order derivative', () {
      final deriv = DerivativeExpr(Variable('x'), 'x');

      expect(deriv.body, equals(Variable('x')));
      expect(deriv.variable, equals('x'));
      expect(deriv.order, equals(1));
    });

    test('creates a higher-order derivative', () {
      final deriv = DerivativeExpr(Variable('x'), 'x', order: 3);

      expect(deriv.order, equals(3));
    });

    test('toString for first-order derivative', () {
      final deriv = DerivativeExpr(Variable('x'), 'x');
      expect(deriv.toString(), contains('DerivativeExpr'));
      expect(deriv.toString(), contains('d/dx'));
    });

    test('toString for higher-order derivative', () {
      final deriv = DerivativeExpr(Variable('x'), 'x', order: 2);
      expect(deriv.toString(), contains('d^2'));
      expect(deriv.toString(), contains('dx^2'));
    });

    test('equality works correctly', () {
      final deriv1 = DerivativeExpr(Variable('x'), 'x');
      final deriv2 = DerivativeExpr(Variable('x'), 'x');
      final deriv3 = DerivativeExpr(Variable('x'), 'x', order: 2);

      expect(deriv1, equals(deriv2));
      expect(deriv1, isNot(equals(deriv3)));
    });

    test('hashCode is consistent', () {
      final deriv1 = DerivativeExpr(Variable('x'), 'x', order: 2);
      final deriv2 = DerivativeExpr(Variable('x'), 'x', order: 2);

      expect(deriv1.hashCode, equals(deriv2.hashCode));
    });
  });

  group('Comparison', () {
    test('creates a comparison expression', () {
      final comp = Comparison(
        NumberLiteral(1.0),
        ComparisonOperator.less,
        NumberLiteral(2.0),
      );

      expect(comp.left, equals(NumberLiteral(1.0)));
      expect(comp.operator, equals(ComparisonOperator.less));
      expect(comp.right, equals(NumberLiteral(2.0)));
    });

    test('toString returns correct format', () {
      final comp = Comparison(
        Variable('x'),
        ComparisonOperator.greater,
        NumberLiteral(0.0),
      );
      expect(comp.toString(), contains('Comparison'));
      expect(comp.toString(), contains('greater'));
    });

    test('all comparison operators can be used', () {
      final left = NumberLiteral(1.0);
      final right = NumberLiteral(2.0);

      final less = Comparison(left, ComparisonOperator.less, right);
      final greater = Comparison(left, ComparisonOperator.greater, right);
      final lessEqual = Comparison(left, ComparisonOperator.lessEqual, right);
      final greaterEqual =
          Comparison(left, ComparisonOperator.greaterEqual, right);
      final equal = Comparison(left, ComparisonOperator.equal, right);

      expect(less.operator, equals(ComparisonOperator.less));
      expect(greater.operator, equals(ComparisonOperator.greater));
      expect(lessEqual.operator, equals(ComparisonOperator.lessEqual));
      expect(greaterEqual.operator, equals(ComparisonOperator.greaterEqual));
      expect(equal.operator, equals(ComparisonOperator.equal));
    });

    test('equality works correctly', () {
      final comp1 = Comparison(
          Variable('x'), ComparisonOperator.less, NumberLiteral(5.0));
      final comp2 = Comparison(
          Variable('x'), ComparisonOperator.less, NumberLiteral(5.0));
      final comp3 = Comparison(
          Variable('x'), ComparisonOperator.greater, NumberLiteral(5.0));

      expect(comp1, equals(comp2));
      expect(comp1, isNot(equals(comp3)));
    });

    test('hashCode is consistent', () {
      final comp1 = Comparison(
          Variable('x'), ComparisonOperator.lessEqual, NumberLiteral(10.0));
      final comp2 = Comparison(
          Variable('x'), ComparisonOperator.lessEqual, NumberLiteral(10.0));

      expect(comp1.hashCode, equals(comp2.hashCode));
    });
  });

  group('ConditionalExpr', () {
    test('creates a conditional expression', () {
      final cond = ConditionalExpr(
        Variable('x'),
        Comparison(
            Variable('x'), ComparisonOperator.greater, NumberLiteral(0.0)),
      );

      expect(cond.expression, equals(Variable('x')));
      expect(cond.condition, isA<Comparison>());
    });

    test('toString returns correct format', () {
      final cond = ConditionalExpr(
        Variable('x'),
        Comparison(Variable('x'), ComparisonOperator.less, NumberLiteral(10.0)),
      );
      expect(cond.toString(), contains('ConditionalExpr'));
      expect(cond.toString(), contains('condition'));
    });

    test('equality works correctly', () {
      final cond1 = ConditionalExpr(
        Variable('x'),
        Comparison(
            Variable('x'), ComparisonOperator.greater, NumberLiteral(0.0)),
      );
      final cond2 = ConditionalExpr(
        Variable('x'),
        Comparison(
            Variable('x'), ComparisonOperator.greater, NumberLiteral(0.0)),
      );
      final cond3 = ConditionalExpr(
        Variable('y'),
        Comparison(
            Variable('y'), ComparisonOperator.greater, NumberLiteral(0.0)),
      );

      expect(cond1, equals(cond2));
      expect(cond1, isNot(equals(cond3)));
    });

    test('hashCode is consistent', () {
      final cond1 = ConditionalExpr(
        Variable('x'),
        Comparison(Variable('x'), ComparisonOperator.less, NumberLiteral(5.0)),
      );
      final cond2 = ConditionalExpr(
        Variable('x'),
        Comparison(Variable('x'), ComparisonOperator.less, NumberLiteral(5.0)),
      );

      expect(cond1.hashCode, equals(cond2.hashCode));
    });
  });

  group('ChainedComparison', () {
    test('creates a chained comparison', () {
      final chain = ChainedComparison(
        [NumberLiteral(-1.0), Variable('x'), NumberLiteral(1.0)],
        [ComparisonOperator.less, ComparisonOperator.less],
      );

      expect(chain.expressions.length, equals(3));
      expect(chain.operators.length, equals(2));
    });

    test('toString returns correct format', () {
      final chain = ChainedComparison(
        [NumberLiteral(0.0), Variable('x'), NumberLiteral(10.0)],
        [ComparisonOperator.lessEqual, ComparisonOperator.lessEqual],
      );
      expect(chain.toString(), contains('ChainedComparison'));
    });

    test('equality works correctly', () {
      final chain1 = ChainedComparison(
        [NumberLiteral(0.0), Variable('x'), NumberLiteral(10.0)],
        [ComparisonOperator.less, ComparisonOperator.less],
      );
      final chain2 = ChainedComparison(
        [NumberLiteral(0.0), Variable('x'), NumberLiteral(10.0)],
        [ComparisonOperator.less, ComparisonOperator.less],
      );
      final chain3 = ChainedComparison(
        [NumberLiteral(0.0), Variable('x'), NumberLiteral(5.0)],
        [ComparisonOperator.less, ComparisonOperator.less],
      );

      expect(chain1, equals(chain2));
      expect(chain1, isNot(equals(chain3)));
    });

    test('equality handles different expression lengths', () {
      final chain1 = ChainedComparison(
        [NumberLiteral(0.0), Variable('x')],
        [ComparisonOperator.less],
      );
      final chain2 = ChainedComparison(
        [NumberLiteral(0.0), Variable('x'), NumberLiteral(10.0)],
        [ComparisonOperator.less, ComparisonOperator.less],
      );

      expect(chain1, isNot(equals(chain2)));
    });

    test('equality handles different operator lengths', () {
      final chain1 = ChainedComparison(
        [NumberLiteral(0.0), Variable('x'), NumberLiteral(10.0)],
        [ComparisonOperator.less],
      );
      final chain2 = ChainedComparison(
        [NumberLiteral(0.0), Variable('x'), NumberLiteral(10.0)],
        [ComparisonOperator.less, ComparisonOperator.less],
      );

      expect(chain1, isNot(equals(chain2)));
    });
  });

  group('MatrixExpr', () {
    test('creates a matrix expression', () {
      final matrix = MatrixExpr([
        [NumberLiteral(1.0), NumberLiteral(2.0)],
        [NumberLiteral(3.0), NumberLiteral(4.0)],
      ]);

      expect(matrix.rows.length, equals(2));
      expect(matrix.rows[0].length, equals(2));
    });

    test('toString returns correct format', () {
      final matrix = MatrixExpr([
        [NumberLiteral(1.0), NumberLiteral(2.0)],
      ]);
      expect(matrix.toString(), contains('MatrixExpr'));
    });

    test('equality works correctly', () {
      final matrix1 = MatrixExpr([
        [NumberLiteral(1.0), NumberLiteral(2.0)],
        [NumberLiteral(3.0), NumberLiteral(4.0)],
      ]);
      final matrix2 = MatrixExpr([
        [NumberLiteral(1.0), NumberLiteral(2.0)],
        [NumberLiteral(3.0), NumberLiteral(4.0)],
      ]);
      final matrix3 = MatrixExpr([
        [NumberLiteral(1.0), NumberLiteral(0.0)],
        [NumberLiteral(0.0), NumberLiteral(1.0)],
      ]);

      expect(matrix1, equals(matrix2));
      expect(matrix1, isNot(equals(matrix3)));
    });

    test('hashCode is consistent', () {
      final matrix1 = MatrixExpr([
        [NumberLiteral(5.0), NumberLiteral(6.0)],
      ]);
      final matrix2 = MatrixExpr([
        [NumberLiteral(5.0), NumberLiteral(6.0)],
      ]);

      expect(matrix1.hashCode, equals(matrix2.hashCode));
    });

    test('equality handles different row counts', () {
      final matrix1 = MatrixExpr([
        [NumberLiteral(1.0)],
      ]);
      final matrix2 = MatrixExpr([
        [NumberLiteral(1.0)],
        [NumberLiteral(2.0)],
      ]);

      expect(matrix1, isNot(equals(matrix2)));
    });

    test('equality handles different column counts', () {
      final matrix1 = MatrixExpr([
        [NumberLiteral(1.0), NumberLiteral(2.0)],
      ]);
      final matrix2 = MatrixExpr([
        [NumberLiteral(1.0)],
      ]);

      expect(matrix1, isNot(equals(matrix2)));
    });
  });

  group('VectorExpr', () {
    test('creates a vector expression', () {
      final vector = VectorExpr([
        NumberLiteral(1.0),
        NumberLiteral(2.0),
        NumberLiteral(3.0),
      ]);

      expect(vector.components.length, equals(3));
      expect(vector.isUnitVector, isFalse);
    });

    test('creates a unit vector', () {
      final vector = VectorExpr(
        [NumberLiteral(1.0), NumberLiteral(0.0)],
        isUnitVector: true,
      );

      expect(vector.isUnitVector, isTrue);
    });

    test('toString for regular vector', () {
      final vector = VectorExpr([NumberLiteral(1.0), NumberLiteral(2.0)]);
      expect(vector.toString(), contains('VectorExpr'));
    });

    test('toString for unit vector', () {
      final vector = VectorExpr(
        [NumberLiteral(1.0), NumberLiteral(0.0)],
        isUnitVector: true,
      );
      expect(vector.toString(), contains('UnitVector'));
    });

    test('equality works correctly', () {
      final vec1 = VectorExpr([NumberLiteral(1.0), NumberLiteral(2.0)]);
      final vec2 = VectorExpr([NumberLiteral(1.0), NumberLiteral(2.0)]);
      final vec3 = VectorExpr([NumberLiteral(3.0), NumberLiteral(4.0)]);

      expect(vec1, equals(vec2));
      expect(vec1, isNot(equals(vec3)));
    });

    test('equality with unit vector flag', () {
      final vec1 = VectorExpr([NumberLiteral(1.0)], isUnitVector: true);
      final vec2 = VectorExpr([NumberLiteral(1.0)], isUnitVector: true);
      final vec3 = VectorExpr([NumberLiteral(1.0)], isUnitVector: false);

      expect(vec1, equals(vec2));
      expect(vec1, isNot(equals(vec3)));
    });

    test('hashCode is consistent', () {
      final vec1 = VectorExpr([NumberLiteral(5.0), NumberLiteral(6.0)]);
      final vec2 = VectorExpr([NumberLiteral(5.0), NumberLiteral(6.0)]);

      expect(vec1.hashCode, equals(vec2.hashCode));
    });

    test('equality handles different component counts', () {
      final vec1 = VectorExpr([NumberLiteral(1.0)]);
      final vec2 = VectorExpr([NumberLiteral(1.0), NumberLiteral(2.0)]);

      expect(vec1, isNot(equals(vec2)));
    });
  });
}
