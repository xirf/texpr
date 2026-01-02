# Symbolic Algebra Engine

The symbolic algebra engine provides capabilities for manipulating mathematical expressions symbolically, beyond simple numeric evaluation.

## Overview

The `SymbolicEngine` class is the main entry point for symbolic operations. It provides:

- **Expression Simplification**: Applies algebraic rules to simplify expressions
- **Polynomial Expansion**: Expands expressions like `(x+1)²` to `x² + 2x + 1`
- **Polynomial Factorization**: Factors expressions like `x² - 4` to `(x-2)(x+2)`
- **Trigonometric Identities**: Applies trig identities like `sin²(x) + cos²(x) = 1`
- **Logarithm Laws**: Applies log rules like `log(ab) = log(a) + log(b)`
- **Rational Simplification**: Simplifies fractions
- **Expression Equivalence**: Tests if two expressions are mathematically equivalent
- **Equation Solving**: Solves linear and quadratic equations

## Usage

### Basic Simplification

```dart
import 'package:texpr/texpr.dart';

final engine = SymbolicEngine();
final evaluator = Texpr();

// Parse an expression
final expr = evaluator.parse('0 + x');
final simplified = engine.simplify(expr);
// Result: Variable(x)
```

### Polynomial Expansion

The engine can expand polynomial expressions using the binomial theorem:

```dart
// (x+1)² → x² + 2x + 1
final expr = evaluator.parse('(x+1)^{2}');
final expanded = engine.expand(expr);

// (x+2)³ → x³ + 6x² + 12x + 8
final expr2 = evaluator.parse('(x+2)^{3}');
final expanded2 = engine.expand(expr2);
```

- **Supported patterns:**
- `(a+b)^n` for integer n ≤ 10
- `(a-b)^n` for integer n ≤ 10
- `(a+b)(c+d)` distributive property

### Polynomial Factorization

Factor polynomial expressions into products:

```dart
// x² - 4 → (x-2)(x+2)
final expr = evaluator.parse('x^{2} - 4');
final factored = engine.factor(expr);

// x² - 1 → (x-1)(x+1)
final expr2 = evaluator.parse('x^{2} - 1');
final factored2 = engine.factor(expr2);
```

**Supported patterns:**
- Difference of squares: `a² - b²` → `(a-b)(a+b)`
- Simple quadratics: `x² + bx + c` (when factorable with integer roots)

### Trigonometric Identities

The engine recognizes and applies fundamental trig identities:

```dart
// Pythagorean identity
final sinX = FunctionCall('sin', Variable('x'));
final sin2X = BinaryOp(sinX, BinaryOperator.power, const NumberLiteral(2));
final cosX = FunctionCall('cos', Variable('x'));
final cos2X = BinaryOp(cosX, BinaryOperator.power, const NumberLiteral(2));
final pythagorean = BinaryOp(sin2X, BinaryOperator.add, cos2X);

final simplified = engine.simplify(pythagorean);
// Result: NumberLiteral(1)
```

**Supported identities:**
- `sin²(x) + cos²(x) = 1` (Pythagorean identity)
- `sin(0) = 0`, `cos(0) = 1`, `tan(0) = 0`
- `sin(-x) = -sin(x)` (odd function)
- `cos(-x) = cos(x)` (even function)
- `sin(2x) = 2*sin(x)*cos(x)` (double-angle formula)
- `cos(2x) = cos²(x) - sin²(x)` (double-angle formula)
- `tan(2x) = 2*tan(x) / (1 - tan²(x))` (double-angle formula)
- `sin(x/2) = √((1-cos(x))/2)` (half-angle formula)
- `cos(x/2) = √((1+cos(x))/2)` (half-angle formula)
- `tan(x/2) = sin(x)/(1+cos(x))` (half-angle formula)

### Logarithm Laws

Apply logarithm rules to simplify expressions:

```dart
// log(x²) → 2*log(x)
final x2 = BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
final logX2 = FunctionCall('log', x2);
final simplified = engine.simplify(logX2);
```

**Supported laws:**
- `log(ab) = log(a) + log(b)` (product rule)
- `log(a/b) = log(a) - log(b)` (quotient rule)
- `log(a^b) = b*log(a)` (power rule)
- `log(1) = 0`
- `ln(e) = 1`, `log10(10) = 1`

Works with `log`, `ln`, `log10`, and `log2` functions.

### Rational Expression Simplification

Simplify fractions and rational expressions:

```dart
// x/x → 1
final expr = BinaryOp(Variable('x'), BinaryOperator.divide, Variable('x'));
final simplified = engine.simplify(expr);

// (2x)/x → 2
final twoX = BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
final expr2 = BinaryOp(twoX, BinaryOperator.divide, Variable('x'));
final simplified2 = engine.simplify(expr2);
```

**Capabilities:**
- Cancel common factors: `(ab)/b = a`
- Simplify numeric fractions using GCD
- Handle complex nested fractions

### Basic Algebraic Simplification Rules

The engine automatically applies fundamental rules:

**Identity operations:**
- `0 + x = x`, `x + 0 = x`
- `1 * x = x`, `x * 1 = x`
- `x^1 = x`, `x^0 = 1`
- `x / 1 = x`

**Zero operations:**
- `0 * x = 0`, `x * 0 = 0`
- `x - x = 0`
- `x / x = 1`

**Negation:**
- `0 - x = -x`
- `--x = x` (double negation)
- `(-1) * x = -x`

**Constant folding:**
- `2 + 3 = 5`
- `4 * 5 = 20`
- `2^3 = 8`

**Like terms:**
- `x + x = 2x`
- `x * x = x²`

### Expression Equivalence Testing

Test if two expressions are mathematically equivalent:

```dart
final expr1 = evaluator.parse('(x+1)^{2}');
final expr2 = evaluator.parse('x^{2} + 2x + 1');

final equivalent = engine.areEquivalent(expr1, expr2);
// Result: true (after simplification)
```

The equivalence test works by simplifying both expressions and comparing their structure.

### Equation Solving

Solve linear and quadratic equations:

```dart
// Solve linear equation: 2x + 4 = 0
final twoX = BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
final equation = BinaryOp(twoX, BinaryOperator.add, const NumberLiteral(4));
final solution = engine.solveLinear(equation, 'x');
// Result: NumberLiteral(-2)

// Solve quadratic equation: x² - 4 = 0
final xSquared = BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
final equation = BinaryOp(xSquared, BinaryOperator.subtract, const NumberLiteral(4));
final solutions = engine.solveQuadratic(equation, 'x');
// Result: [NumberLiteral(2), NumberLiteral(-2)]

// Symbolic quadratic: x² + bx + c = 0
// Returns symbolic solutions using the quadratic formula
```

**Capabilities:**
- Linear equations of the form `ax + b = 0`
- Quadratic equations of the form `ax² + bx + c = 0`
- Symbolic solutions when coefficients are variables
- Handles special cases (double roots, no real solutions)

## Architecture

The symbolic engine is composed of several specialized components:

### Components

1. **Simplifier** (`simplifier.dart`)
   - Core algebraic simplification rules
   - Constant folding
   - Identity operations

2. **PolynomialOperations** (`polynomial_operations.dart`)
   - Binomial expansion using binomial theorem
   - Difference of squares factorization
   - Quadratic factorization

3. **TrigIdentities** (`trig_identities.dart`)
   - Pythagorean identity recognition
   - Even/odd function properties
   - Special angle values

4. **LogarithmLaws** (`logarithm_laws.dart`)
   - Product, quotient, and power rules
   - Special value simplifications

5. **RationalSimplifier** (`rational_simplifier.dart`)
   - Common factor cancellation
   - GCD-based fraction reduction

### Simplification Process

The engine applies simplifications iteratively in this order:

1. Basic algebraic simplification
2. Trigonometric identities
3. Logarithm laws
4. Rational expression simplification
5. Polynomial simplification

This continues until no further simplifications are possible (fixed point), with a maximum of 100 iterations to prevent infinite loops.

## Limitations

Current limitations to be aware of:

1. **Polynomial expansion**: Supports integer exponents up to 10
2. **Factorization**: Limited to difference of squares and simple quadratics with integer roots
3. **Equation solving**: Supports linear and quadratic; higher-order polynomials not yet supported
4. **Commutativity**: Some commutative equivalences (like `x+1` vs `1+x`) may not be recognized structurally
5. **Trigonometric**: Supports Pythagorean, double-angle, and half-angle formulas; sum-to-product formulas not yet implemented
6. **Logarithms**: Works on logarithm of a single argument; doesn't handle multi-argument logarithms

## Testing

The symbolic algebra engine has test coverage comprising 72+ test cases covering:

- 18 basic simplification rules
- 5 constant folding operations
- 4 polynomial expansions
- 3 polynomial factorizations
- 14 trigonometric identities (including double-angle and half-angle formulas)
- 9 logarithm laws
- 6 rational simplifications
- 2 expression equivalence tests
- 7 equation solving tests (linear and quadratic)
- 7 additional edge cases

Run tests with:

```bash
flutter test test/features/symbolic_algebra_test.dart
```

## Examples

See these examples for working demonstrations:
- [`example/features/symbolic_algebra_demo.dart`](../../example/features/symbolic_algebra_demo.dart) - General symbolic algebra
- [`example/features/equation_solving_demo.dart`](../../example/features/equation_solving_demo.dart) - Equation solving

## Future Enhancements

Planned improvements:

- [ ] Full symbolic equation solving (systems, higher-order polynomials)
- [x] More trigonometric identities (double-angle and half-angle formulas implemented)
- [ ] Sum-to-product and product-to-sum formulas
- [ ] Partial fraction decomposition
- [ ] Symbolic differentiation integration
- [ ] Symbolic integration (basic)
- [ ] Matrix symbolic operations
- [ ] Improved pattern matching for commutativity and associativity
- [ ] Support for more complex polynomial factorizations
- [ ] Symbolic limits
- [ ] Series expansion

## API Reference

### SymbolicEngine

**Constructor:**
```dart
SymbolicEngine()
```

**Methods:**

- `Expression simplify(Expression expr)`
  - Simplifies an expression using all available rules
  - Returns a simplified expression

- `Expression expand(Expression expr)`
  - Expands polynomial expressions
  - Returns the expanded form

- `Expression factor(Expression expr)`
  - Factors polynomial expressions
  - Returns the factored form or original if not factorable

- `bool areEquivalent(Expression expr1, Expression expr2)`
  - Tests if two expressions are equivalent after simplification
  - Returns true if equivalent

- `Expression? solveLinear(Expression equation, String variable)`
  - Solves a linear equation for the given variable
  - Returns the solution or null if not solvable

- `List<Expression> solveQuadratic(Expression equation, String variable)`
  - Solves a quadratic equation using the quadratic formula
  - Returns a list of 0, 1, or 2 solutions
