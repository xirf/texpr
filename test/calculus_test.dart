import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  late Evaluator evaluator;

  setUp(() {
    evaluator = Evaluator();
  });

  group('Challenge 1: Quantum Mechanics (Calculus & Trigonometry)', () {
    test(
        'Expectation value of momentum (should be 0 for real wave function components)',
        () {
      // \int_{0}^{L} \left( \sqrt{\frac{2}{L}} \sin\left(\frac{n\pi x}{L}\right) \right) \left( -i\hbar \frac{d}{dx} \left( \sqrt{\frac{2}{L}} \sin\left(\frac{n\pi x}{L}\right) \right) \right) dx
      // Constants: L=1, n=1, hbar=1
      // Evaluates to Integral of -i * pi * sin(2*pi*x) from 0 to 1, which is 0.

      final variables = {
        'L': 1.0,
        'n': 1.0,
        'h': 1.0, // Represents hbar
        // 'i' is built-in
      };

      final expression = r'''
        \int_{0}^{L} \left( \sqrt{\frac{2}{L}} \sin\left(\frac{n\pi x}{L}\right) \right) \left( -i\hbar \frac{d}{dx} \left( \sqrt{\frac{2}{L}} \sin\left(\frac{n\pi x}{L}\right) \right) \right) dx
      ''';

      final ast = Parser(Tokenizer(expression).tokenize()).parse();
      final result = evaluator.evaluate(ast, variables);

      expect(result, isA<ComplexResult>());
      final complex = (result as ComplexResult).value;
      // Real part should be effectively 0
      expect(complex.real, closeTo(0, 1e-5));
      // Imaginary part should be effectively 0
      expect(complex.imaginary, closeTo(0, 1e-5));
    });
  });

  group('Challenge 2: Structural Engineering (Algebraic Manipulation)', () {
    test('Euler-Bernoulli Beam Equation', () {
      // w(x) = \frac{P L^3}{48 E I} \left[ 3 \frac{x}{L} - 4 \left( \frac{x}{L} \right)^3 \right]
      // P=48, L=1, E=1, I=1 => Coeff = 1
      // w(x) = 3x - 4x^3. At x=0.5: 1.5 - 0.5 = 1.0

      final variables = {
        'P': 48.0,
        'L': 1.0,
        'E': 1.0,
        'I': 1.0,
        'x': 0.5,
      };

      final expression = r'''
        \frac{P L^3}{48 E I} * ( 3 \frac{x}{L} - 4 ( \frac{x}{L} )^3 )
      ''';

      final ast = Parser(Tokenizer(expression).tokenize()).parse();
      final result = evaluator.evaluate(ast, variables);

      expect(result, isA<NumericResult>());
      expect((result as NumericResult).value, closeTo(1.0, 1e-9));
    });
  });

  group('Challenge 3: Data Science (Matrix Operations)', () {
    test('Transition Matrix Steady State (Power)', () {
      // P^2 = \begin{pmatrix} 0.8 & 0.1 & 0.1 \\ 0.2 & 0.7 & 0.1 \\ 0.3 & 0.3 & 0.4 \end{pmatrix} ^ 2
      // Expected Row 1 Col 1: 0.8*0.8 + 0.1*0.2 + 0.1*0.3 = 0.64 + 0.02 + 0.03 = 0.69

      final expression = r'''
        \begin{pmatrix} 0.8 & 0.1 & 0.1 \\ 0.2 & 0.7 & 0.1 \\ 0.3 & 0.3 & 0.4 \end{pmatrix} ^ 2
      ''';

      final ast = Parser(Tokenizer(expression).tokenize()).parse();
      final result = evaluator.evaluate(ast);

      expect(result, isA<MatrixResult>());
      final matrix = (result as MatrixResult).matrix;
      expect(matrix[0][0], closeTo(0.69, 1e-9));
    });
  });

  group('Challenge 4: Relativistic Physics', () {
    test('Lorentz Factor', () {
      // \gamma = \frac{1}{\sqrt{1 - \frac{v^2}{c^2}}}
      // v = 0.6c => v/c = 0.6 => v^2/c^2 = 0.36
      // 1 - 0.36 = 0.64. sqrt(0.64) = 0.8. 1/0.8 = 1.25

      final variables = {
        'v': 0.6,
        'c': 1.0,
      };

      final expression = r'''
        \frac{1}{\sqrt{1 - \frac{v^2}{c^2}}}
      ''';

      final ast = Parser(Tokenizer(expression).tokenize()).parse();
      final result = evaluator.evaluate(ast, variables);

      expect(result, isA<NumericResult>());
      expect((result as NumericResult).value, closeTo(1.25, 1e-9));
    });
  });

  group('Challenge 5: Calculus (Definite Integral)', () {
    test('Gaussian Integral', () {
      // \frac{1}{\sigma \sqrt{2\pi}} \int_{-\infty}^{\infty} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2} dx
      // sigma=1, mu=0.
      // \frac{1}{\sqrt{2\pi}} \int_{-\infty}^{\infty} e^{-0.5 x^2} dx
      // Should be 1.0

      final variables = {
        'sigma': 1.0,
        'mu': 0.0,
        'pi': 3.14159265359,
      };

      final expression = r'''
        \frac{1}{\sigma \sqrt{2\pi}} \int_{-\infty}^{\infty} e^{-\frac{1}{2}(\frac{x-\mu}{\sigma})^2} dx
      ''';

      final ast = Parser(Tokenizer(expression).tokenize()).parse();
      final result = evaluator.evaluate(ast, variables);

      expect(result, isA<NumericResult>());
      expect((result as NumericResult).value,
          closeTo(1.0, 1e-2)); // Numeric integration with large bounds
    });
  });

  group('Limit at Infinity (Known Limitation)', () {
    test('limit at infinity evaluates at large numbers', () {
      // Documents that lim_{x→∞} uses large finite values (1e2, 1e4, 1e6, 1e8)
      // See KNOWN_ISSUES.md: "Infinity Approximation in Calculus Operations"
      final expression = r'\lim_{x \to \infty} \frac{1}{x}';

      final ast = Parser(Tokenizer(expression).tokenize()).parse();
      final result = evaluator.evaluate(ast);

      // Should approach 0, evaluated at x = 1e8 (the largest step)
      // Result: 1/1e8 = 1e-8
      expect(result, isA<NumericResult>());
      expect((result as NumericResult).value, closeTo(0, 1e-7));
    });

    test('limit at infinity works for polynomial ratios', () {
      // lim_{x→∞} (2x+1)/(x+3) = 2 (degrees equal, ratio of leading coefficients)
      final expression = r'\lim_{x \to \infty} \frac{2x+1}{x+3}';

      final ast = Parser(Tokenizer(expression).tokenize()).parse();
      final result = evaluator.evaluate(ast);

      expect(result, isA<NumericResult>());
      // At x=1e8: (2*1e8+1)/(1e8+3) ≈ 2
      expect((result as NumericResult).value, closeTo(2.0, 0.01));
    });
  });
}
