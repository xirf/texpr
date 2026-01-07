# Formal Grammar Specification

This document provides a precise specification of the LaTeX subset accepted by TeXpr. Understanding this grammar is essential for predicting parsing behavior and handling edge cases.

## Grammar Notation

This specification uses **Extended Backus-Naur Form (EBNF)** with these conventions:

| Notation    | Meaning                |
| ----------- | ---------------------- |
| `→`         | Production rule        |
| `           | `                      | Alternative |
| `[ ... ]`   | Optional (0 or 1)      |
| `{ ... }`   | Repetition (0 or more) |
| `( ... )`   | Grouping               |
| `'...'`     | Literal token          |
| `CAPS`      | Terminal token type    |
| `lowercase` | Non-terminal           |

---

## Lexical Grammar (Tokenization)

### Character Classes

```text
digit       → '0'..'9'
letter      → 'a'..'z' | 'A'..'Z'
greek       → 'α'..'ω' | 'Α'..'Ω'
whitespace  → ' ' | '\t' | '\n' | '\r'
```

### Token Definitions

```text
NUMBER      → digit { digit } [ '.' digit { digit } ] [ ('e'|'E') ['+'|'-'] digit { digit } ]
            | '.' digit { digit }

VARIABLE    → letter | greek

OPERATOR    → '+' | '-' | '*' | '/' | '^' | '×' | '÷' | '·'

COMPARISON  → '<' | '>' | '≤' | '≥' | '=' | '≠' | '≈' | '∈'

DELIMITER   → '(' | ')' | '{' | '}' | '[' | ']' | '|' | ',' | '&'

COMMAND     → '\' letter { letter }
```

### Token Types

| Token Type   | Examples                | Description                  |
| ------------ | ----------------------- | ---------------------------- |
| `NUMBER`     | `3.14`, `1e-5`, `.5`    | Numeric literals             |
| `VARIABLE`   | `x`, `y`, `α`, `θ`      | Single-character identifiers |
| `FUNCTION`   | `\sin`, `\cos`, `\log`  | Known function commands      |
| `CONSTANT`   | `\pi`, `\tau`, `e`      | Mathematical constants       |
| `OPERATOR`   | `+`, `-`, `*`, `/`, `^` | Arithmetic operators         |
| `LPAREN`     | `(`, `{`                | Opening delimiters           |
| `RPAREN`     | `)`, `}`                | Closing delimiters           |
| `LBRACKET`   | `[`                     | Left bracket                 |
| `RBRACKET`   | `]`                     | Right bracket                |
| `UNDERSCORE` | `_`                     | Subscript marker             |

---

## Syntactic Grammar (Parsing)

### Top-Level Productions

```text
program         → assignment
                | function_def
                | expression [ ',' condition ]

assignment      → 'let' VARIABLE '=' expression

function_def    → VARIABLE '(' param_list ')' '=' expression

param_list      → VARIABLE { ',' VARIABLE }
```

### Expression Hierarchy

Expressions are parsed with the following precedence (lowest to highest):

```text
expression      → comparison

comparison      → additive { comparison_op additive }

additive        → multiplicative { ('+'|'-') multiplicative }

multiplicative  → unary { ('*'|'/'|IMPLICIT) unary }

unary           → '-' unary
                | power

power           → primary [ '^' power ]   (* right-associative *)

primary         → atom
                | function_call
                | calculus_expr
                | matrix_expr
                | '(' expression ')'
                | '{' expression '}'
                | '|' expression '|'
```

### Atoms

```text
atom            → NUMBER
                | VARIABLE [ subscript ]
                | CONSTANT
                | 'i'

subscript       → '_' ( VARIABLE | NUMBER | '{' expression '}' )
```

### Function Calls

```text
function_call   → FUNCTION argument
                | FUNCTION '^' power_arg argument
                | '\frac' '{' expression '}' '{' expression '}'
                | '\sqrt' [ '[' expression ']' ] '{' expression '}'
                | '\binom' '{' expression '}' '{' expression '}'

argument        → '{' expression '}'
                | '(' expression ')'
                | atom

power_arg       → '{' expression '}'
                | NUMBER
```

### Calculus Expressions

```text
calculus_expr   → integral
                | derivative
                | limit
                | summation
                | product
                | gradient

integral        → integral_sym [ bounds ] integrand differential

integral_sym    → '\int' | '\iint' | '\iiint' | '\oint'

bounds          → '_' '{' expression '}' '^' '{' expression '}'

integrand       → expression

differential    → 'd' VARIABLE
                | '\mathrm{d}' VARIABLE

derivative      → '\frac' '{' 'd' [ '^' NUMBER ] '}' '{' 'd' VARIABLE [ '^' NUMBER ] '}' expression
                | '\frac' '{' '\partial' [ '^' NUMBER ] '}' '{' '\partial' VARIABLE [ '^' NUMBER ] '}' expression

limit           → '\lim' '_' '{' VARIABLE '\to' expression '}' expression

summation       → '\sum' '_' '{' VARIABLE '=' expression '}' '^' '{' expression '}' '{' expression '}'

product         → '\prod' '_' '{' VARIABLE '=' expression '}' '^' '{' expression '}' '{' expression '}'

gradient        → '\nabla' '{' expression '}'
```

### Matrix Expressions

```text
matrix_expr     → '\begin{' matrix_env '}' matrix_content '\end{' matrix_env '}'

matrix_env      → 'matrix' | 'pmatrix' | 'bmatrix' | 'vmatrix' | 'cases' | 'align'

matrix_content  → matrix_row { '\\' matrix_row }

matrix_row      → expression { '&' expression }
```

### Comparison Operators

```text
comparison_op   → '<' | '>' | '\leq' | '\geq' | '=' | '\neq' | '\approx' | '\in'
```

---

## Operator Precedence and Associativity

| Level       | Operators                    | Associativity  | Example             |
| ----------- | ---------------------------- | -------------- | ------------------- |
| 1 (lowest)  | `=`, `<`, `>`, `≤`, `≥`, `≈` | Left           | `a < b < c`         |
| 2           | `+`, `-`                     | Left           | `a + b - c`         |
| 3           | `*`, `/`, `×`, `÷`, implicit | Left           | `a * b / c`         |
| 4           | Unary `-`                    | Right (prefix) | `--x` = `-(-x)`     |
| 5 (highest) | `^`                          | Right          | `a^b^c` = `a^(b^c)` |

### Right Associativity of Power

Exponentiation is right-associative, matching mathematical convention:

```
2^3^4 = 2^(3^4) = 2^81 ≈ 2.4 × 10²⁴
```

Not:
```
(2^3)^4 = 8^4 = 4096
```

---

## Implicit Multiplication

When `allowImplicitMultiplication` is enabled (default), multiplication is inferred between certain adjacent tokens:

### Insertion Rules

| Pattern           | Becomes             | Example                 |
| ----------------- | ------------------- | ----------------------- |
| NUMBER VARIABLE   | NUMBER * VARIABLE   | `2x` → `2*x`            |
| NUMBER FUNCTION   | NUMBER * FUNCTION   | `2\sin{x}` → `2*sin(x)` |
| VARIABLE VARIABLE | VARIABLE * VARIABLE | `xy` → `x*y`            |
| RPAREN LPAREN     | RPAREN * LPAREN     | `(a)(b)` → `(a)*(b)`    |
| RPAREN VARIABLE   | RPAREN * VARIABLE   | `(a)b` → `(a)*b`        |
| VARIABLE LPAREN   | VARIABLE * LPAREN   | `x(a+b)` → `x*(a+b)`    |
| NUMBER LPAREN     | NUMBER * LPAREN     | `2(x+1)` → `2*(x+1)`    |

### Precedence

Implicit multiplication has the **same precedence** as explicit multiplication:

```
2x^2 = 2 * (x^2)    ✓
(2x)^2              ✗ (not this)

a/bc = a / (b * c)  ✓
(a/b) * c           ✗ (not this)
```

---

## Ambiguity Resolution

### Greedy Tokenization

The tokenizer is **greedy**: it always matches the longest possible token.

```
\sinx    → FUNCTION(sin), VARIABLE(x)    ✓
\sin, x  ✗ (not two separate tokens)
```

### Function Argument Binding

Functions bind tightly to their immediate argument:

```
\sin x^2 = sin(x^2)     ✓  (function power notation)
\sin{x}^2 = (sin(x))^2  ✓  (standard)
```

### Subscript Variables

Subscripts create variable names with underscores:

```
x_0     → Variable("x_0")
R_{crit} → Variable("R_crit")
```

When evaluating, provide `{'x_0': value}` or `{'R_crit': value}`.

---

## Supported LaTeX Subset

### Explicitly Supported

- Basic arithmetic: `+`, `-`, `*`, `/`, `^`
- Fractions: `\frac{a}{b}`
- Roots: `\sqrt{x}`, `\sqrt[n]{x}`
- Trigonometric: `\sin`, `\cos`, `\tan`, `\cot`, `\sec`, `\csc`
- Inverse trig: `\arcsin`, `\arccos`, `\arctan`
- Hyperbolic: `\sinh`, `\cosh`, `\tanh`
- Logarithmic: `\ln`, `\log`, `\log_{b}`
- Calculus: `\int`, `\sum`, `\prod`, `\lim`, `\frac{d}{dx}`, `\nabla`
- Matrices: `\begin{pmatrix}...\end{pmatrix}`
- Constants: `\pi`, `\tau`, `e`, `i`, `\infty`
- Greek letters: `\alpha` through `\omega`

### Explicitly NOT Supported

> [!IMPORTANT]
> These LaTeX commands are outside TeXpr's scope and will produce errors:

- **Document commands**: `\documentclass`, `\usepackage`, `\title`
- **Environments**: `\begin{equation}`, `\begin{theorem}`
- **Text formatting**: `\textit`, `\textbf` (except inside `\text{}`)
- **Macros**: `\newcommand`, `\def`
- **Labels/refs**: `\label`, `\ref`, `\eqref`
- **Display math**: `$$...$$`, `\[...\]` (implicit, parse content directly)

---

## Error Conditions

The parser will reject:

| Condition             | Example                    | Error Type         |
| --------------------- | -------------------------- | ------------------ |
| Unbalanced delimiters | `(x + 1`                   | ParserException    |
| Unknown commands      | `\unknownfunc{x}`          | TokenizerException |
| Missing arguments     | `\frac{1}`                 | ParserException    |
| Invalid syntax        | `+ + 1`                    | ParserException    |
| Recursion overflow    | `(((((...))))` (500+ deep) | ParserException    |

See [Exceptions](./exceptions.md) for the full error taxonomy.

---

## Formal Properties

### Decidability

- **Parsing is decidable**: Every input either parses successfully or produces a well-defined error.
- **Time complexity**: O(n) where n is input length (recursive descent, single pass).

### Determinism

- **Lexer is deterministic**: Each character sequence maps to exactly one token sequence.
- **Parser is deterministic**: Each token sequence has at most one valid parse tree.

### Limitations

- **Not context-free in the Chomsky sense**: Implicit multiplication and subscript handling add context-sensitivity.
- **Not LR(1)**: The lookahead requirements for function definitions vs. function calls require LL-style parsing.

---

## Version History

| Version | Changes                                                                  |
| ------- | ------------------------------------------------------------------------ |
| 0.2.0   | Added `let` assignments, function definitions, piecewise `\begin{cases}` |
| 0.1.0   | Initial grammar specification                                            |
