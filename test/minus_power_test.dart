import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  test('unary minus with power and parentheses', () {
    final evaluator = Evaluator();
    final expr = Parser(Tokenizer(r'-(x-1)^{2}+4').tokenize()).parse();
    final result = evaluator.evaluate(expr, {'x': 2});
    expect(result.asNumeric(), equals(3.0));
  });
}
