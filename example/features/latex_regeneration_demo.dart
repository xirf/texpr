import 'package:texpr/texpr.dart';

/// Demonstrates LaTeX regeneration from AST (round-trip support).
///
/// This feature enables:
/// 1. Parsing LaTeX to AST, then regenerating clean LaTeX
/// 2. Programmatically building expressions and outputting LaTeX
/// 3. AST manipulation with LaTeX output
/// 4. Integration with visualization tools (MathJax, KaTeX)
void main() {
  final evaluator = Texpr();

  print('=== LaTeX Regeneration Demo ===\n');

  // Example 1: Round-trip parsing
  print('1. Round-Trip: LaTeX to AST to LaTeX');
  print("=" * 50);

  final expressions = [
    r'\frac{x^2 + 1}{2}',
    r'\sin{x} + \cos{y}',
    r'\int_{0}^{\pi}{\sin{x}} dx',
    r'\sum_{i=1}^{10}{i^2}',
    r'\sqrt[3]{27}',
    r'\log_{2}{8}',
  ];

  for (final latex in expressions) {
    final ast = evaluator.parse(latex);
    final regenerated = ast.toLatex();
    print('Original:     $latex');
    print('Regenerated:  $regenerated');
    print('');
  }

  // Example 2: Programmatic AST building
  print('\n2. Programmatic AST Building');
  print("=" * 50);

  // Build the quadratic formula: (-b ± sqrt(b^2 - 4ac)) / 2a
  const b = Variable('b');
  const a = Variable('a');
  const c = Variable('c');
  const four = NumberLiteral(4);
  const two = NumberLiteral(2);

  // b^2
  final bSquared = BinaryOp(b, BinaryOperator.power, const NumberLiteral(2));

  // 4ac
  final fourA = BinaryOp(four, BinaryOperator.multiply, a);
  final fourAC = BinaryOp(fourA, BinaryOperator.multiply, c);

  // b^2 - 4ac
  final discriminant = BinaryOp(bSquared, BinaryOperator.subtract, fourAC);

  // sqrt(b^2 - 4ac)
  final sqrtDiscriminant = FunctionCall('sqrt', discriminant);

  // -b
  final negB = UnaryOp(UnaryOperator.negate, b);

  // -b + sqrt(...)
  final numerator = BinaryOp(negB, BinaryOperator.add, sqrtDiscriminant);

  // 2a
  final denominator = BinaryOp(two, BinaryOperator.multiply, a);

  // Full formula
  final quadraticFormula =
      BinaryOp(numerator, BinaryOperator.divide, denominator);

  print('Built quadratic formula programmatically:');
  print(quadraticFormula.toLatex());
  print('');

  // Example 3: AST manipulation
  print('\n3. AST Manipulation');
  print("=" * 50);

  // Parse a simple expression
  final simple = evaluator.parse(r'x^2');
  print('Original expression: ${simple.toLatex()}');

  // Wrap it in a derivative
  final derivative = DerivativeExpr(simple, 'x');
  print('After differentiation operator: ${derivative.toLatex()}');

  // Add 1 to the result
  final modified = BinaryOp(simple, BinaryOperator.add, const NumberLiteral(1));
  print('After adding 1: ${modified.toLatex()}');

  // Wrap in integral
  final integral = IntegralExpr(
    const NumberLiteral(0),
    const NumberLiteral(1),
    modified,
    'x',
  );
  print('Wrapped in integral: ${integral.toLatex()}');
  print('');

  // Example 4: Complex real-world example
  print('\n4. Complex Expression Processing');
  print("=" * 50);

  // Parse a complex calculus expression
  final complex =
      evaluator.parse(r'\frac{d}{dx}{\left(\sin{x^2} + \cos{2x}\right)}');

  print('Parsed complex expression:');
  print('LaTeX: ${complex.toLatex()}');
  print('AST: $complex');
  print('');

  // Example 5: Matrix and vector regeneration
  print('\n5. Matrix and Vector Support');
  print("=" * 50);

  final matrix = evaluator.parse(r'\begin{bmatrix}1 & 2\\3 & 4\end{bmatrix}');
  print('Matrix: ${matrix.toLatex()}');

  final vector = evaluator.parse(r'\vec{1,2,3}');
  print('Vector: ${vector.toLatex()}');
  print('');

  // Example 6: Use cases
  print('\n6. Practical Use Cases');
  print("=" * 50);

  print('Use Case A: Export to visualization tools');
  final expr = evaluator.parse(r'\frac{-b + \sqrt{b^2 - 4ac}}{2a}');
  final cleanLatex = expr.toLatex();
  print('  Clean LaTeX for MathJax/KaTeX: $cleanLatex');
  print('');

  print('Use Case B: Expression normalization');
  final messy = evaluator.parse(r'x+y+z'); // Might have implicit multiplication
  print('  Normalized: ${messy.toLatex()}');
  print('');

  print('Use Case C: AST-based expression builder');
  print('  Users can build complex expressions programmatically,');
  print('  then export to LaTeX for display or further processing.');
  print('');

  // Example 7: Round-trip verification
  print('\n7. Round-Trip Verification');
  print("=" * 50);

  final testCases = [
    r'x^2 + 2x + 1',
    r'\sin{x} \times \cos{y}',
    r'\frac{1}{1+x^2}',
  ];

  for (final original in testCases) {
    final ast1 = evaluator.parse(original);
    final regenerated = ast1.toLatex();
    final ast2 = evaluator.parse(regenerated);

    final matches = ast1 == ast2;
    print('Original:  $original');
    print('Regenerated: $regenerated');
    print('ASTs match: ${matches ? '✓' : '✗'}');
    print('');
  }

  print('\n=== Summary ===');
  print('The toLatex() method enables:');
  print('  ✓ Round-trip LaTeX processing');
  print('  ✓ Programmatic expression building');
  print('  ✓ AST manipulation and transformation');
  print('  ✓ Export to visualization tools');
  print('  ✓ Expression normalization and formatting');
  print('\nThis is a foundational feature for symbolic algebra,');
  print('CAS integration, and advanced mathematical tooling.');
}
