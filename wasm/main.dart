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
        final result = evaluator.evaluate(expression);
        // Convert any result (numeric, complex, matrix, vector, function) to string
        // We could return a structured JS object if we wanted to be fancy, but string is fine for playground.
        return result.toString().toJS;
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
        final vars = <String, double>{};

        // Access Object.keys via global scope (window)
        final objectConstructor =
            web.window.getProperty('Object'.toJS) as JSObject;
        final keysArray = objectConstructor.callMethod('keys'.toJS, varsJs)
            as JSArray<JSString>;
        final keys = keysArray.toDart;

        for (final keyJs in keys) {
          final key = keyJs.toDart;
          final valueJs = varsJs.getProperty(keyJs);

          // Simple conversion to double
          // If value is a number, we can treat it as such.
          // Using unsafe cast or toDartInt/Double
          if (valueJs.typeofEquals('number')) {
            final num val = (valueJs as JSNumber).toDartDouble;
            vars[key] = val.toDouble();
          }
        }

        final result = evaluator.evaluate(expression, vars);
        return result.toString().toJS;
      } catch (e) {
        return 'Error: $e'.toJS;
      }
    }.toJS,
  );

  // Attach to window.texpr
  web.window.setProperty('texpr'.toJS, exports);

  print('texpr API exported to window.texpr');
}
