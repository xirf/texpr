# Quick Start

Get up and running with TeXpr in minutes.

## Try It on Replit

<iframe frameborder="0" width="100%" height="500px" src="https://replit.com/@xirf/TeXpr-Demo?embed=true"></iframe>

or try evaluate your own directly in the [playground](/guide/playground)

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

## Checking Syntax

The `parse()` method throws descriptive exceptions for invalid input:

```dart
try {
  texpr.parse(r'\sin{x}');  // ✅ valid
} on ParserException catch (e) {
  print('Error: ${e.message}');
  print('Position: ${e.position}');
  print('Suggestion: ${e.suggestion}');
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

## User-Defined Functions

Define and call your own functions:

```dart
final texpr = Texpr();

// Define a function
texpr.evaluate(r'f(x) = x^2');

// Use it
print(texpr.evaluate('f(3)').asNumeric());  // 9.0
print(texpr.evaluate('f(5)').asNumeric());  // 25.0
```

See [Custom Environments](/guide/environments) for variables, multi-parameter functions, and more.

### Real-Only Mode

By default, TeXpr evaluates expressions over the complex numbers ℂ.

This means:

* `sqrt(x)` for `x < 0` produces a complex result.
* Subsequent operations continue in ℂ.
* Certain operators (e.g. `abs`) map complex inputs to real outputs by definition.

As a consequence, an expression may:

* Enter the complex domain during evaluation
* Later return a real-valued result
* Be reported as `NumericResult`, even though intermediate values were complex

Example:
`sqrt(π·(-5))` evaluates in ℂ
`abs(3.96i + 10)` evaluates to a real magnitude
The final value is real, but the computation was not real-only.

This behavior is mathematically correct but differs from “real-only” graphing tools, where operations like `sqrt(x)` are undefined for `x < 0` and halt evaluation.

---

### Real-Only Mode Semantics

When Real-Only Mode is enabled:

* The evaluation domain is restricted to ℝ
* Any operation that would require extension to ℂ is treated as undefined
* The entire expression becomes unevaluable at that point
* No downstream recovery via real-valued operators is permitted

Formally:
If any subexpression is not real-evaluable, the full expression is rejected.

This mode enforces domain safety rather than result-type inspection.


```dart
final texpr = Texpr(realOnly: true);

texpr.evaluate(r'\sqrt{-1}');  // NaN (not i)
texpr.evaluate(r'\ln{-1}');    // NaN (not iπ)
texpr.evaluate(r'\sqrt{4}');   // 2.0 (works normally)
```

## How It Works

The evaluator processes expressions in 3 stages:

1. **Tokenize** — LaTeX string → tokens
2. **Parse** — tokens → AST (Abstract Syntax Tree)
3. **Evaluate** — AST + variables → result

Results are type-safe sealed classes: `NumericResult`, `ComplexResult`, `MatrixResult`, `VectorResult`.

## What's Next

- [Custom Environments](/guide/environments) — Variables and user-defined functions
- [LaTeX Reference](/reference/latex) — All supported commands
- [Functions](/reference/functions) — Mathematical functions
- [Advanced Topics](/advanced/) — Symbolic algebra, calculus, extensions

