# API Reference

Complete API reference for the TeXpr library.

## Texpr Class

The main entry point for parsing and evaluating expressions.

### Constructor

```dart
Texpr({
  ExtensionRegistry? extensions,
  bool allowImplicitMultiplication = true,
  CacheConfig? cacheConfig,
  int maxRecursionDepth = 500,
  bool realOnly = false,
})
```

| Parameter                     | Type                 | Default       | Description                                                |
| ----------------------------- | -------------------- | ------------- | ---------------------------------------------------------- |
| `extensions`                  | `ExtensionRegistry?` | null          | Custom commands and evaluators                             |
| `allowImplicitMultiplication` | `bool`               | true          | Treat `xy` as `x * y`                                      |
| `cacheConfig`                 | `CacheConfig?`       | CacheConfig() | Cache size and eviction settings                           |
| `maxRecursionDepth`           | `int`                | 500           | Max recursion for parsing/evaluation                       |
| `realOnly`                    | `bool`               | false         | Only evaluate real numbers, return NaN for complex results |

### Methods

#### Evaluation Methods

| Method            | Signature                                                                     | Description                   |
| ----------------- | ----------------------------------------------------------------------------- | ----------------------------- |
| `evaluate`        | `EvaluationResult evaluate(String expr, [Map<String, double> vars])`          | Parse and evaluate expression |
| `evaluateNumeric` | `double evaluateNumeric(String expr, [Map<String, double> vars])`             | Evaluate and return as double |
| `evaluateMatrix`  | `Matrix evaluateMatrix(String expr, [Map<String, double> vars])`              | Evaluate and return as Matrix |
| `evaluateParsed`  | `EvaluationResult evaluateParsed(Expression ast, [Map<String, double> vars])` | Evaluate pre-parsed AST       |

#### Parsing Methods

| Method     | Signature                                | Description                         |
| ---------- | ---------------------------------------- | ----------------------------------- |
| `parse`    | `Expression parse(String expr)`          | Parse to AST without evaluating     |
| `isValid`  | `bool isValid(String expr)`              | Check if syntax is valid            |
| `validate` | `ValidationResult validate(String expr)` | Detailed validation with error info |

#### Calculus Methods

| Method          | Signature                                                                  | Description             |
| --------------- | -------------------------------------------------------------------------- | ----------------------- |
| `differentiate` | `Expression differentiate(dynamic expr, String variable, {int order = 1})` | Symbolic derivative     |
| `integrate`     | `Expression integrate(dynamic expr, String variable)`                      | Symbolic antiderivative |

#### Cache Methods

| Method                       | Signature                                    | Description        |
| ---------------------------- | -------------------------------------------- | ------------------ |
| `clearParsedExpressionCache` | `void clearParsedExpressionCache()`          | Clear L1 cache     |
| `clearAllCaches`             | `void clearAllCaches()`                      | Clear all caches   |
| `warmUpCache`                | `void warmUpCache(List<String> expressions)` | Pre-populate cache |

#### Environment Methods

| Method             | Signature                 | Description                       |
| ------------------ | ------------------------- | --------------------------------- |
| `clearEnvironment` | `void clearEnvironment()` | Clear persistent global variables |

#### Properties

| Property          | Type                        | Description                 |
| ----------------- | --------------------------- | --------------------------- |
| `cacheStatistics` | `MultiLayerCacheStatistics` | Cache hit/miss statistics   |
| `cacheConfig`     | `CacheConfig`               | Current cache configuration |

---

## EvaluationResult (Sealed)

Base class for all evaluation results. Use pattern matching or convenience methods.

```dart
sealed class EvaluationResult {
  // Convenience accessors (throw if wrong type)
  double asNumeric();
  Complex asComplex();
  Matrix asMatrix();
  Vector asVector();
  
  // Type checks
  bool get isNumeric;
  bool get isComplex;
  bool get isMatrix;
  bool get isVector;
  bool get isNaN;
}
```

### Subclasses

#### NumericResult
```dart
class NumericResult extends EvaluationResult {
  final double value;
}
```

#### ComplexResult
```dart
class ComplexResult extends EvaluationResult {
  final Complex value;
}
```

#### MatrixResult
```dart
class MatrixResult extends EvaluationResult {
  final Matrix matrix;
}
```

#### VectorResult
```dart
class VectorResult extends EvaluationResult {
  final Vector vector;
}
```

### Usage Example

```dart
final result = evaluator.evaluate(r'e^{i\pi}');

switch (result) {
  case NumericResult(:final value):
    print('Real: $value');
  case ComplexResult(:final value):
    print('Complex: ${value.real} + ${value.imaginary}i');
  case MatrixResult(:final matrix):
    print('Matrix: ${matrix.rows}x${matrix.cols}');
  case VectorResult(:final vector):
    print('Vector with ${vector.length} elements');
}
```

---

## Expression (Sealed)

Base class for all AST nodes. Created by `parse()` and consumed by `evaluateParsed()`.

### Common Node Types

| Class                  | Description          | Example expression                |
| ---------------------- | -------------------- | --------------------------------- |
| `NumberLiteral`        | Numeric value        | `3.14`                            |
| `Variable`             | Variable reference   | `x`                               |
| `ImaginaryUnit`        | The constant i       | `i`                               |
| `BinaryOp`             | Binary operation     | `a + b`                           |
| `UnaryOp`              | Unary operation      | `-x`, `x!`                        |
| `FunctionCall`         | Function with 1 arg  | `\sin{x}`                         |
| `MultiArgFunctionCall` | Function with n args | `\max{a, b}`                      |
| `MatrixExpr`           | Matrix literal       | `\begin{pmatrix}...\end{pmatrix}` |
| `VectorExpr`           | Vector literal       | `[1, 2, 3]`                       |
| `IntegralExpr`         | Integral             | `\int x dx`                       |
| `DerivativeExpr`       | Derivative           | `\frac{d}{dx}f`                   |
| `SumExpr`              | Summation            | `\sum_{i=1}^n i`                  |
| `ProductExpr`          | Product              | `\prod_{i=1}^n i`                 |
| `LimitExpr`            | Limit                | `\lim_{x \to 0}`                  |
| `ConditionalExpr`      | Piecewise            | `f, a < x < b`                    |

### Node Methods

All Expression nodes have:

```dart
abstract class Expression {
  Map<String, dynamic> toJson();  // Serialize to JSON
  String toLatex();               // Convert back to LaTeX
  String toSymPy();               // Export to SymPy syntax
}
```

### Evaluability Extension

Check if an expression can be evaluated before attempting evaluation:

```dart
final expr = evaluator.parse(r'\nabla f');
final evaluability = expr.getEvaluability();

// Returns one of:
// - Evaluability.numeric     (can compute a number)
// - Evaluability.symbolic    (symbolic-only, e.g. ∇f)
// - Evaluability.unevaluable (missing variables)
```

Pass known variables to check evaluability with context:

```dart
final expr = evaluator.parse(r'x^2 + 1');
expr.getEvaluability();       // unevaluable (x undefined)
expr.getEvaluability({'x'});  // numeric (x provided)
```

---

## Evaluability

Enum describing whether an expression can be numerically evaluated.

```dart
enum Evaluability {
  /// Can be fully evaluated to numeric/complex/matrix result.
  /// Examples: 2 + 3, \sin{\pi}, \sum_{i=1}^{10} i
  numeric,

  /// Symbolic-only, cannot produce a numeric result.
  /// Examples: \nabla f, tensor indices, \frac{\partial}{\partial x} f
  symbolic,

  /// Cannot be evaluated due to missing context.
  /// Examples: x + 1 without x defined
  unevaluable,
}
```

### Usage

```dart
import 'package:texpr/texpr.dart';

final texpr = Texpr();

// Numeric expression
final expr1 = texpr.parse(r'2 + 3');
expr1.getEvaluability();  // Evaluability.numeric

// Expression with undefined variable
final expr2 = texpr.parse(r'x^2 + 1');
expr2.getEvaluability();       // Evaluability.unevaluable
expr2.getEvaluability({'x'});  // Evaluability.numeric

// Symbolic expression
final expr3 = texpr.parse(r'\nabla f');
expr3.getEvaluability();  // Evaluability.symbolic
```

### Evaluability Rules

| Expression Type                  | Evaluability        | Notes                  |
| -------------------------------- | ------------------- | ---------------------- |
| `NumberLiteral`                  | `numeric`           | Always                 |
| `Variable` (defined)             | `numeric`           | When in context        |
| `Variable` (undefined)           | `unevaluable`       | When not in context    |
| Known constants (`pi`, `e`, `i`) | `numeric`           | Built-in               |
| `BinaryOp`, `UnaryOp`            | Depends on children | Worst-case propagates  |
| Definite integral                | `numeric`           | Has bounds             |
| Indefinite integral              | `symbolic`          | No bounds              |
| `∇f` (gradient of symbol)        | `symbolic`          | Bare symbol            |
| `∂f/∂x` (of symbol)              | `symbolic`          | Bare symbol            |
| Multi-integrals                  | `symbolic`          | Line/surface integrals |

**Combination rule**: When combining children, the "worst" evaluability wins:
- `symbolic` > `unevaluable` > `numeric`

## ValidationResult

Returned by `validate()` with detailed error information.

```dart
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int? position;          // Character position of error
  final String? suggestion;      // Suggested fix
  final List<ValidationResult> subErrors;  // Additional errors
}

// Constructors
const ValidationResult.valid();
ValidationResult.fromException(TexprException e);
```

---

## CacheConfig

Configure caching behavior.

```dart
class CacheConfig {
  final int parsedExpressionCacheSize;   // L1, default: 128
  final int evaluationResultCacheSize;    // L2, default: 256
  final int differentiationCacheSize;     // L3, default: 128
  final EvictionPolicy evictionPolicy;    // LRU or LFU
  final Duration? ttl;                    // Time-to-live
  final int maxCacheInputLength;          // Skip long expressions
  final bool collectStatistics;           // Enable stats
}

// Presets
CacheConfig.highPerformance
CacheConfig.withStatistics
CacheConfig.minimal
CacheConfig.disabled
```

---

## Complex

Complex number representation.

```dart
class Complex {
  final double real;
  final double imaginary;
  
  Complex(this.real, this.imaginary);
  Complex.fromReal(double r);
  Complex.fromImaginary(double i);
  
  // Arithmetic
  Complex operator +(Complex other);
  Complex operator -(Complex other);
  Complex operator *(Complex other);
  Complex operator /(Complex other);
  Complex operator -();
  
  // Properties
  double get magnitude;     // |z| = sqrt(real² + imaginary²)
  double get phase;         // arg(z) = atan2(imaginary, real)
  Complex get conjugate;    // a - bi
  
  // Functions
  Complex sqrt();
  Complex exp();
  Complex log();
  Complex pow(Complex exponent);
  Complex sin();
  Complex cos();
}
```

---

## Matrix

Matrix representation and operations.

```dart
class Matrix {
  final List<List<double>> data;
  
  Matrix(this.data);
  Matrix.identity(int size);
  Matrix.zero(int rows, int cols);
  
  // Properties
  int get rows;
  int get cols;
  bool get isSquare;
  
  // Element access
  double get(int row, int col);
  void set(int row, int col, double value);
  List<double> getRow(int index);
  List<double> getColumn(int index);
  
  // Arithmetic
  Matrix operator +(Matrix other);
  Matrix operator -(Matrix other);
  Matrix operator *(Matrix other);  // Matrix multiplication
  Matrix operator /(double scalar);
  
  // Operations
  Matrix transpose();
  Matrix inverse();
  double determinant();
  double trace();
  Matrix power(int n);  // Repeated multiplication
}
```

---

## Vector

Vector representation.

```dart
class Vector {
  final List<double> elements;
  
  Vector(this.elements);
  Vector.zero(int length);
  
  // Properties
  int get length;
  double get magnitude;
  Vector get normalized;
  
  // Element access
  double operator [](int index);
  void operator []=(int index, double value);
  
  // Arithmetic
  Vector operator +(Vector other);
  Vector operator -(Vector other);
  Vector operator *(double scalar);
  double dot(Vector other);      // Dot product
  Vector cross(Vector other);    // Cross product (3D only)
}
```

---

## Exceptions

All exceptions inherit from `TexprException`:

```dart
sealed class TexprException implements Exception {
  String get message;
  int? get position;
  String? get suggestion;
}

class TokenizerException extends TexprException {
  // Thrown during tokenization
}

class ParserException extends TexprException {
  // Thrown during parsing
}

class EvaluatorException extends TexprException {
  // Thrown during evaluation
}
```

---

## ExtensionRegistry

Register custom commands and evaluators.

```dart
class ExtensionRegistry {
  // Register a custom LaTeX command
  void registerCommand(
    String name, 
    Token Function(String command, int position) tokenizer
  );
  
  // Register a custom evaluator
  void registerEvaluator(
    double? Function(Expression expr, Map<String, double> vars, EvalFunc eval) evaluator
  );
}

typedef EvalFunc = double Function(Expression expr);
```

### Example

```dart
final registry = ExtensionRegistry();

// Register \myconst as a constant
registry.registerCommand('myconst', (cmd, pos) =>
  Token(type: TokenType.number, value: '42', position: pos)
);

// Register custom function evaluation
registry.registerEvaluator((expr, vars, eval) {
  if (expr is FunctionCall && expr.name == 'double') {
    return 2 * eval(expr.argument);
  }
  return null;  // Not handled, use default
});

final evaluator = Texpr(extensions: registry);
evaluator.evaluate(r'\myconst');  // 42
```

---

## Export Visitors

Convert AST to other formats.

### JsonAstVisitor
```dart
final json = expr.toJson();
// { "type": "BinaryOp", "operator": "+", "left": {...}, "right": {...} }
```

### SymPyVisitor
```dart
final sympy = expr.toSymPy();
// "x**2 + sin(x)"
```

### MathMLVisitor
```dart
final mathml = MathMLVisitor().visit(expr);
// <math>...</math>
```
