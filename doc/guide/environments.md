# Custom Environments

Texpr allows you to define custom variables and functions that persist across multiple evaluations. This is useful for creating interactive sessions, REPLs, or complex calculations where values need to be reused.

## Variables

You can define variables using the `let` keyword. Once defined, these variables can be used in subsequent expressions.

```latex
let x = 5
let y = 10
x + y  // Result: 15
```

### Syntax
```latex
let <variable_name> = <expression>
```

- **Variable Names**: Must start with a letter and can contain letters. They are case-sensitive.
- **Expression**: Any valid LaTeX math expression.

### Persistence
Variables defined with `let` are stored in the `Texpr` instance's global environment. They persist until you explicitly clear them or the instance is destroyed.

```dart
final texpr = Texpr();
texpr.evaluate('let a = 10');
print(texpr.evaluate('a + 5').asNumeric()); // 15.0
```

## Functions

You can define custom functions using the standard function notation.

```latex
f(x) = x^2 + 1
g(a, b) = a * b
```

### Syntax
```latex
<function_name>(<parameter_list>) = <expression>
```

- **Function Name**: The name of the function (e.g., `f`, `myFunc`).
- **Parameter List**: Comma-separated list of parameter names (e.g., `x`, `a, b`).
- **Expression**: The function body, using the parameters.

### Usage
Once defined, custom functions can be called just like built-in functions.

```latex
let val = f(3) // Uses f(x) = x^2 + 1, result is 10
```

## Scoping and Shadowing

The `Texpr` environment has two layers:
1.  **Global Environment**: Persistent items defined via `let` or function definitions.
2.  **Local Environment**: Temporary variables passed to `evaluate` or `evaluateParsed`.

Local variables shadow global variables.

```dart
final texpr = Texpr();
texpr.evaluate('let x = 10');

// Use global 'x'
print(texpr.evaluate('x').asNumeric()); // 10.0

// Shadow global 'x' with local 'x'
print(texpr.evaluate('x', {'x': 20}).asNumeric()); // 20.0

// Global 'x' is unchanged
print(texpr.evaluate('x').asNumeric()); // 10.0
```

## Managing the Environment

You can clear the persistent global environment using `clearEnvironment()`.

```dart
texpr.clearEnvironment();
// 'x' is no longer defined
```
