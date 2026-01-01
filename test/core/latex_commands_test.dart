import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Missing LaTeX Commands', () {
    Expression parse(String input) {
      final tokens = Tokenizer(input).tokenize();
      return Parser(tokens).parse();
    }

    group('Arrow and Relation Symbols', () {
      test('parses \\mapsto (ignored)', () {
        // Should not throw when parsing
        final result = parse(r'f \mapsto y');
        expect(result, isNotNull);
      });

      test('parses \\Rightarrow (ignored)', () {
        final result = parse(r'A \Rightarrow B');
        expect(result, isNotNull);
      });

      test('parses \\Leftarrow (ignored)', () {
        final result = parse(r'A \Leftarrow B');
        expect(result, isNotNull);
      });

      test('parses \\Leftrightarrow (ignored)', () {
        final result = parse(r'A \Leftrightarrow B');
        expect(result, isNotNull);
      });

      test('parses \\approx (ignored)', () {
        final result = parse(r'x \approx y');
        expect(result, isNotNull);
      });

      test('parses \\propto (ignored)', () {
        final result = parse(r'F \propto m');
        expect(result, isNotNull);
      });
    });

    group('Set Notation', () {
      test('parses \\subset', () {
        final result = parse(r'A \subset B');
        expect(result, isNotNull);
      });

      test('parses \\subseteq', () {
        final result = parse(r'A \subseteq B');
        expect(result, isNotNull);
      });

      test('parses \\supset', () {
        final result = parse(r'A \supset B');
        expect(result, isNotNull);
      });

      test('parses \\supseteq', () {
        final result = parse(r'A \supseteq B');
        expect(result, isNotNull);
      });

      test('parses \\cup', () {
        final result = parse(r'A \cup B');
        expect(result, isNotNull);
      });

      test('parses \\cap', () {
        final result = parse(r'A \cap B');
        expect(result, isNotNull);
      });

      test('parses \\setminus', () {
        final result = parse(r'A \setminus B');
        expect(result, isNotNull);
      });
    });

    group('Quantifiers', () {
      test('parses \\forall as variable', () {
        final result = parse(r'\forall x');
        expect(result, isA<BinaryOp>()); // forall * x
        final op = result as BinaryOp;
        expect(op.left, isA<Variable>());
        expect((op.left as Variable).name, 'forall');
      });

      test('parses \\exists as variable', () {
        final result = parse(r'\exists x');
        expect(result, isA<BinaryOp>()); // exists * x
        final op = result as BinaryOp;
        expect(op.left, isA<Variable>());
        expect((op.left as Variable).name, 'exists');
      });
    });

    group('Decoration Functions', () {
      test('parses \\dot{x}', () {
        final result = parse(r'\dot{x}');
        expect(result, isA<FunctionCall>());
        final func = result as FunctionCall;
        expect(func.name, 'dot');
        expect(func.argument, isA<Variable>());
      });

      test('parses \\ddot{x}', () {
        final result = parse(r'\ddot{x}');
        expect(result, isA<FunctionCall>());
        final func = result as FunctionCall;
        expect(func.name, 'ddot');
        expect(func.argument, isA<Variable>());
      });

      test('parses \\bar{x}', () {
        final result = parse(r'\bar{x}');
        expect(result, isA<FunctionCall>());
        final func = result as FunctionCall;
        expect(func.name, 'bar');
        expect(func.argument, isA<Variable>());
      });

      test('evaluates \\dot{x} to variable value', () {
        final evaluator = LatexMathEvaluator();
        final result = evaluator.evaluate(r'\dot{x}', {'x': 5.0});
        expect(result.asNumeric(), 5.0);
      });

      test('evaluates \\ddot{x} to variable value', () {
        final evaluator = LatexMathEvaluator();
        final result = evaluator.evaluate(r'\ddot{x}', {'x': 3.0});
        expect(result.asNumeric(), 3.0);
      });

      test('evaluates \\bar{x} to variable value', () {
        final evaluator = LatexMathEvaluator();
        final result = evaluator.evaluate(r'\bar{x}', {'x': 7.5});
        expect(result.asNumeric(), 7.5);
      });

      test('evaluates complex expression with decorations', () {
        final evaluator = LatexMathEvaluator();
        // \dot{x} + \bar{y} = x + y
        final result = evaluator.evaluate(
          r'\dot{x} + \bar{y}',
          {'x': 2.0, 'y': 3.0},
        );
        expect(result.asNumeric(), 5.0);
      });

      test('parses decorated expression in context', () {
        // Physics-style expression: m\ddot{x} + c\dot{x} + kx = F
        final result = parse(r'm \cdot \ddot{x} + c \cdot \dot{x}');
        expect(result, isA<BinaryOp>());
      });
    });

    group('Complex Academic Expressions', () {
      test('parses logic statement', () {
        final result = parse(r'\forall x \exists y');
        expect(result, isNotNull);
      });

      test('parses set theory expression', () {
        final result = parse(r'A \cup B \subset C');
        expect(result, isNotNull);
      });

      test('parses physics notation with time derivatives', () {
        final result = parse(r'\ddot{q} + \omega^2 q = 0');
        expect(result, isNotNull);
      });

      test('parses statistical mean notation', () {
        final result = parse(r'\bar{x} = \frac{1}{n} \sum_{i=1}^{n} x_i');
        expect(result, isNotNull);
      });
    });
  });

  group('Tokenizer - New Commands', () {
    test('tokenizes all new arrow symbols', () {
      final commands = [
        r'\mapsto',
        r'\Rightarrow',
        r'\Leftarrow',
        r'\Leftrightarrow',
      ];
      for (final cmd in commands) {
        expect(
          () => Tokenizer(cmd).tokenize(),
          returnsNormally,
          reason: 'Failed to tokenize $cmd',
        );
      }
    });

    test('tokenizes all new relation symbols', () {
      final commands = [r'\approx', r'\propto'];
      for (final cmd in commands) {
        expect(
          () => Tokenizer(cmd).tokenize(),
          returnsNormally,
          reason: 'Failed to tokenize $cmd',
        );
      }
    });

    test('tokenizes all new set notation', () {
      final commands = [
        r'\subset',
        r'\subseteq',
        r'\supset',
        r'\supseteq',
        r'\cup',
        r'\cap',
        r'\setminus',
      ];
      for (final cmd in commands) {
        expect(
          () => Tokenizer(cmd).tokenize(),
          returnsNormally,
          reason: 'Failed to tokenize $cmd',
        );
      }
    });

    test('tokenizes quantifiers', () {
      final commands = [r'\forall', r'\exists'];
      for (final cmd in commands) {
        final tokens = Tokenizer(cmd).tokenize();
        expect(tokens.first.type, TokenType.variable);
      }
    });

    test('tokenizes decoration functions', () {
      final commands = [r'\dot', r'\ddot', r'\bar'];
      for (final cmd in commands) {
        final tokens = Tokenizer(cmd).tokenize();
        expect(tokens.first.type, TokenType.function);
      }
    });
  });
}
