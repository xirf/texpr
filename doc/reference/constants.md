# Built-in Constants

Constants are used as fallback when a variable is not provided by the user.

## Available Constants

| Name    | Symbol | Value            | Description            |
| ------- | ------ | ---------------- | ---------------------- |
| `hbar`  | ℏ      | 1.054571817e-34  | Reduced Planck (J·s)   |
| `e`     | e      | 2.71828182845905 | Euler's number         |
| `pi`    | π      | 3.14159265358979 | Pi                     |
| `tau`   | τ      | 6.28318530717959 | 2 * π                  |
| `phi`   | φ      | 1.61803398874989 | Golden ratio           |
| `gamma` | γ      | 0.57721566490153 | Euler-Mascheroni       |
| `Omega` | Ω      | 0.56714329040978 | Lambda W constant      |
| `delta` | δ      | 2.41421356237310 | Silver ratio (1+√2)    |
| `G`     | G      | 6.67430e-11      | Gravitational constant |
| `zeta3` | ζ(3)   | 1.20205690315959 | Apéry's constant       |
| `infty` | ∞      | ∞                | Infinity               |
| `sqrt2` | √2     | 1.41421356237310 | Square root of 2       |
| `sqrt3` | √3     | 1.73205080756888 | Square root of 3       |
| `ln2`   | ln(2)  | 0.69314718055995 | Natural log of 2       |
| `ln10`  | ln(10) | 2.30258509299405 | Natural log of 10      |

## Usage

Constants can be accessed using their standard LaTeX commands or as variables:

```dart
final evaluator = Texpr();

// LaTeX command notation (Recommended for multi-character)
evaluator.evaluateNumeric(r'\hbar');  // 1.05457...
evaluator.evaluateNumeric(r'\pi');     // 3.14159...

// Variable name notation
evaluator.evaluateNumeric('pi');  // 3.14159... (if allowImplicitMultiplication is false)
evaluator.evaluateNumeric('e');   // 2.71828...
```

> [!TIP]
> Always use the backslash notation (e.g., `\pi`, `\hbar`) for multi-character constants to avoid ambiguity with implicit multiplication of single-letter variables.

## Overriding Constants

User-provided variables override built-in constants by default:

```dart
// Override 'e' with custom value
e.evaluate('e', {'e': 3.0});  // 3.0

// Constant used when variable not provided
e.evaluate('e');  // 2.71828...
```

## Multi-character Constants

Multi-character constant names (like `pi`, `phi`) require using them as variable bindings since the parser only reads single characters:

```dart
// Bind pi value to a single-letter variable
e.evaluate(r'\sin{p}', {'p': 3.14159});  // ~0
```
