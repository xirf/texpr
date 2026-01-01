import 'package:test/test.dart';
import 'package:texpr/src/extensions.dart';
import 'package:texpr/src/token.dart';
import 'package:texpr/src/ast.dart';

void main() {
  group('ExtensionRegistry', () {
    test('creates empty registry', () {
      final registry = ExtensionRegistry();
      expect(registry.hasCustomCommands, isFalse);
      expect(registry.hasCustomEvaluators, isFalse);
    });

    test('registerCommand adds command handler', () {
      final registry = ExtensionRegistry();

      registry.registerCommand('custom', (cmd, pos) {
        return Token(type: TokenType.function, value: cmd, position: pos);
      });

      expect(registry.hasCustomCommands, isTrue);
    });

    test('registerEvaluator adds evaluator', () {
      final registry = ExtensionRegistry();

      registry.registerEvaluator((expr, vars, eval) {
        return null;
      });

      expect(registry.hasCustomEvaluators, isTrue);
    });

    test('tryTokenize returns null for unregistered command', () {
      final registry = ExtensionRegistry();

      final token = registry.tryTokenize('unknown', 0);
      expect(token, isNull);
    });

    test('tryTokenize returns token for registered command', () {
      final registry = ExtensionRegistry();

      registry.registerCommand('sqrt', (cmd, pos) {
        return Token(type: TokenType.function, value: 'sqrt', position: pos);
      });

      final token = registry.tryTokenize('sqrt', 5);
      expect(token, isNotNull);
      expect(token!.type, equals(TokenType.function));
      expect(token.value, equals('sqrt'));
      expect(token.position, equals(5));
    });

    test('tryTokenize can return null from handler', () {
      final registry = ExtensionRegistry();

      registry.registerCommand('conditional', (cmd, pos) {
        // Handler decides not to handle this
        return null;
      });

      final token = registry.tryTokenize('conditional', 0);
      expect(token, isNull);
    });

    test('tryEvaluate returns null for unregistered expression', () {
      final registry = ExtensionRegistry();

      final result = registry.tryEvaluate(
        NumberLiteral(5),
        {},
        (expr) => 0,
      );
      expect(result, isNull);
    });

    test('tryEvaluate returns result from registered evaluator', () {
      final registry = ExtensionRegistry();

      registry.registerEvaluator((expr, vars, eval) {
        if (expr is NumberLiteral && expr.value == 42) {
          return 100.0;
        }
        return null;
      });

      final result = registry.tryEvaluate(
        NumberLiteral(42),
        {},
        (expr) => 0,
      );
      expect(result, equals(100.0));
    });

    test('tryEvaluate tries evaluators in order', () {
      final registry = ExtensionRegistry();

      // First evaluator handles variables
      registry.registerEvaluator((expr, vars, eval) {
        if (expr is Variable) {
          return 1.0;
        }
        return null;
      });

      // Second evaluator handles numbers
      registry.registerEvaluator((expr, vars, eval) {
        if (expr is NumberLiteral) {
          return 2.0;
        }
        return null;
      });

      final varResult = registry.tryEvaluate(
        Variable('x'),
        {},
        (expr) => 0,
      );
      expect(varResult, equals(1.0));

      final numResult = registry.tryEvaluate(
        NumberLiteral(5),
        {},
        (expr) => 0,
      );
      expect(numResult, equals(2.0));
    });

    test('tryEvaluate stops at first non-null result', () {
      final registry = ExtensionRegistry();

      registry.registerEvaluator((expr, vars, eval) {
        if (expr is NumberLiteral) {
          return 10.0;
        }
        return null;
      });

      registry.registerEvaluator((expr, vars, eval) {
        if (expr is NumberLiteral) {
          return 20.0; // This should not be reached
        }
        return null;
      });

      final result = registry.tryEvaluate(
        NumberLiteral(5),
        {},
        (expr) => 0,
      );
      expect(result, equals(10.0)); // First evaluator wins
    });

    test('evaluator can use variables parameter', () {
      final registry = ExtensionRegistry();

      registry.registerEvaluator((expr, vars, eval) {
        if (expr is Variable && vars.containsKey(expr.name)) {
          return vars[expr.name]! * 2;
        }
        return null;
      });

      final result = registry.tryEvaluate(
        Variable('x'),
        {'x': 5.0},
        (expr) => 0,
      );
      expect(result, equals(10.0));
    });

    test('evaluator can use evaluate callback', () {
      final registry = ExtensionRegistry();

      registry.registerEvaluator((expr, vars, eval) {
        if (expr is BinaryOp && expr.operator == BinaryOperator.add) {
          // Custom addition: multiply instead
          return eval(expr.left) * eval(expr.right);
        }
        return null;
      });

      final result = registry.tryEvaluate(
        BinaryOp(NumberLiteral(3), BinaryOperator.add, NumberLiteral(4)),
        {},
        (expr) {
          if (expr is NumberLiteral) return expr.value;
          return 0;
        },
      );
      expect(result, equals(12.0)); // 3 * 4 instead of 3 + 4
    });

    test('multiple commands can be registered', () {
      final registry = ExtensionRegistry();

      registry.registerCommand('cmd1', (cmd, pos) {
        return Token(type: TokenType.function, value: 'cmd1', position: pos);
      });

      registry.registerCommand('cmd2', (cmd, pos) {
        return Token(type: TokenType.function, value: 'cmd2', position: pos);
      });

      final token1 = registry.tryTokenize('cmd1', 0);
      final token2 = registry.tryTokenize('cmd2', 5);

      expect(token1!.value, equals('cmd1'));
      expect(token2!.value, equals('cmd2'));
    });

    test('command can be overridden', () {
      final registry = ExtensionRegistry();

      registry.registerCommand('test', (cmd, pos) {
        return Token(type: TokenType.number, value: '1', position: pos);
      });

      registry.registerCommand('test', (cmd, pos) {
        return Token(type: TokenType.number, value: '2', position: pos);
      });

      final token = registry.tryTokenize('test', 0);
      expect(token!.value, equals('2')); // Later registration wins
    });
  });
}
