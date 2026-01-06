# Tokenizer

The tokenizer is the first stage of the processing pipeline. It transforms a raw LaTeX string into a stream of **tokens** — discrete units that the parser can work with.

## What Is a Token?

A token is a meaningful unit extracted from the input. For example:

| Input  | Token Type | Value |
| ------ | ---------- | ----- |
| `3.14` | NUMBER     | 3.14  |
| `x`    | VARIABLE   | x     |
| `\sin` | FUNCTION   | sin   |
| `+`    | OPERATOR   | add   |
| `{`    | LBRACE     | -     |
| `^`    | OPERATOR   | power |

The tokenizer doesn't understand structure — it just identifies what each piece of text represents.

---

## How Tokenization Works

The tokenizer reads the input character by character, applying these rules in order:

### 1. Skip Whitespace
Spaces, tabs, and newlines are consumed but produce no tokens. This is why `2+3` and `2 + 3` parse identically.

### 2. Recognize Numbers
When a digit or decimal point is encountered, the tokenizer greedily consumes the entire number:
```
"3.14159" → NUMBER(3.14159)
"1e-5"    → NUMBER(0.00001)
".5"      → NUMBER(0.5)
```

### 3. Recognize Operators
Single characters that are operators produce operator tokens:
```
"+"  → OPERATOR(add)
"-"  → OPERATOR(subtract)
"*"  → OPERATOR(multiply)
"/"  → OPERATOR(divide)
"^"  → OPERATOR(power)
"="  → OPERATOR(equals)
```

### 4. Recognize LaTeX Commands
When `\` is encountered, the tokenizer reads the command name:
```
"\sin"    → FUNCTION(sin)
"\frac"   → FUNCTION(frac)
"\pi"     → CONSTANT(π)
"\alpha"  → VARIABLE(α)
```

The tokenizer maintains a registry of known commands. Unknown commands produce an error with suggestions for similar commands.

### 5. Recognize Identifiers
Single letters (when not part of a LaTeX command) become variables:
```
"x"  → VARIABLE(x)
"y"  → VARIABLE(y)
```

Multi-character sequences like `xy` are handled specially — see Implicit Multiplication below.

---

## Implicit Multiplication

One of TeXpr's key features is **implicit multiplication** — the ability to write `2x` instead of `2*x`. This is how textbook notation works.

### How It Works

When `allowImplicitMultiplication` is enabled (the default), the tokenizer inserts multiplication tokens between certain adjacent tokens:

| Input           | Tokens Produced                                                     |
| --------------- | ------------------------------------------------------------------- |
| `2x`            | NUMBER(2), OPERATOR(*), VARIABLE(x)                                 |
| `xy`            | VARIABLE(x), OPERATOR(*), VARIABLE(y)                               |
| `\sin x \cos x` | FUNCTION(sin), VARIABLE(x), OPERATOR(*), FUNCTION(cos), VARIABLE(x) |
| `(a+b)(c+d)`    | ..., RPAREN, OPERATOR(*), LPAREN, ...                               |

### The Rules

Implicit multiplication is inserted when:
1. **Number followed by variable**: `2x` → `2 * x`
2. **Number followed by function**: `2\sin{x}` → `2 * sin(x)`
3. **Variable followed by variable**: `xy` → `x * y`
4. **Closing paren followed by opening paren**: `(a)(b)` → `(a) * (b)`
5. **Closing paren followed by variable/number**: `(a)b` → `(a) * b`
6. **Variable followed by opening paren**: `x(a+b)` → `x * (a+b)`

### When to Disable It

Disable implicit multiplication when you need multi-character variable names:

```dart
final evaluator = Texpr(allowImplicitMultiplication: false);
// Now "velocity" is a single variable, not v*e*l*o*c*i*t*y
evaluator.evaluate('velocity * time', {'velocity': 10, 'time': 5});
```

---

## Token Types

The complete list of token types:

| Type              | Examples       | Purpose                 |
| ----------------- | -------------- | ----------------------- |
| `NUMBER`          | 3.14, 1e-5, .5 | Numeric literals        |
| `VARIABLE`        | x, y, α, β     | Variable references     |
| `FUNCTION`        | sin, cos, sqrt | Function names          |
| `CONSTANT`        | π, e, ∞        | Mathematical constants  |
| `OPERATOR`        | +, -, *, /, ^  | Binary operators        |
| `LBRACE`          | {              | Opening brace           |
| `RBRACE`          | }              | Closing brace           |
| `LPAREN`          | (              | Opening parenthesis     |
| `RPAREN`          | )              | Closing parenthesis     |
| `LBRACKET`        | [              | Opening bracket         |
| `RBRACKET`        | ]              | Closing bracket         |
| `COMMA`           | ,              | Argument separator      |
| `UNDERSCORE`      | _              | Subscript marker        |
| `AMPERSAND`       | &              | Matrix column separator |
| `DOUBLEBACKSLASH` | \\\\           | Matrix row separator    |
| `EOF`             | (end)          | End of input            |

---

## Error Handling

When the tokenizer encounters invalid input, it throws a `TokenizerException` with:
- **Position**: The character index where the error occurred
- **Message**: What went wrong
- **Suggestion**: How to fix it

```dart
try {
  evaluator.parse(r'\unknowncommand{x}');
} on TokenizerException catch (e) {
  print(e.position);    // 0
  print(e.message);     // "Unknown command: unknowncommand"
  print(e.suggestion);  // "Did you mean 'sin', 'cos', or 'tan'?"
}
```

Common errors:
- Unknown LaTeX command
- Invalid character
- Malformed number (e.g., `1.2.3`)

---

## Unicode Support

The tokenizer accepts Unicode mathematical symbols directly:

| Unicode          | Equivalent LaTeX               | Token          |
| ---------------- | ------------------------------ | -------------- |
| `π`              | `\pi`                          | CONSTANT(π)    |
| `∑`              | `\sum`                         | FUNCTION(sum)  |
| `∫`              | `\int`                         | FUNCTION(int)  |
| `√`              | `\sqrt`                        | FUNCTION(sqrt) |
| `α`, `β`, `γ`... | `\alpha`, `\beta`, `\gamma`... | VARIABLE       |
| `∞`              | `\infty`                       | CONSTANT(∞)    |

This allows copy-pasting mathematical expressions from documents.

---

## Extending the Tokenizer

You can register custom commands via `ExtensionRegistry`:

```dart
final registry = ExtensionRegistry();
registry.registerCommand('myfunction', (cmd, pos) =>
  Token(type: TokenType.function, value: 'myfunction', position: pos)
);

final evaluator = Texpr(extensions: registry);
```

The registered command becomes available as `\myfunction` in expressions.

---

## Performance Considerations

Tokenization is **O(n)** where n is the input length. It's a single pass with no backtracking.

The bottleneck is usually:
- Large expressions (thousands of characters)
- Many LaTeX commands (each requires a lookup)

For repeated evaluation of the same expression, use `parse()` once and `evaluateParsed()` multiple times — this skips tokenization on subsequent calls.

---

## Summary

The tokenizer:
1. Reads input character-by-character
2. Produces a stream of typed tokens
3. Handles implicit multiplication
4. Recognizes LaTeX commands, Unicode symbols
5. Reports errors with position and suggestions

The tokens are then consumed by the [Parser](./parser.md) to build the AST.
