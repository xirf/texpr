# TeXpr 🧮

[![Tests](https://img.shields.io/badge/tests-1197%20passed-brightgreen)](https://github.com/xirf/texpr)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)](https://github.com/xirf/texpr)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Pub Version](https://img.shields.io/pub/v/texpr)](https://pub.dev/packages/texpr)

TeXpr is a Dart library that parses and evaluates mathematical expressions using LaTeX syntax. It compiles input strings into an Abstract Syntax Tree (AST) to support numerical evaluation, symbolic differentiation, and structural analysis.

## ✨ Capabilities

* 🎯 **LaTeX Parsing** – Parses standard LaTeX mathematical notation directly into Dart objects.
* 🧮 **Symbolic Calculus** – Computes derivatives and simplifies expressions using algebraic rules.
* 🔢 **Advanced Mathematics** – Supports summations, products, limits, integrals, and special functions.
* 📈 **Linear Algebra** – Supports matrix and vector operations, including determinants, inverses, and arithmetic.
* 🔢 **Type Safety** – Returns results as `Numeric`, `Complex`, `Matrix`, or `Vector` via Dart 3 sealed classes.
* 🚩 **Domain Constraints** – Validates mathematical domains (e.g., $x > 0$ ) during evaluation.
* 🧩 **Implicit Multiplication** – Supports implicit syntax such as $2 \pi r^2$ or $\sin{2x}$. (can be disabled)
* 🎲 **Equation Solving** – Solves linear and quadratic equations symbolically.
* 🚨 **Piecewise Functions** – Evaluates and differentiates conditional expressions.

---

## 🚀 Quick Start

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  texpr: ^0.0.1

```

### Basic Usage

```dart
import 'package:texpr/texpr.dart';

final evaluator = LatexMathEvaluator();

// 1. Numeric evaluation
final result = evaluator.evaluateNumeric(r'\frac{\sqrt{16}}{2} + \sin{\pi}');
print(result); // 2.0

// 2. Evaluation with variable binding
final vars = {'x': 3.0, 'y': 4.0};
final hypotenuse = evaluator.evaluateNumeric(r'\sqrt{x^2 + y^2}', vars);
print(hypotenuse); // 5.0

```

---

## 🛠️ Features

### 1. Symbolic Calculus & Differentiation

The library supports exact symbolic differentiation rather than finite difference approximations.

```dart
// Differentiate with respect to x
final derivative = evaluator.differentiate(r'x^3 + \sin{x}', 'x');

// Evaluate the derivative at x = 0
print(evaluator.evaluateParsed(derivative, {'x': 0})); // 1.0

// Differentiate piecewise functions
final piecewise = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');
print(evaluator.evaluateParsed(piecewise, {'x': 1})); // cos(1)

```

### 2. Complex Numbers & Matrices

Evaluates expressions involving complex numbers and linear algebra components.

```dart
// Euler's identity evaluation
final euler = evaluator.evaluate(r'e^{i*\pi}');
print(euler.asComplex().real); // -1.0

// Complex trigonometry
final sinComplex = evaluator.evaluate(r'\sin(1 + 2*i)');
print(sinComplex.asComplex()); // Complex(3.1658, 1.9596)

// Matrix arithmetic
final matrixResult = evaluator.evaluate(r'''
  \begin{pmatrix} 0.8 & 0.1 \\ 0.2 & 0.7 \end{pmatrix} ^ 2
''');

```

### 3. Diagnostics

The parser provides error location offsets and suggestions for syntax errors.

```dart
final validation = evaluator.validate(r'\frac{1{2}');
if (!validation.isValid) {
  print('Error at ${validation.position}: ${validation.errorMessage}');
  // Suggestion: "Add a closing brace '}'"
}

// Function name suggestions
try {
  evaluator.evaluate(r'\sinn{x}');
} on EvaluatorException catch (e) {
  print(e.suggestion); // "Did you mean 'sin'?"
}

```

### 4. Caching

The `LatexMathEvaluator` includes a configurable multi-layer LRU cache for repeated evaluations.

```dart
// Parse once, evaluate multiple times (Recommended for loops)
final ast = evaluator.parse(r'\sin(x) + \cos(x)');
for (var x = 0.0; x < 100; x += 0.01) {
  evaluator.evaluateParsed(ast, {'x': x});
}

```

#### Performance Modes

| Mode               | Overhead | Description                                        |
| ------------------ | -------- | -------------------------------------------------- |
| `evaluate()`       | High     | Parses and evaluates the string on every call.     |
| `evaluateParsed()` | Low      | Evaluates a pre-parsed AST. Recommended for loops. |

#### Benchmark Context

> [!IMPORTANT] Comparison Limitations
> This performance comparison compares different tools with different purposes:
> - **Dart**: Numeric evaluation of LaTeX syntax
> - **Python**: Symbolic computation with SymPy (capable of algebra, not just evaluation)
> - **JavaScript**: General-purpose math with mathjs (supports units, matrices, complex types)
>
> Direct speed comparisons should be interpreted with these architectural differences in mind.

Results from MacBook Air M1 8GB, macOS 15.7.2:

| Expression Category             | Dart (µs) | Dart WASM (µs) | Python (SymPy)* (µs) | JS (mathjs) (µs) |
| :------------------------------ | --------: | -------------: | -------------------: | ---------------: |
| **Basic: Trigonometry**         |      1.10 |           3.38 |                34.23 |             5.28 |
| **Basic: Power & Sqrt**         |      1.05 |           2.80 |                32.93 |             6.09 |
| **Polynomial**                  |      1.19 |           3.10 |                 6.45 |             5.59 |
| **Academic: Normal PDF**        |      4.76 |          10.77 |               211.05 |            19.46 |
| **Calculus: Definite Integral** |  1,415.93 |            N/A |             1,811.45 |              N/A |

### 5. Export

Parsed expressions (AST) can be exported to other formats.

```dart
final expr = evaluator.parse(r'\int x^2 dx');

// Export to JSON for tooling/debugging
print(expr.toJson());

// Export to SymPy for Python interoperability
print(expr.toSymPy()); // Output: integrate(x**2, x)

```

---

## 📚 Examples

Below is a selection of examples showcasing the library's capabilities.

| Category        | Expression                                                              | Feature Used             |
| --------------- | ----------------------------------------------------------------------- | ------------------------ |
| **Physics**     | `\frac{1}{\sqrt{1 - \frac{v^2}{c^2}}}`                                  | Variable Binding         |
| **Engineering** | `\frac{P L^3}{48 E I} ( 3 \frac{x}{L} - 4 ( \frac{x}{L} )^3 )`          | Algebraic Simplification |
| **Quantum**     | `\int_{0}^{L} \psi^*(x) \hat{H} \psi(x) dx`                             | Integration              |
| **Statistics**  | `\frac{1}{\sigma \sqrt{2\pi}} e^{-\frac{1}{2}(\frac{x-\mu}{\sigma})^2}` | Constants ()             |

---

## 📖 Documentation

* **[Getting Started](doc/getting_started.md)**
* **[LaTeX Commands Reference](doc/latex_commands.md)**
* **[Symbolic Algebra](doc/symbolic_algebra.md)**
* **[Function Reference](doc/functions/README.md)**
* **[Extending the Library](doc/extensions.md)**
* **[Export Features](doc/features/export.md)**

## 🤝 Contributing

Contributions are welcome. Please open a Pull Request or Issue on GitHub.

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.