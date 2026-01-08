import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Tests for SymPy export functionality.
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('SymPy Export', () {
    group('Basic Expressions', () {
      test('NumberLiteral', () {
        final expr = evaluator.parse('42');
        expect(expr.toSymPy(), '42');
      });

      test('Variable', () {
        final expr = evaluator.parse('x');
        expect(expr.toSymPy(), 'x');
      });

      test('pi constant', () {
        final expr = evaluator.parse(r'\pi');
        expect(expr.toSymPy(), 'pi');
      });

      test('e constant', () {
        final expr = evaluator.parse('e');
        expect(expr.toSymPy(), 'E');
      });

      test('imaginary unit', () {
        // Note: standalone 'i' stays as 'i' to avoid conflict with loop variables
        // Use SymPy's I directly for imaginary operations
        final expr = evaluator.parse('i');
        expect(expr.toSymPy(), 'i');
      });

      test('infinity', () {
        final expr = evaluator.parse(r'\infty');
        expect(expr.toSymPy(), 'oo');
      });

      test('negative number', () {
        final expr = evaluator.parse('-5');
        expect(expr.toSymPy(), '-5');
      });
    });

    group('Binary Operations', () {
      test('addition', () {
        final expr = evaluator.parse('2 + 3');
        expect(expr.toSymPy(), '2 + 3');
      });

      test('subtraction', () {
        final expr = evaluator.parse('5 - 2');
        expect(expr.toSymPy(), '5 - 2');
      });

      test('multiplication', () {
        final expr = evaluator.parse(r'3 \times 4');
        expect(expr.toSymPy(), '3*4');
      });

      test('division', () {
        final expr = evaluator.parse(r'\frac{10}{2}');
        expect(expr.toSymPy(), '(10)/(2)');
      });

      test('power uses **', () {
        final expr = evaluator.parse('x^{2}');
        expect(expr.toSymPy(), 'x**2');
      });

      test('nested expression', () {
        final expr = evaluator.parse('(x + 1)^{2}');
        expect(expr.toSymPy(), '(x + 1)**2');
      });
    });

    group('Functions', () {
      test('sin', () {
        final expr = evaluator.parse(r'\sin{x}');
        expect(expr.toSymPy(), 'sin(x)');
      });

      test('cos', () {
        final expr = evaluator.parse(r'\cos{x}');
        expect(expr.toSymPy(), 'cos(x)');
      });

      test('sqrt', () {
        final expr = evaluator.parse(r'\sqrt{x}');
        expect(expr.toSymPy(), 'sqrt(x)');
      });

      test('nth root uses root()', () {
        final expr = evaluator.parse(r'\sqrt[3]{x}');
        expect(expr.toSymPy(), 'root(x, 3)');
      });

      test('natural log uses log()', () {
        final expr = evaluator.parse(r'\ln{x}');
        expect(expr.toSymPy(), 'log(x)');
      });

      test('log base 10', () {
        final expr = evaluator.parse(r'\log{x}');
        expect(expr.toSymPy(), 'log(x, 10)');
      });

      test('log with custom base', () {
        final expr = evaluator.parse(r'\log_{2}{x}');
        expect(expr.toSymPy(), 'log(x, 2)');
      });

      test('absolute value uses Abs()', () {
        final expr = evaluator.parse(r'|x|');
        expect(expr.toSymPy(), 'Abs(x)');
      });

      test('factorial', () {
        final expr = evaluator.parse(r'\factorial{5}');
        expect(expr.toSymPy(), 'factorial(5)');
      });

      test('ceiling uses ceiling()', () {
        final expr = evaluator.parse(r'\ceil{x}');
        expect(expr.toSymPy(), 'ceiling(x)');
      });
    });

    group('Calculus', () {
      test('summation uses Sum()', () {
        final expr = evaluator.parse(r'\sum_{i=1}^{10} i');
        expect(expr.toSymPy(), 'Sum(i, (i, 1, 10))');
      });

      test('product uses Product()', () {
        final expr = evaluator.parse(r'\prod_{i=1}^{5} i');
        expect(expr.toSymPy(), 'Product(i, (i, 1, 5))');
      });

      test('limit uses limit()', () {
        final expr = evaluator.parse(r'\lim_{x \to 0} x');
        expect(expr.toSymPy(), 'limit(x, x, 0)');
      });

      test('definite integral uses integrate()', () {
        final expr = evaluator.parse(r'\int_{0}^{1} x dx');
        expect(expr.toSymPy(), 'integrate(x, (x, 0, 1))');
      });

      test('indefinite integral', () {
        final expr = evaluator.parse(r'\int x^2 dx');
        expect(expr.toSymPy(), 'integrate(x**2, x)');
      });

      test('derivative uses diff()', () {
        final expr = evaluator.parse(r'\frac{d}{dx}(x^2)');
        expect(expr.toSymPy(), 'diff(x**2, x)');
      });

      test('second derivative', () {
        final expr = evaluator.parse(r'\frac{d^{2}}{dx^{2}}(x^3)');
        expect(expr.toSymPy(), 'diff(x**3, x, 2)');
      });

      test('binomial uses binomial()', () {
        final expr = evaluator.parse(r'\binom{5}{2}');
        expect(expr.toSymPy(), 'binomial(5, 2)');
      });
    });

    group('Matrix and Vector', () {
      test('matrix uses Matrix()', () {
        final expr =
            evaluator.parse(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
        expect(expr.toSymPy(), 'Matrix([[1, 2], [3, 4]])');
      });

      test('vector uses Matrix()', () {
        final expr = evaluator.parse(r'\vec{1, 2, 3}');
        expect(expr.toSymPy(), 'Matrix([[1, 2, 3]])');
      });
    });

    group('Piecewise', () {
      test('conditional uses Piecewise()', () {
        final expr = evaluator.parse(r'x^2, x > 0');
        expect(expr.toSymPy(), 'Piecewise((x**2, x > 0))');
      });

      test('piecewise function', () {
        final expr = evaluator
            .parse(r'\begin{cases} x & x > 0 \\ -x & x \leq 0 \end{cases}');
        expect(expr.toSymPy(), contains('Piecewise'));
        expect(expr.toSymPy(), contains('x > 0'));
        expect(expr.toSymPy(), contains('x <= 0'));
      });
    });

    group('Script Generation', () {
      test('generates complete script', () {
        final expr = evaluator.parse('x^{2} + 1');
        final script = expr.toSymPyScript();

        expect(script, contains('from sympy import *'));
        expect(script, contains("symbols('x')"));
        expect(script, contains('expr = '));
      });

      test('collects multiple variables', () {
        final expr = evaluator.parse('x + y + z');
        final script = expr.toSymPyScript();

        expect(script, contains("x, y, z = symbols('x y z')"));
      });

      test('excludes constants from variables', () {
        final expr = evaluator.parse(r'e^{i \pi}');
        final script = expr.toSymPyScript();

        // e, i, pi should not be in symbols declaration
        expect(script, isNot(contains("= symbols('e")));
        expect(script, isNot(contains("= symbols('i")));
        expect(script, isNot(contains("= symbols('pi")));
      });

      test('with custom variables', () {
        final expr = evaluator.parse('a*b');
        final script = expr.toSymPyScript(variables: ['a', 'b', 'c']);

        expect(script, contains("a, b, c = symbols('a b c')"));
      });
    });
  });
}
