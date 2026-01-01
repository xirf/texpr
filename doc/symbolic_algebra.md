# Symbolic Algebra System

The `texpr` package includes a powerful symbolic algebra engine capable of expression simplification, expansion, and domain-aware transformations.

## Core Components

### 1. `SymbolicEngine`

The central entry point for all symbolic operations. It manages the rule engine and assumptions.

```dart
final engine = SymbolicEngine();

// Simplification
final simplified = engine.simplify(expr);

// Expansion
final expanded = engine.expand(expr);

// Factorization
final factored = engine.factor(expr);
```

### 2. `Assumptions` System

Many mathematical rules are only valid under certain domain constraints. For example, `sqrt(x^2)` is only equal to `x` if `x >= 0`. Without this knowledge, the engine safely simplifies it to `|x|`.

You can provide global assumptions to the engine to enable more aggressive (but still correct) simplifications.

```dart
final engine = SymbolicEngine();

// sqrt(x^2) -> |x|
print(engine.simplify(expr).toLatex());

// Add assumption
engine.assume('x', Assumption.nonNegative);

// sqrt(x^2) -> x
print(engine.simplify(expr).toLatex());
```

#### Supported Assumptions:

- `Assumption.real`: Variable is a real number.
- `Assumption.integer`: Variable is an integer.
- `Assumption.positive`: Variable is > 0 (implies non-negative and real).
- `Assumption.nonNegative`: Variable is >= 0 (implies real).
- `Assumption.negative`: Variable is < 0 (implies real).
- `Assumption.nonPositive`: Variable is <= 0 (implies real).

### 3. `RewriteRule`

The engine uses a rule-based system. Each rule is a subclass of `RewriteRule` that defines when it `matches` and how it should `apply` a transformation.

#### Categories:

- `RuleCategory.simplification`: Rules that reduce complexity (e.g., `x + 0 -> x`).
- `RuleCategory.expansion`: Rules that expand terms (e.g., `(a+b)^2 -> a^2 + 2ab + b^2`).
- `RuleCategory.normalization`: Internal rules for canonical forms.

## Key Symbolic Features

### Trigonometric Identities

The engine recognizes standard trigonometric identities:

- **Pythagorean**: `sin²(x) + cos²(x) = 1`
- **Double Angle**: `sin(2x) = 2 sin(x) cos(x)`
- **Half Angle**: `sin(x/2) = sqrt((1-cos(x))/2)`
- **Parity**: `sin(-x) = -sin(x)`, `cos(-x) = cos(x)`

### Logarithm Laws

- `log(a*b) = log(a) + log(b)`
- `log(a/b) = log(a) - log(b)`
- `log(a^b) = b*log(a)` (Domain-aware: strictly `a > 0` or even power)

### Arithmetic Simplification

- Constant folding (e.g., `2 + 3 -> 5`)
- Identity elements (e.g., `x * 1 -> x`, `x + 0 -> x`)
- Dominant elements (e.g., `x * 0 -> 0`)
- Combining like terms (e.g., `x + 2x -> 3x`)
- Power rules (e.g., `(x^a)^b -> x^(a*b)`)

## Extending the Engine

You can create custom rewrite rules by implementing the `RewriteRule` interface and adding them to the `RuleEngine`.

```dart
class MyCustomRule extends RewriteRule {
  @override
  String get name => 'my_rule';

  @override
  RuleCategory get category => RuleCategory.simplification;

  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
     // Your logic here
     return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
     // Your transformation here
     return expr;
  }
}
```
