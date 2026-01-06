# Parser

The parser is the second stage of the processing pipeline. It consumes the token stream from the tokenizer and builds an **Abstract Syntax Tree (AST)** — a hierarchical representation of the expression's structure.

## What Is an AST?

An AST represents the logical structure of an expression as a tree. Each node represents an operation, value, or construct.

**Example**: `2 * x + 1` becomes:

```
       BinaryOp(+)
         /    \
   BinaryOp(*)   NumberLiteral(1)
     /    \
Number(2)  Variable(x)
```

The tree structure captures:
- **What** operations are performed
- **In what order** (precedence is encoded in the tree shape)
- **With what operands**

---

## The Parsing Algorithm

TeXpr uses a **recursive descent parser** with operator precedence climbing. This is a top-down approach where each grammar rule becomes a function.

### Operator Precedence

Operators are parsed in order of precedence (lowest to highest):

| Level | Operators               | Associativity | Example             |
| ----- | ----------------------- | ------------- | ------------------- |
| 1     | `=`, `<`, `>`, `≤`, `≥` | Left          | `a = b`             |
| 2     | `+`, `-`                | Left          | `a + b - c`         |
| 3     | `*`, `/`, `×`, `÷`      | Left          | `a * b / c`         |
| 4     | Unary `-`               | Right         | `-a`                |
| 5     | `^` (power)             | Right         | `a^b^c` = `a^(b^c)` |
| 6     | Function calls, atoms   | -             | `sin(x)`, `x`, `3`  |

### How It Works

1. **Primary parser** handles atoms: numbers, variables, parenthesized expressions
2. **Unary parser** handles prefix operators like negation
3. **Binary parser** handles infix operators, respecting precedence
4. **Specialized parsers** handle complex constructs (matrices, integrals, etc.)

---

## AST Node Types

The `Expression` class is a sealed base class. Each node type represents a different construct:

### Value Nodes

```dart
sealed class Expression {}

// A number like 3.14
class NumberLiteral extends Expression {
  final double value;
}

// A variable like x
class Variable extends Expression {
  final String name;
}

// The imaginary unit i
class ImaginaryUnit extends Expression {}
```

### Operator Nodes

```dart
// Binary operation: a + b, x * y, etc.
class BinaryOp extends Expression {
  final Expression left;
  final BinaryOperator operator;
  final Expression right;
}

// Unary operation: -x, !n (factorial)
class UnaryOp extends Expression {
  final UnaryOperator operator;
  final Expression operand;
}
```

### Function Nodes

```dart
// Function call: sin(x), sqrt(16)
class FunctionCall extends Expression {
  final String name;
  final Expression argument;
}

// Multi-argument function: max(a, b), gcd(12, 8)
class MultiArgFunctionCall extends Expression {
  final String name;
  final List<Expression> arguments;
}
```

### Calculus Nodes

```dart
// Integral: ∫ x² dx, ∫₀¹ x dx
class IntegralExpr extends Expression {
  final Expression integrand;
  final String variable;
  final Expression? lower;  // null for indefinite
  final Expression? upper;
}

// Derivative: d/dx(x²)
class DerivativeExpr extends Expression {
  final Expression expression;
  final String variable;
  final int order;  // 1 for first derivative, 2 for second, etc.
}

// Summation: ∑_{i=1}^{n} i²
class SumExpr extends Expression {
  final String variable;
  final Expression start;
  final Expression end;
  final Expression body;
}

// Limit: lim_{x→0} sin(x)/x
class LimitExpr extends Expression {
  final String variable;
  final Expression approach;
  final Expression body;
}
```

### Matrix Nodes

```dart
// Matrix: [[1, 2], [3, 4]]
class MatrixExpr extends Expression {
  final List<List<Expression>> rows;
}

// Vector: [1, 2, 3]
class VectorExpr extends Expression {
  final List<Expression> elements;
}
```

---

## Parsing LaTeX Constructs

### Fractions

`\frac{a}{b}` is parsed as:
```
BinaryOp(/)
  /    \
 a      b
```

The parser recognizes the `\frac` token, consumes two brace-delimited arguments, and creates a division node.

### Subscripts and Superscripts

`x^2` (superscript) becomes:
```
BinaryOp(^)
  /    \
x       2
```

`x_{i}` (subscript) creates a `Subscript` node. For expressions like `\log_{2}{8}`, the subscript indicates the base.

### Matrix Environments

```latex
\begin{pmatrix}
  1 & 2 \\
  3 & 4
\end{pmatrix}
```

The parser:
1. Recognizes `\begin{pmatrix}`
2. Parses expressions separated by `&` (columns) and `\\` (rows)
3. Creates a `MatrixExpr` with the row/column structure
4. Expects and consumes `\end{pmatrix}`

### Integrals

```latex
\int_{0}^{1} x^2 dx
```

The parser:
1. Recognizes `\int`
2. Parses optional `_{lower}^{upper}` bounds
3. Parses the integrand
4. Expects `dx`, `dt`, or similar to identify the integration variable
5. Creates an `IntegralExpr` node

---

## Error Recovery

The parser can operate in two modes:

### Strict Mode (Default)
Throws `ParserException` on first error. Used for normal evaluation.

### Recovery Mode
Attempts to recover from errors to report multiple issues. Used by `validate()`.

```dart
// Strict mode - throws on first error
evaluator.parse(r'\frac{1{2}');  // throws ParserException

// Recovery mode - collects multiple errors
final result = evaluator.validate(r'\frac{1{2} + \unknownfunc');
print(result.subErrors);  // May contain multiple errors
```

---

## Precedence and Associativity

### Why It Matters

Without precedence, `2 + 3 * 4` would be ambiguous. The parser enforces:
- `*` binds tighter than `+`, so it's parsed as `2 + (3 * 4) = 14`

### Right Associativity of Power

Exponentiation is right-associative:
- `2^3^4` = `2^(3^4)` = `2^81` ≈ 2.4 × 10²⁴

This matches mathematical convention. The AST reflects this:
```
   BinaryOp(^)
     /    \
    2    BinaryOp(^)
           /    \
          3      4
```

### Implicit Multiplication Precedence

Implicit multiplication has the same precedence as explicit multiplication:
- `2x^2` = `2 * (x^2)`, not `(2x)^2`
- `a/bc` = `a / (b * c)`, not `(a/b) * c`

This matches textbook conventions but can be surprising. When in doubt, use explicit parentheses.

---

## Recursion Depth Limit

The parser enforces a maximum recursion depth (default: 500) to prevent stack overflow on deeply nested expressions.

```dart
final evaluator = Texpr(maxRecursionDepth: 1000);  // Increase if needed
```

Expressions that exceed this limit throw `ParserException`:
```dart
// Very deep nesting like a^(b^(c^(d^(...))))
// will throw if it exceeds the limit
```

---

## Performance

Parsing is **O(n)** where n is the number of tokens. The recursive descent algorithm is efficient but:
- Complex expressions with many nested structures take longer
- Matrix parsing is O(rows × columns × element complexity)

For repeated evaluation, **parse once**:

```dart
// Good: Parse once, evaluate many times
final ast = evaluator.parse(r'\sin{x} + \cos{x}');
for (var x = 0.0; x < 100; x += 0.1) {
  evaluator.evaluateParsed(ast, {'x': x});
}

// Bad: Re-parses every iteration
for (var x = 0.0; x < 100; x += 0.1) {
  evaluator.evaluate(r'\sin{x} + \cos{x}', {'x': x});  // Parses each time!
}
```

(Note: L1 cache mitigates the "bad" case, but explicit caching is more predictable.)

---

## Summary

The parser:
1. Consumes tokens from the tokenizer
2. Builds a tree structure (AST) representing expression structure
3. Enforces operator precedence and associativity
4. Handles special LaTeX constructs (fractions, matrices, calculus)
5. Provides error recovery for validation

The AST is then processed by the [Evaluator](./evaluator.md) to compute results.
