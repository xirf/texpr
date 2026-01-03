import 'dart:convert';
import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Tests for JSON AST export functionality.
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('JSON AST Export', () {
    group('Basic Expressions', () {
      test('NumberLiteral', () {
        final expr = evaluator.parse('42');
        final json = expr.toJson();

        expect(json['type'], 'NumberLiteral');
        expect(json['value'], 42.0);
      });

      test('Variable', () {
        final expr = evaluator.parse('x');
        final json = expr.toJson();

        expect(json['type'], 'Variable');
        expect(json['name'], 'x');
      });

      test('negative number', () {
        final expr = evaluator.parse('-5');
        final json = expr.toJson();

        expect(json['type'], 'UnaryOp');
        expect(json['operator'], 'negate');
        expect(json['operand']['type'], 'NumberLiteral');
        expect(json['operand']['value'], 5.0);
      });
    });

    group('Binary Operations', () {
      test('addition', () {
        final expr = evaluator.parse('2 + 3');
        final json = expr.toJson();

        expect(json['type'], 'BinaryOp');
        expect(json['operator'], 'add');
        expect(json['left']['type'], 'NumberLiteral');
        expect(json['left']['value'], 2.0);
        expect(json['right']['type'], 'NumberLiteral');
        expect(json['right']['value'], 3.0);
      });

      test('subtraction', () {
        final expr = evaluator.parse('5 - 2');
        final json = expr.toJson();

        expect(json['type'], 'BinaryOp');
        expect(json['operator'], 'subtract');
      });

      test('multiplication', () {
        final expr = evaluator.parse(r'3 \times 4');
        final json = expr.toJson();

        expect(json['type'], 'BinaryOp');
        expect(json['operator'], 'multiply');
      });

      test('division as fraction', () {
        final expr = evaluator.parse(r'\frac{10}{2}');
        final json = expr.toJson();

        expect(json['type'], 'BinaryOp');
        expect(json['operator'], 'divide');
      });

      test('power', () {
        final expr = evaluator.parse('x^{2}');
        final json = expr.toJson();

        expect(json['type'], 'BinaryOp');
        expect(json['operator'], 'power');
        expect(json['left']['name'], 'x');
        expect(json['right']['value'], 2.0);
      });

      test('nested expression', () {
        final expr = evaluator.parse('(x + 1) * 2');
        final json = expr.toJson();

        expect(json['type'], 'BinaryOp');
        expect(json['operator'], 'multiply');
        expect(json['left']['type'], 'BinaryOp');
        expect(json['left']['operator'], 'add');
      });
    });

    group('Functions', () {
      test('simple function', () {
        final expr = evaluator.parse(r'\sin{x}');
        final json = expr.toJson();

        expect(json['type'], 'FunctionCall');
        expect(json['name'], 'sin');
        expect(json['args'], isList);
        expect(json['args'][0]['type'], 'Variable');
        expect(json['args'][0]['name'], 'x');
      });

      test('function with multiple args', () {
        final expr = evaluator.parse(r'f(x, y)');
        final json = expr.toJson();

        expect(json['type'], 'FunctionCall');
        expect(json['args'].length, 2);
      });

      test('log with base', () {
        final expr = evaluator.parse(r'\log_{2}{8}');
        final json = expr.toJson();

        expect(json['type'], 'FunctionCall');
        expect(json['name'], 'log');
        expect(json['base'], isNotNull);
        expect(json['base']['value'], 2.0);
      });

      test('sqrt with optional param', () {
        final expr = evaluator.parse(r'\sqrt[3]{27}');
        final json = expr.toJson();

        expect(json['type'], 'FunctionCall');
        expect(json['name'], 'sqrt');
        expect(json['optionalParam'], isNotNull);
        expect(json['optionalParam']['value'], 3.0);
      });

      test('absolute value', () {
        final expr = evaluator.parse(r'|x|');
        final json = expr.toJson();

        expect(json['type'], 'AbsoluteValue');
        expect(json['argument']['type'], 'Variable');
      });
    });

    group('Calculus', () {
      test('summation', () {
        final expr = evaluator.parse(r'\sum_{i=1}^{10} i');
        final json = expr.toJson();

        expect(json['type'], 'SumExpr');
        expect(json['variable'], 'i');
        expect(json['start']['value'], 1.0);
        expect(json['end']['value'], 10.0);
        expect(json['body']['type'], 'Variable');
      });

      test('product', () {
        final expr = evaluator.parse(r'\prod_{i=1}^{5} i');
        final json = expr.toJson();

        expect(json['type'], 'ProductExpr');
        expect(json['variable'], 'i');
      });

      test('limit', () {
        final expr = evaluator.parse(r'\lim_{x \to 0} x');
        final json = expr.toJson();

        expect(json['type'], 'LimitExpr');
        expect(json['variable'], 'x');
        expect(json['target']['value'], 0.0);
        expect(json['body']['type'], 'Variable');
      });

      test('definite integral', () {
        final expr = evaluator.parse(r'\int_{0}^{1} x dx');
        final json = expr.toJson();

        expect(json['type'], 'IntegralExpr');
        expect(json['variable'], 'x');
        expect(json['lower'], isNotNull);
        expect(json['upper'], isNotNull);
        expect(json['isClosed'], false);
      });

      test('indefinite integral', () {
        final expr = evaluator.parse(r'\int x dx');
        final json = expr.toJson();

        expect(json['type'], 'IntegralExpr');
        expect(json['lower'], isNull);
        expect(json['upper'], isNull);
      });

      test('derivative', () {
        final expr = evaluator.parse(r'\frac{d}{dx}(x^2)');
        final json = expr.toJson();

        expect(json['type'], 'DerivativeExpr');
        expect(json['variable'], 'x');
        expect(json['order'], 1);
      });

      test('second derivative', () {
        final expr = evaluator.parse(r'\frac{d^{2}}{dx^{2}}(x^3)');
        final json = expr.toJson();

        expect(json['type'], 'DerivativeExpr');
        expect(json['order'], 2);
      });

      test('partial derivative', () {
        final expr = evaluator.parse(r'\frac{\partial}{\partial x}(xy)');
        final json = expr.toJson();

        expect(json['type'], 'PartialDerivativeExpr');
        expect(json['variable'], 'x');
      });

      test('binomial coefficient', () {
        final expr = evaluator.parse(r'\binom{5}{2}');
        final json = expr.toJson();

        expect(json['type'], 'BinomExpr');
        expect(json['n']['value'], 5.0);
        expect(json['k']['value'], 2.0);
      });
    });

    group('Comparisons and Logic', () {
      test('simple comparison', () {
        final expr = evaluator.parse('x < 5');
        final json = expr.toJson();

        expect(json['type'], 'Comparison');
        expect(json['operator'], 'less');
        expect(json['left']['name'], 'x');
        expect(json['right']['value'], 5.0);
      });

      test('chained comparison', () {
        final expr = evaluator.parse('-1 < x < 1');
        final json = expr.toJson();

        expect(json['type'], 'ChainedComparison');
        expect(json['expressions'], isList);
        expect(json['operators'], isList);
        expect(json['expressions'].length, 3);
        expect(json['operators'].length, 2);
      });

      test('conditional expression', () {
        final expr = evaluator.parse(r'x^2, x > 0');
        final json = expr.toJson();

        expect(json['type'], 'ConditionalExpr');
        expect(json['expression']['type'], 'BinaryOp');
        expect(json['condition']['type'], 'Comparison');
      });

      test('piecewise expression', () {
        final expr = evaluator
            .parse(r'\begin{cases} x & x > 0 \\ -x & x \leq 0 \end{cases}');
        final json = expr.toJson();

        expect(json['type'], 'PiecewiseExpr');
        expect(json['cases'], isList);
        expect(json['cases'].length, 2);
        expect(json['cases'][0]['expression'], isNotNull);
        expect(json['cases'][0]['condition'], isNotNull);
      });
    });

    group('Matrix and Vector', () {
      test('matrix', () {
        final expr =
            evaluator.parse(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
        final json = expr.toJson();

        expect(json['type'], 'MatrixExpr');
        expect(json['rows'], isList);
        expect(json['rows'].length, 2);
        expect(json['rows'][0].length, 2);
        expect(json['rows'][0][0]['value'], 1.0);
        expect(json['rows'][1][1]['value'], 4.0);
      });

      test('vector', () {
        final expr = evaluator.parse(r'\vec{1, 2, 3}');
        final json = expr.toJson();

        expect(json['type'], 'VectorExpr');
        expect(json['components'], isList);
        expect(json['components'].length, 3);
        expect(json['isUnitVector'], false);
      });
    });

    group('JSON Serialization', () {
      test('can be encoded to JSON string', () {
        final expr = evaluator.parse(r'\frac{x^{2} + 1}{2}');
        final json = expr.toJson();
        final jsonString = jsonEncode(json);

        expect(jsonString, isA<String>());
        expect(jsonString.contains('"type"'), isTrue);
      });

      test('round-trip JSON encode/decode', () {
        final expr = evaluator.parse(r'\sin{x} + \cos{x}');
        final json = expr.toJson();
        final jsonString = jsonEncode(json);
        final decoded = jsonDecode(jsonString);

        expect(decoded['type'], json['type']);
        expect(decoded['operator'], json['operator']);
      });

      test('complex expression', () {
        final expr = evaluator.parse(r'\frac{-b + \sqrt{b^{2} - 4ac}}{2a}');
        final json = expr.toJson();

        // Should be parseable without error
        final jsonString = jsonEncode(json);
        expect(jsonString, isA<String>());
      });
    });
  });
}
