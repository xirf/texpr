import 'package:texpr/texpr.dart';

void main() {
  // First tokenize to see what tokens we get
  final tokens = Tokenizer(r'\sqrt{|x|}').tokenize();
  print('Tokens:');
  for (final token in tokens) {
    print('  $token');
  }

  print('\nEvaluating...');
  final e = Texpr();
  print(e.evaluate(r'\sqrt{|x|}', {'x': -4}));
}
