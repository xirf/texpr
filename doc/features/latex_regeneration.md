# LaTeX Regeneration from AST

## Overview

The TeXpr supports **round-trip LaTeX processing**: you can parse LaTeX into an AST (Abstract Syntax Tree) and then regenerate LaTeX from that AST. This enables workflows for symbolic manipulation, expression normalization, and integration with visualization tools.

> **Note**: The regeneration process produces **canonical LaTeX**. It does not preserve the original formatting (whitespace, unnecessary braces) of the input string. Instead, it generates a standardized, mathematically equivalent representation.

## Basic Usage

```dart
import 'package:texpr/texpr.dart';

void main() {
  final evaluator = LatexMathEvaluator();
  
  // Parse LaTeX to AST
  final ast = evaluator.parse(r'\frac{x^2 + 1}{2}');
  
  // Regenerate LaTeX from AST
  final latex = ast.toLatex();
  print(latex); // \frac{x^{2}+1}{2}
}
```

## Features

### 1. Round-Trip Processing

Parse LaTeX, modify it programmatically, and export back to LaTeX:

```dart
// Parse original expression
final original = evaluator.parse(r'x^2');

// Modify: add 1 to create (x^2) + 1
final modified = BinaryOp(
  original,
  BinaryOperator.add,
  const NumberLiteral(1),
);

// Export to LaTeX
print(modified.toLatex()); // x^{2}+1
```

### 2. Programmatic Expression Building

Build complex expressions from AST nodes and export to LaTeX:

```dart
// Build the quadratic formula: (-b + sqrt(b^2 - 4ac)) / 2a
const b = Variable('b');
const a = Variable('a');
const c = Variable('c');

final bSquared = BinaryOp(b, BinaryOperator.power, const NumberLiteral(2));
final fourAC = BinaryOp(
  BinaryOp(const NumberLiteral(4), BinaryOperator.multiply, a),
  BinaryOperator.multiply,
  c,
);
final discriminant = BinaryOp(bSquared, BinaryOperator.subtract, fourAC);
final sqrtDiscriminant = FunctionCall('sqrt', discriminant);
final numerator = BinaryOp(
  UnaryOp(UnaryOperator.negate, b),
  BinaryOperator.add,
  sqrtDiscriminant,
);
final denominator = BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, a);
final formula = BinaryOp(numerator, BinaryOperator.divide, denominator);

print(formula.toLatex());
// \frac{-b+\sqrt{b^{2}-4 \cdot a \cdot c}}{2 \cdot a}
```

### 3. Expression Normalization

Convert different LaTeX representations into a canonical form:

```dart
// Input variations
final expr1 = evaluator.parse(r'x*y');
final expr2 = evaluator.parse(r'x \cdot y');
final expr3 = evaluator.parse(r'xy');  // implicit multiplication

// All produce normalized LaTeX
print(expr1.toLatex()); // Contains multiplication operator
print(expr2.toLatex()); // Contains multiplication operator  
print(expr3.toLatex()); // Contains multiplication operator
```

### 4. Integration with Visualization Tools

Export AST to LaTeX for rendering with MathJax or KaTeX:

```dart
final expr = evaluator.parse(r'\frac{x^2+1}{x-1}');
final cleanLatex = expr.toLatex();

// Use in web display
// <div>$$${cleanLatex}$$</div>
```

## Supported Constructs

The `toLatex()` method supports all expression types:

### Basic Expressions
- **Number Literals**: `42`, `3.14`
- **Variables**: `x`, `y`, `theta`

### Binary Operations
- **Addition**: `+`
- **Subtraction**: `-`
- **Multiplication**: `\cdot`, `\times` (preserves source token)
- **Division**: `\frac{a}{b}`
- **Exponentiation**: `^`

### Functions
- **Trigonometric**: `\sin`, `\cos`, `\tan`, etc.
- **Logarithmic**: `\ln`, `\log`, `\log_{base}`
- **Square Root**: `\sqrt{x}`, `\sqrt[n]{x}`
- **Absolute Value**: `\left|x\right|`

### Calculus
- **Limits**: `\lim_{x \to a}{f(x)}`
- **Derivatives**: `\frac{d}{dx}{f(x)}`, `\frac{d^n}{dx^n}{f(x)}`
- **Integrals**: `\int_{a}^{b}{f(x)} dx`
- **Summation**: `\sum_{i=a}^{b}{f(i)}`
- **Product**: `\prod_{i=a}^{b}{f(i)}`

### Linear Algebra
- **Matrices**: `\begin{bmatrix}...\end{bmatrix}`
- **Vectors**: `\vec{...}`, `\hat{...}`

### Logic
- **Comparisons**: `<`, `>`, `=`
- **Chained Comparisons**: `a < x < b`
- **Conditional Expressions**: `expr \text{ where } condition`

## Implementation Details

### Operator Precedence

The `toLatex()` method automatically adds parentheses based on operator precedence:

```dart
final expr = evaluator.parse(r'2+3 \times 4');
print(expr.toLatex()); // Preserves precedence without unnecessary parens

final expr2 = evaluator.parse(r'(2+3) \times 4');  
print(expr2.toLatex()); // Adds parens where needed
```

### Source Token Preservation

For operations like multiplication, the original token is preserved when possible:

```dart
final expr1 = evaluator.parse(r'2 \times 3');
print(expr1.toLatex()); // Uses \times

final expr2 = evaluator.parse(r'2 \cdot 3');
print(expr2.toLatex()); // Uses \cdot
```

### Round-Trip Behavior

While the LaTeX output may differ cosmetically from the input (spacing, parentheses), parsing the regenerated LaTeX produces an **equivalent AST** for supported constructs:

```dart
final original = r'\frac{x^2 + 1}{2}';
final ast1 = evaluator.parse(original);
final regenerated = ast1.toLatex();
final ast2 = evaluator.parse(regenerated);

assert(ast1 == ast2); // ASTs are equivalent for supported constructs
```

## Use Cases

### 1. Symbolic Algebra Systems
Build expressions programmatically and export to LaTeX for display:

```dart
// Simplify: (x+1)^2 → x^2 + 2x + 1
// (simplified AST construction)
final result = /* construct simplified form */;
print(result.toLatex());
```

### 2. Educational Tools
Show step-by-step solutions with LaTeX output at each step:

```dart
final steps = [
  evaluator.parse(r'x^2 + 2x + 1'),
  evaluator.parse(r'(x+1)^2'),
  // ... more steps
];

for (final step in steps) {
  print(step.toLatex());
}
```

### 3. Expression Validators
Normalize user input and display cleaned version:

```dart
final userInput = r'x*2+3*x';
final ast = evaluator.parse(userInput);
final normalized = ast.toLatex();
print('Did you mean: $normalized?');
```

### 4. API Integration
Convert between different mathematical formats:

```dart
// Accept user input
final input = getUserInput();
final ast = evaluator.parse(input);

// Export for external systems
final latex = ast.toLatex();
final mathML = ast.toMathML(); // Future feature
final json = ast.toJson();     // Future feature
```

## Examples

See these files for complete examples:

- [`example/features/latex_regeneration_demo.dart`](../example/features/latex_regeneration_demo.dart) - Demonstration
- [`test/features/ast_to_latex_test.dart`](../test/features/ast_to_latex_test.dart) - Test suite with many examples

## Future Enhancements

This feature is part of **Roadmap 4.1: AST Export Formats**. Planned additions include:

- MathML export (Presentation and Content MathML)
- JSON AST export
- SymPy-compatible format
- Import capabilities for all formats
- More sophisticated simplification during export

## API Reference

### `Expression.toLatex()`

Converts an AST expression to LaTeX notation.

**Returns:** `String` - The LaTeX representation of the expression

**Example:**
```dart
final expr = evaluator.parse(r'\sin{x^2}');
final latex = expr.toLatex(); // \sin{x^{2}}
```

All `Expression` subclasses implement this method:
- `NumberLiteral`
- `Variable`
- `BinaryOp`
- `UnaryOp`
- `FunctionCall`
- `LimitExpr`
- `DerivativeExpr`
- `IntegralExpr`
- `SumExpr`
- `ProductExpr`
- `MatrixExpr`
- `VectorExpr`
- `Comparison`
- `ChainedComparison`
- `ConditionalExpr`
- `AbsoluteValue`

**Related Documentation:**
- [Getting Started](getting_started.md)
- [AST Documentation](api/ast.md)
- [Roadmap - AST Export Formats](../ROADMAP.md#41-ast-export-formats)
