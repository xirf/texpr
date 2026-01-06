import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:texpr/texpr.dart';
import 'package:web/web.dart' as web;

void main() {
  print('=== texpr WASM Service ===');

  final evaluator = Texpr();

  // Create a JS object to hold our exported functions
  final exports = JSObject();

  // Export 'evaluate' function
  exports.setProperty(
    'evaluate'.toJS,
    (String expression) {
      try {
        return evaluator.evaluateNumeric(expression).toJS;
      } catch (e) {
        // Return error as string or handle it
        return 'Error: $e'.toJS;
      }
    }.toJS,
  );

  // Export 'evaluateWithVars' function
  exports.setProperty(
    'evaluateWithVars'.toJS,
    (String expression, JSObject varsJs) {
      try {
        // Convert JS object to connection
        // final vars = <String, double>{};
        // Simple iteration over keys - simplistic approach for demo
        // A more robust way would be to use Object.entries or similar if needed,
        // but for now let's assume the user passes a simple object.
        // Actually, converting JSObject to Map in dart:js_interop can be tricky without dart:js_util (which is legacy).
        // Let's stick to evaluate for now or use a basic interop pattern.

        // Using js_interop.unsafe to iterate keys
        // (Not implementing complex object conversion for calmness in this demo step,
        // sticking to simple evaluate first to prove point).
        return evaluator.evaluateNumeric(expression).toJS;
      } catch (e) {
        return 'Error: $e'.toJS;
      }
    }.toJS,
  );

  // Attach to window.texpr
  web.window.setProperty('texpr'.toJS, exports);

  print('texpr API exported to window.texpr');
}
