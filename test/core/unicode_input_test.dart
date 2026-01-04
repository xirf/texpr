import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Unicode Input Support', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Tokenizer Unicode preprocessing', () {
      test('tokenizes π as pi constant', () {
        final tokens = Tokenizer('π').tokenize();
        expect(tokens.first.type, TokenType.constant);
        expect(tokens.first.value, 'pi');
      });

      test('tokenizes ∞ as infty', () {
        final tokens = Tokenizer('∞').tokenize();
        expect(tokens.first.type, TokenType.infty);
      });

      test('tokenizes √ as sqrt function', () {
        final tokens = Tokenizer('√{4}').tokenize();
        // sqrt is registered as TokenType.function in command registry
        expect(tokens.first.type, TokenType.function);
        expect(tokens.first.value, 'sqrt');
      });

      test('tokenizes ∑ as sum', () {
        final tokens = Tokenizer('∑').tokenize();
        expect(tokens.first.type, TokenType.sum);
      });

      test('tokenizes ∫ as integral', () {
        final tokens = Tokenizer('∫').tokenize();
        expect(tokens.first.type, TokenType.int);
      });

      test('tokenizes ∂ as partial', () {
        final tokens = Tokenizer('∂').tokenize();
        expect(tokens.first.type, TokenType.partial);
      });

      test('tokenizes ∇ as nabla', () {
        final tokens = Tokenizer('∇').tokenize();
        expect(tokens.first.type, TokenType.nabla);
      });

      test('tokenizes × as multiply', () {
        final tokens = Tokenizer('×').tokenize();
        expect(tokens.first.type, TokenType.multiply);
      });

      test('tokenizes ÷ as divide', () {
        final tokens = Tokenizer('÷').tokenize();
        expect(tokens.first.type, TokenType.divide);
      });

      test('tokenizes Greek letters as variables', () {
        // Note: Greek letters are parsed as TokenType.variable
        final alphaTokens = Tokenizer('α').tokenize();
        expect(alphaTokens.first.type, TokenType.variable);
        expect(alphaTokens.first.value, 'alpha');

        final betaTokens = Tokenizer('β').tokenize();
        expect(betaTokens.first.type, TokenType.variable);
        expect(betaTokens.first.value, 'beta');

        final thetaTokens = Tokenizer('θ').tokenize();
        expect(thetaTokens.first.type, TokenType.variable);
        expect(thetaTokens.first.value, 'theta');
      });

      test('tokenizes comparison operators', () {
        expect(Tokenizer('≤').tokenize().first.type, TokenType.lessEqual);
        expect(Tokenizer('≥').tokenize().first.type, TokenType.greaterEqual);
        expect(Tokenizer('≠').tokenize().first.type, TokenType.notEqual);
      });
    });

    group('Evaluation with Unicode input', () {
      test('evaluates expression with π', () {
        final result = evaluator.evaluateNumeric('2 × π');
        expect(result, closeTo(2 * 3.14159265359, 1e-9));
      });

      test('evaluates √{16}', () {
        final result = evaluator.evaluateNumeric('√{16}');
        expect(result, equals(4.0));
      });

      test('evaluates expression with mixed Unicode and LaTeX', () {
        final result = evaluator.evaluateNumeric(r'√{4} + \sin{π}');
        expect(result, closeTo(2.0, 1e-9));
      });

      test('evaluates ∑ with Unicode', () {
        final result = evaluator.evaluateNumeric('∑_{i=1}^{5} i');
        expect(result, equals(15.0));
      });

      test('evaluates ∫ with Unicode', () {
        final result = evaluator.evaluateNumeric('∫_{0}^{1} x dx');
        expect(result, closeTo(0.5, 1e-3));
      });

      test('evaluates with Greek letters as variables', () {
        // Greek Unicode letters are converted to \alpha, \beta, etc.
        // which are parsed as variable tokens that can be bound.
        final result =
            evaluator.evaluateNumeric('α + β', {'alpha': 1.0, 'beta': 2.0});
        expect(result, equals(3.0));
      });
    });

    group('Unicode comparison operators in constraints', () {
      test('evaluates expression with ≤ constraint', () {
        final result = evaluator.evaluateNumeric('x, x ≤ 5', {'x': 3.0});
        expect(result, equals(3.0));
      });

      test('evaluates expression with ≥ constraint', () {
        final result = evaluator.evaluateNumeric('x, x ≥ 0', {'x': 5.0});
        expect(result, equals(5.0));
      });
    });
  });
}
