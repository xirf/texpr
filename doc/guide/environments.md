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

### Defining and Calling Functions

Once defined, custom functions can be called just like built-in functions.

```dart
final texpr = Texpr();

// Define a function
texpr.evaluate(r'f(x) = x^2');

// Call the function
print(texpr.evaluate('f(3)').asNumeric());        // 9.0
print(texpr.evaluate('f(5)').asNumeric());        // 25.0

// Multi-parameter functions
texpr.evaluate(r'g(a, b) = a + b');
print(texpr.evaluate('g(2, 3)').asNumeric());     // 5.0

// Nested function calls
print(texpr.evaluate('f(g(1, 2))').asNumeric());  // 9.0 (f(3) = 9)
```

### Using LaTeX in Function Bodies

Function bodies can use any valid LaTeX expressions:

```dart
texpr.evaluate(r'area(r) = \pi r^2');
print(texpr.evaluate('area(2)').asNumeric());  // 12.566...

texpr.evaluate(r'h(x) = \sin{x} + \cos{x}');
print(texpr.evaluate('h(0)').asNumeric());     // 1.0
```

### Accessing Global Variables

Functions can use variables from the global environment:

```dart
texpr.evaluate(r'let rate = 0.05');
texpr.evaluate(r'interest(principal) = principal * rate');
print(texpr.evaluate('interest(1000)').asNumeric()); // 50.0
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
