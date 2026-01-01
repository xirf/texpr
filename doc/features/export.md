# Export Features

The `texpr` library provides several methods to export the Abstract Syntax Tree (AST) to different formats. This enables interoperability with other tools, debugging, and web display.

## Overview

| Format     | Method        | Purpose                 | Status           |
| ---------- | ------------- | ----------------------- | ---------------- |
| **JSON**   | `.toJson()`   | Debugging, Tooling      | Stable           |
| **SymPy**  | `.toSymPy()`  | Python Interoperability | **Experimental** |
| **MathML** | `.toMathML()` | Web Display             | **Experimental** |

---

## JSON Export (`.toJson()`)

The JSON export provides a complete, structural representation of the AST. It is fully tested and covers all 18 AST node types.

**Use Cases:**

- Debugging the parser structure.
- Sending AST data to external analysis tools.
- Serializing expressions for storage.

**Example:**

```dart
final expr = evaluator.parse(r'\frac{x^2 + 1}{2}');
final json = expr.toJson();
print(jsonEncode(json));
```

---

## SymPy Export (`.toSymPy()`)

> [!WARNING] Status: Experimental
> This feature is currently in an early stage. It has been verified against a small set of approximately 40 test cases covering standard arithmetic, calculus, and basic functions. It may not handle all edge cases, complex variable scope issues, or advanced symbolic constructs perfectly.

Generates Python code compatible with the [SymPy](https://www.sympy.org/) library. This allows you to leverage Python's powerful CAS capabilities for tasks like solving equations or advanced simplification.

**Capabilities:**

- Maps standard functions (`\sin` to `sin`, `\ln` to `log`).
- Handles calculus structure (`\int` to `integrate`, `\frac{d}{dx}` to `diff`).
- Generates valid Python syntax.

**Example:**

```dart
final expr = evaluator.parse(r'\int x^2 dx');
print(expr.toSymPy()); // Output: integrate(x**2, x)

// Generate a full runnable script
print(expr.toSymPyScript());
```

**Known Limitations:**

- Variable mapping is basic; might conflict if you use reserved Python keywords (though we handle `i`/`I` and `infinity`/`oo`).
- Complex custom functions may not map 1:1 to SymPy functions without manual intervention.

---

## MathML Export (`.toMathML()`)

> [!WARNING] Status: Experimental
> This feature is experimental. It has been validated against approximately 20 integration test cases for XML well-formedness and basic structure. It produces **Presentation MathML**, which focuses on visual rendering. Browser support for MathML varies, and complex layout adjustments might be needed.

Generates [MathML](https://www.w3.org/Math/) markup, enabling mathematical expressions to be rendered natively in web browsers that support it.

**Capabilities:**

- Generates Presentation MathML tags (`<mn>`, `<mi>`, `<mo>`, `<mfrac>`, etc.).
- Supports standard operators and layout schemata like integrals and sums.
- Includes XML escaping for operators (e.g., `<` becomes `&lt;`).

**Example:**

```dart
final expr = evaluator.parse(r'\frac{a}{b}');
print(expr.toMathML());
// Output: <math...><mfrac><mi>a</mi><mi>b</mi></mfrac></math>
```

**Known Limitations:**

- Generates "Presentation MathML" only, not "Content MathML".
- Styling and font handling rely on the rendering engine (browser).
- Complex nested structures might need visual fine-tuning.
