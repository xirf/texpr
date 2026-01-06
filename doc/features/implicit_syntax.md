# Implicit vs. Explicit Syntax

The parser supports both strict LaTeX syntax and "implicit" syntax common in informal math inputs.

## Implicit Multiplication

By default, the parser enables **implicit multiplication**. This affects how variable names and adjacent terms are handled.

### Enabled (Default)

When enabled, adjacent terms are multiplied, and single letters are treated as variables unless wrapped in braces.

- `2x` to `2 * x`
- `ab` to `a * b` (Variables `a` and `b`)
- `(a+b)(a-b)` to `(a+b) * (a-b)`
- `sin(x)` to `\sin(x)` (Function recognition)
- `sinx` to `s * i * n * x` (If not followed by `(`)

### Disabled

This behavior can be disabled by setting `Tokenizer(allowImplicitMultiplication: false)`. When disabled, the parser will treat adjacent letters as a single variable name.

- `ab` to Variable named `ab`
- `count` to Variable named `count`
- Implicit multiplication `2x` might not be parsed or treated differently depending on context.

## Syntax Tolerance

To support user-friendly input, the parser allows some relaxed syntax forms even when strictly parsing LaTeX.

### Braceless Fractions
Standard LaTeX requires braces: `\frac{1}{2}`.
The parser also accepts:
- `\frac12` to `\frac{1}{2}` (Exactly two single digits/variables)
- `\frac1x` to `\frac{1}{x}`

*Ambiguous cases like `\frac123` are rejected to avoid confusion (is it `1/23` or `12/3`?).*

### Prefix-less Functions
Standard LaTeX requires a backslash: `\sin{x}`.
The parser accepts:
- `sin(x)` to `\sin{x}`
- `cos(x)` to `\cos{x}`

*This only applies when the function name is immediately followed by `(`.*
