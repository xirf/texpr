# Extensions

Add custom LaTeX commands and evaluation logic.

## ExtensionRegistry

```dart
import 'package:texpr/texpr.dart';

final registry = ExtensionRegistry();

// Register extensions...

final texpr = Texpr(extensions: registry);
```

## Custom Commands

Register a new LaTeX command:

```dart
registry.registerCommand('myfunction', (command, position) {
  return Token(
    type: TokenType.function,
    value: 'myfunction',
    position: position,
  );
});
```

## Custom Evaluators

Define evaluation logic for custom expressions:

```dart
registry.registerEvaluator((expression, variables, evaluate) {
  if (expression is FunctionCall && expression.name == 'myfunction') {
    final arg = evaluate(expression.argument);
    return arg * 2;  // Double the argument
  }
  return null;  // Use default evaluation
});
```

Return `null` to fall back to built-in evaluation.

## Example: Cube Root

```dart
import 'dart:math' as math;
import 'package:texpr/texpr.dart';

final registry = ExtensionRegistry();

// Register \cbrt command
registry.registerCommand('cbrt', (cmd, pos) =>
  Token(type: TokenType.function, value: 'cbrt', position: pos));

// Register evaluator
registry.registerEvaluator((expr, vars, evaluate) {
  if (expr is FunctionCall && expr.name == 'cbrt') {
    final arg = evaluate(expr.argument);
    return math.pow(arg, 1/3).toDouble();
  }
  return null;
});

final texpr = Texpr(extensions: registry);

texpr.evaluate(r'\cbrt{27}');  // 3.0
texpr.evaluate(r'\cbrt{8}');   // 2.0
```

## Overriding Built-ins

Custom evaluators run first, allowing you to override defaults:

```dart
// Sin in degrees instead of radians
registry.registerEvaluator((expr, vars, evaluate) {
  if (expr is FunctionCall && expr.name == 'sin') {
    final degrees = evaluate(expr.argument);
    return math.sin(degrees * math.pi / 180);
  }
  return null;
});
```
