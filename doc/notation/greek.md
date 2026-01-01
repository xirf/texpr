# Greek Letters

The library supports a set of Greek letters as variables. These can be used in expressions and assigned values.

## Lowercase Letters

| LaTeX Command | Symbol | LaTeX Command | Symbol | LaTeX Command | Symbol |
| :------------ | :----- | :------------ | :----- | :------------ | :----- |
| `\alpha`      | α      | `\iota`       | ι      | `\rho`        | ρ      |
| `\beta`       | β      | `\kappa`      | κ      | `\sigma`      | σ      |
| `\gamma`      | γ      | `\lambda`     | λ      | `\tau`        | τ      |
| `\delta`      | δ      | `\mu`         | μ      | `\upsilon`    | υ      |
| `\epsilon`    | ε      | `\nu`         | ν      | `\phi`        | φ      |
| `\zeta`       | ζ      | `\xi`         | ξ      | `\chi`        | χ      |
| `\eta`        | η      | `\omicron`    | ο      | `\psi`        | ψ      |
| `\theta`      | θ      | `\pi`         | π      | `\omega`      | ω      |

## Uppercase Letters

| LaTeX Command | Symbol | LaTeX Command | Symbol | LaTeX Command | Symbol |
| :------------ | :----- | :------------ | :----- | :------------ | :----- |
| `\Gamma`      | Γ      | `\Lambda`     | Λ      | `\Phi`        | Φ      |
| `\Delta`      | Δ      | `\Xi`         | Ξ      | `\Psi`        | Ψ      |
| `\Theta`      | Θ      | `\Pi`         | Π      | `\Omega`      | Ω      |
| `\Sigma`      | Σ      | `\Upsilon`    | Υ      |               |        |

## Variant Letters

Alternative forms for certain Greek letters.

| LaTeX Command | Symbol | Description     |
| :------------ | :----- | :-------------- |
| `\varepsilon` | ε      | Variant epsilon |
| `\varphi`     | φ      | Variant phi     |
| `\varrho`     | ρ      | Variant rho     |
| `\vartheta`   | θ      | Variant theta   |
| `\varpi`      | ϖ      | Variant pi      |
| `\varsigma`   | ς      | Final sigma     |

## Usage Examples

Greek letters can be used just like any other variable.

```dart
final e = LatexMathEvaluator();

// Evaluate with Greek variables
e.evaluate(r'\alpha + \beta', {r'\alpha': 10, r'\beta': 20}); // 30.0

// Useful for math physics formulas
e.evaluate(r'\Delta = b^2 - 4ac', {
  'b': 5,
  'a': 1,
  'c': 6
}); // 1.0
```
