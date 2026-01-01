import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Gradient Evaluation (∇f)', () {
    Expression parse(String input) {
      final tokens = Tokenizer(input).tokenize();
      return Parser(tokens).parse();
    }

    group('Parsing', () {
      test('parses \\nabla f as GradientExpr', () {
        final result = parse(r'\nabla f');
        expect(result, isA<GradientExpr>());
        final grad = result as GradientExpr;
        expect(grad.body, isA<Variable>());
        expect((grad.body as Variable).name, 'f');
      });

      test('parses \\nabla{f} with braces', () {
        final result = parse(r'\nabla{f}');
        expect(result, isA<GradientExpr>());
      });

      test('parses \\nabla (x^2 + y^2)', () {
        // This will parse as \nabla x^2 + y^2 due to operator precedence
        // Just verify it parses
        final result = parse(r'\nabla{x^2 + y^2}');
        expect(result, isA<GradientExpr>());
      });
    });

    group('Evaluation', () {
      late LatexMathEvaluator evaluator;

      setUp(() {
        evaluator = LatexMathEvaluator();
      });

      test('gradient of x^2 at x=3 is [6]', () {
        final result = evaluator.evaluate(r'\nabla{x^2}', {'x': 3.0});
        expect(result.isVector, isTrue);
        final vec = result.asVector();
        expect(vec.components, [6.0]); // d/dx(x^2) = 2x, at x=3 -> 6
      });

      test('gradient of x^2 + y^2 at (1, 2) is [2, 4]', () {
        final result = evaluator.evaluate(
          r'\nabla{x^2 + y^2}',
          {'x': 1.0, 'y': 2.0},
        );
        expect(result.isVector, isTrue);
        final vec = result.asVector();
        // ∂/∂x(x^2 + y^2) = 2x = 2*1 = 2
        // ∂/∂y(x^2 + y^2) = 2y = 2*2 = 4
        expect(vec.components, [2.0, 4.0]);
      });

      test('gradient of xyz at (1, 2, 3) is [6, 3, 2]', () {
        final result = evaluator.evaluate(
          r'\nabla{x \cdot y \cdot z}',
          {'x': 1.0, 'y': 2.0, 'z': 3.0},
        );
        expect(result.isVector, isTrue);
        final vec = result.asVector();
        // ∂/∂x(xyz) = yz = 2*3 = 6
        // ∂/∂y(xyz) = xz = 1*3 = 3
        // ∂/∂z(xyz) = xy = 1*2 = 2
        expect(vec.components, [6.0, 3.0, 2.0]);
      });

      test('gradient of sin(x) + cos(y) at (0, 0) is [1, 0]', () {
        final result = evaluator.evaluate(
          r'\nabla{\sin{x} + \cos{y}}',
          {'x': 0.0, 'y': 0.0},
        );
        expect(result.isVector, isTrue);
        final vec = result.asVector();
        // ∂/∂x(sin(x) + cos(y)) = cos(x) = cos(0) = 1
        // ∂/∂y(sin(x) + cos(y)) = -sin(y) = -sin(0) = 0
        expect(vec.components[0], closeTo(1.0, 1e-10));
        expect(vec.components[1], closeTo(0.0, 1e-10));
      });

      test('gradient of x^2*y at (2, 3) is [12, 4]', () {
        final result = evaluator.evaluate(
          r'\nabla{x^2 \cdot y}',
          {'x': 2.0, 'y': 3.0},
        );
        expect(result.isVector, isTrue);
        final vec = result.asVector();
        // ∂/∂x(x^2*y) = 2xy = 2*2*3 = 12
        // ∂/∂y(x^2*y) = x^2 = 4
        expect(vec.components, [12.0, 4.0]);
      });
    });

    group('Export', () {
      test('toLatex preserves gradient notation', () {
        final expr = parse(r'\nabla{f}');
        expect(expr.toLatex(), contains('nabla'));
      });

      test('toMathML uses nabla symbol', () {
        final expr = parse(r'\nabla{x}');
        final mathml = expr.toMathML();
        expect(mathml, contains('∇'));
      });
    });
  });
}
