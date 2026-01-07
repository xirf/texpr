# Quick Start

Get up and running with TeXpr in minutes.

## Basic Evaluation

```dart
import 'package:texpr/texpr.dart';

final texpr = Texpr();

// Arithmetic
texpr.evaluate(r'2 + 3');           // 5.0
texpr.evaluate(r'\frac{10}{2}');    // 5.0
texpr.evaluate(r'2^{10}');          // 1024.0

// Functions
texpr.evaluate(r'\sin{\pi}');       // 0.0
texpr.evaluate(r'\sqrt{16}');       // 4.0
texpr.evaluate(r'\log_{2}{8}');     // 3.0
```

## Variables

Pass a map of variable bindings:

```dart
final vars = {'x': 3.0, 'y': 4.0};

texpr.evaluate(r'x + y', vars);              // 7.0
texpr.evaluate(r'\sqrt{x^2 + y^2}', vars);   // 5.0
texpr.evaluate(r'\sin{x} + \cos{y}', vars);  // 0.14...
```

## LaTeX Operators

```dart
texpr.evaluate(r'6 \div 2');    // 3.0
texpr.evaluate(r'3 \times 4');  // 12.0
texpr.evaluate(r'2 \cdot 5');   // 10.0
```

## Error Handling

```dart
try {
  texpr.evaluate(r'\log{0}');
} on EvaluatorException catch (e) {
  print('Math error: ${e.message}');
  print('Suggestion: ${e.suggestion}');
} on ParserException catch (e) {
  print('Syntax error at position ${e.position}');
} on TokenizerException catch (e) {
  print('Invalid input: $e');
}
```

## Validation

Check syntax before evaluation:

```dart
// Quick check
texpr.isValid(r'\sin{x}');     // true
texpr.isValid(r'\sin{');       // false

// Detailed validation
final result = texpr.validate(r'\sinn{x}');
if (!result.isValid) {
  print(result.errorMessage);  // Unknown function
  print(result.suggestion);    // "Did you mean 'sin'?"
}
```

## Parse Once, Evaluate Many

For repeated evaluations (e.g., plotting), parse once:

```dart
final ast = texpr.parse(r'\sin{x} + \cos{x}');

for (var x = 0.0; x < 10; x += 0.1) {
  texpr.evaluateParsed(ast, {'x': x});
}
```

## How It Works

The evaluator processes expressions in 3 stages:

1. **Tokenize** — LaTeX string → tokens
2. **Parse** — tokens → AST (Abstract Syntax Tree)
3. **Evaluate** — AST + variables → result

Results are type-safe sealed classes: `NumericResult`, `ComplexResult`, `MatrixResult`, `VectorResult`.

## What's Next

- [LaTeX Reference](/reference/latex) — All supported commands
- [Functions](/reference/functions) — Mathematical functions
- [Advanced Topics](/advanced/) — Symbolic algebra, calculus, extensions
