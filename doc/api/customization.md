# Customization API

## ExtensionRegistry

The `ExtensionRegistry` allows you to extend the evaluator with custom commands and functions.

### Methods

#### `registerCommand`

```dart
void registerCommand(String command, CommandTokenizer handler)
```

Registers a custom LaTeX command. The `CommandTokenizer` callback should consume the command and return a `Token`.

#### `registerEvaluator`

```dart
void registerEvaluator(CustomEvaluator handler)
```

Registers a custom evaluator function. The handler is called during evaluation and can intercept specific expressions.

### Usage Example

```dart
final registry = ExtensionRegistry();

registry.registerCommand('custom', (cmd, pos) {
  return Token(type: TokenType.function, value: 'custom', position: pos);
});

registry.registerEvaluator((expr, vars, eval) {
  if (expr is FunctionCall && expr.name == 'custom') {
    return 42.0;
  }
  return null; // Pass to next evaluator
});
```

---

## Tokenizer

The `Tokenizer` class converts a LaTeX string into a list of `Token` objects.

- `Tokenizer(String expression, {ExtensionRegistry? extensions, bool allowImplicitMultiplication = true})`
- `List<Token> tokenize()`

## Parser

The `Parser` class converts a list of `Token` objects into an AST `Expression`.

- `Parser(List<Token> tokens, String sourceExpression, bool recoverOnError, int maxRecursionDepth)`
- `Expression parse()`

## Token

Represents a unit of code in the LaTeX expression.

### Types

- `number`, `variable`, `operator`, `function`, `leftParen`, `rightParen`, `leftBrace`, `rightBrace`, `comma`, `backslash`, `circumflex`, `underscore`, `verticalBar` (absolute value).
