# Custom Extensions

The library supports adding custom LaTeX commands and evaluation logic.

## ExtensionRegistry

Use `ExtensionRegistry` to register custom functionality:

```dart
import 'package:texpr/texpr.dart';

final registry = ExtensionRegistry();

// Register your extensions...

final evaluator = LatexMathEvaluator(extensions: registry);
```

## Adding Custom Commands

Register a custom LaTeX command that produces tokens:

```dart
registry.registerCommand('myfunction', (command, position) {
  return Token(
    type: TokenType.function,
    value: 'myfunction',
    position: position,
  );
});
```

## Adding Custom Evaluators

Register custom evaluation logic for expressions:

```dart
import 'dart:math' as math;

registry.registerEvaluator((expression, variables, evaluate) {
  if (expression is FunctionCall && expression.name == 'myfunction') {
    // Custom logic here
    final argValue = evaluate(expression.argument);
    return argValue * 2;  // Example: double the argument
  }
  return null;  // Return null to use default evaluation
});
```

## Complete Example: Cube Root

```dart
import 'dart:math' as math;
import 'package:texpr/texpr.dart';

void main() {
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
  
  final evaluator = LatexMathEvaluator(extensions: registry);
  
  print(evaluator.evaluate(r'\cbrt{27}'));  // 3.0
  print(evaluator.evaluate(r'\cbrt{8}'));   // 2.0
}
```

## Overriding Built-in Functions

Custom evaluators run before built-in evaluation, so you can override default behavior:

```dart
registry.registerEvaluator((expr, vars, evaluate) {
  if (expr is FunctionCall && expr.name == 'sin') {
    // Custom sin that works in degrees instead of radians
    final degrees = evaluate(expr.argument);
    return math.sin(degrees * math.pi / 180);
  }
  return null;
});
```
