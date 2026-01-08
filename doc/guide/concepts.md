# Core Concepts

Before diving into the API, it helps to understand the key concepts that make TeXpr work.

## LaTeX as Input

TeXpr uses LaTeX syntax because it's the standard for mathematical notation. You write expressions the same way you'd write them in a math document:

| What you mean     | LaTeX syntax  | TeXpr evaluates to |
| ----------------- | ------------- | ------------------ |
| Square root of 16 | `\sqrt{16}`   | 4                  |
| Fraction 1/2      | `\frac{1}{2}` | 0.5                |
| Sin of π          | `\sin{\pi}`   | 0                  |
| x squared         | `x^{2}`       | depends on x       |

This isn't an arbitrary choice — if you're working with mathematical expressions, you (or your users) probably already know LaTeX.

---

## The Three-Stage Pipeline

Every evaluation goes through three stages:

```
String → Tokenizer → Tokens → Parser → AST → Evaluator → Result
```

You don't need to understand the internals, but knowing they exist helps explain:
- **Why parsing once and evaluating many times is faster** (skip tokenizer + parser)
- **Why some errors mention "tokenization" vs "parsing" vs "evaluation"** (different stages)
- **Why caching works** (results from each stage can be reused)

[Learn more about internals →](/how-it-works/)

---

## Variable Binding

Expressions can contain variables. You provide values at evaluation time:

```dart
// Expression contains x and y
final result = evaluator.evaluate(
  r'\sqrt{x^2 + y^2}', 
  {'x': 3.0, 'y': 4.0}  // Provide values
);
// Result: 5.0
```

**Key points:**
- Variables are single letters by default: `x`, `y`, `α`
- Variable names are case-sensitive: `x` ≠ `X`
- Undefined variables throw an error with a suggestion
- Some names are reserved: `e` (Euler's number), `i` (imaginary unit)

---

## Implicit Multiplication

TeXpr can interpret adjacent items as multiplication:

```dart
// These are equivalent when allowImplicitMultiplication is true (default)
evaluator.evaluate(r'2x');      // 2 * x
evaluator.evaluate(r'xy');      // x * y
evaluator.evaluate(r'\sin x \cos x');  // sin(x) * cos(x)
```

**Why this exists**: Textbooks write `2πr²`, not `2 * π * r^2`. TeXpr matches this convention.

**The trade-off**: Multi-character variable names don't work. `velocity` becomes `v * e * l * o * c * i * t * y`.

**Disable it** when you need multi-character names:

```dart
final evaluator = Texpr(allowImplicitMultiplication: false);
evaluator.evaluate('velocity * time', {'velocity': 10, 'time': 5});
```

---

## Result Types

Evaluation returns `EvaluationResult`, a sealed class with four variants:

| Result Type     | When it's used | Example expression                     |
| --------------- | -------------- | -------------------------------------- |
| `NumericResult` | Real number    | `2 + 3` → 5.0                          |
| `ComplexResult` | Complex number | `e^{i\pi}` → -1+0i                     |
| `MatrixResult`  | Matrix         | `\begin{pmatrix}1&2\\3&4\end{pmatrix}` |
| `VectorResult`  | Vector         | `\nabla{x^2+y^2}` → [2x, 2y]           |

Use pattern matching to handle results:

```dart
final result = evaluator.evaluate(expression);
switch (result) {
  case NumericResult(:final value):
    print('Number: $value');
  case ComplexResult(:final value):
    print('Complex: $value');
  case MatrixResult(:final matrix):
    print('Matrix: ${matrix.rows}x${matrix.cols}');
  case VectorResult(:final vector):
    print('Vector: $vector');
}
```

Or use convenience methods when you know the type:

```dart
// Throws if result isn't numeric
final number = evaluator.evaluateNumeric(r'\sqrt{16}');  // 4.0
```

---

## Error Handling

TeXpr has three exception types, one for each pipeline stage:

| Exception            | When it's thrown  | Example cause                 |
| -------------------- | ----------------- | ----------------------------- |
| `TokenizerException` | Invalid input     | Unknown command `\foo`        |
| `ParserException`    | Invalid syntax    | Unclosed brace `\frac{1`      |
| `EvaluatorException` | Invalid operation | `\log{0}`, undefined variable |

All inherit from `TexprException`, so you can catch all or be specific:

```dart
try {
  evaluator.evaluate(expression);
} on TokenizerException catch (e) {
  print('Invalid input at ${e.position}: ${e.message}');
} on ParserException catch (e) {
  print('Syntax error at ${e.position}: ${e.message}');
} on EvaluatorException catch (e) {
  print('Math error: ${e.message}');
  if (e.suggestion != null) print('Suggestion: ${e.suggestion}');
}
```

---

## Parse Once, Evaluate Many

For repeated evaluation (plotting, animation, iteration), parse the expression once:

```dart
// ✓ Efficient: Parse once
final ast = evaluator.parse(r'\sin{x} + \cos{x}');
for (var x = 0.0; x < 100; x += 0.01) {
  evaluator.evaluateParsed(ast, {'x': x});
}

// ✗ Less efficient: Re-parses internally (though L1 cache helps)
for (var x = 0.0; x < 100; x += 0.01) {
  evaluator.evaluate(r'\sin{x} + \cos{x}', {'x': x});
}
```

The internal cache mitigates the second approach, but explicit caching is more predictable.

---

## Symbolic Operations

Beyond evaluation, TeXpr can manipulate expressions symbolically:

### Differentiation
```dart
final derivative = evaluator.differentiate(r'x^3', 'x');
// Returns AST representing 3*x^2
evaluator.evaluateParsed(derivative, {'x': 2});  // 12.0
```

### Integration
```dart
// Symbolic (indefinite)
final integral = evaluator.integrate(r'x^2', 'x');
// Returns AST representing x^3/3

// Numeric (definite)
evaluator.evaluate(r'\int_{0}^{1} x^2 dx');  // 0.333...
```

---

## Evaluability

Not all parsed expressions can be evaluated numerically. TeXpr makes this explicit:

```dart
final expr = evaluator.parse(r'\nabla f');
print(expr.getEvaluability());  // Evaluability.symbolic
```

| Evaluability  | Meaning                       | Example               |
| ------------- | ----------------------------- | --------------------- |
| `numeric`     | Can compute a result          | `2 + 3`, `\sin{\pi}`  |
| `symbolic`    | Parse-only, no numeric result | `\nabla f`, `\iint`   |
| `unevaluable` | Missing variable definitions  | `x + 1` (x undefined) |

**Check before evaluation** to provide better user feedback:

```dart
final expr = evaluator.parse(userInput);
final eval = expr.getEvaluability(definedVariables);

if (eval == Evaluability.numeric) {
  final result = evaluator.evaluateParsed(expr, variables);
} else if (eval == Evaluability.symbolic) {
  showMessage('This expression is symbolic and cannot be computed');
} else {
  showMessage('Define all variables first');
}
```

---

## What's Next

- [How It Works](/how-it-works/) — Deep dive into the processing pipeline
- [API Reference](/reference/) — Complete method and type reference
- [Advanced Topics](/advanced/) — Calculus, symbolic algebra, extensions
