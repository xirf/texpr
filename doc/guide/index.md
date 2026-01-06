# Introduction

TeXpr is a Dart library that parses and evaluates mathematical expressions using LaTeX syntax. It converts strings like `\frac{\sqrt{16}}{2} + \sin{\pi}` into numeric results.

## Why TeXpr?

Consider these scenarios:

- **Scientific calculator app**: Users type expressions, you need to evaluate them
- **Graphing tool**: Generate y-values for thousands of x-values from a formula
- **Education platform**: Parse and validate student-submitted equations
- **Engineering application**: Evaluate formulas with different parameter values

TeXpr handles the parsing, evaluation, and edge cases so you can focus on your application.

## What TeXpr Does

| Capability               | Example                             |
| ------------------------ | ----------------------------------- |
| **Parse LaTeX**          | `\sqrt{x^2 + y^2}` → AST            |
| **Evaluate expressions** | `3 + 4 * 2` → `11.0`                |
| **Handle variables**     | `x^2` with `x=3` → `9.0`            |
| **Complex numbers**      | `e^{i\pi}` → `-1 + 0i`              |
| **Matrix operations**    | Matrix multiplication, determinants |
| **Symbolic calculus**    | Differentiate, integrate, limits    |

## What TeXpr Is NOT

To set expectations correctly:

- **Not a CAS**: TeXpr doesn't simplify `2x + 3x` to `5x`. It evaluates expressions to numeric/symbolic results, but doesn't perform algebraic simplification beyond basic rules.
- **Not a full LaTeX parser**: It handles math notation, not document formatting (`\documentclass`, `\begin{theorem}`, etc.)
- **Not arbitrary precision**: Uses IEEE 754 doubles (~15 digits of precision)

See [Known Issues](/reference/known-issues) for detailed limitations.

## How It Works (In Brief)

TeXpr processes expressions through a pipeline:

```
"\sin{x} + 1"  →  Tokenizer  →  Parser  →  Evaluator  →  1.84...
                     ↓            ↓           ↓
                  Tokens        AST       Result
```

1. **Tokenizer**: Breaks input into tokens (numbers, operators, functions)
2. **Parser**: Builds a tree structure (AST) from tokens
3. **Evaluator**: Computes the result by traversing the tree

For details, see [How It Works](/how-it-works/).

## Quick Example

```dart
import 'package:texpr/texpr.dart';

final evaluator = Texpr();

// Simple evaluation
final result = evaluator.evaluate(r'\sqrt{16} + \sin{\pi}');
print(result.asNumeric());  // 4.0

// With variables
final hypotenuse = evaluator.evaluate(
  r'\sqrt{x^2 + y^2}', 
  {'x': 3.0, 'y': 4.0}
);
print(hypotenuse.asNumeric());  // 5.0

// Symbolic differentiation
final derivative = evaluator.differentiate(r'x^3', 'x');
final slope = evaluator.evaluateParsed(derivative, {'x': 2.0});
print(slope.asNumeric());  // 12.0
```

## Next Steps

- [Installation](/guide/installation) – Add TeXpr to your project
- [Quick Start](/guide/quick-start) – Get productive in 5 minutes
- [Core Concepts](/guide/concepts) – Understand key ideas
- [API Reference](/reference/) – Complete method documentation
