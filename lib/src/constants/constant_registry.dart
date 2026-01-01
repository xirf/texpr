/// Built-in mathematical constants registry.
///
/// Constants are organized into separate files by category:
/// - [circle.dart] - pi, tau
/// - [mathematical.dart] - e, phi, gamma, omega, delta, zeta3, G
/// - [common.dart] - sqrt2, sqrt3, ln2, ln10
library;

import 'circle.dart' as circle;
import 'mathematical.dart' as mathematical;
import 'common.dart' as common;

/// Registry of mathematical constants.
///
/// Constants are used as fallback when a variable is not provided
/// by the user. This allows expressions like `e` to work
/// without explicit variable binding.
class ConstantRegistry {
  static final ConstantRegistry _instance = ConstantRegistry._();

  /// Singleton instance of the constant registry.
  static ConstantRegistry get instance => _instance;

  final Map<String, double> _constants = {};

  ConstantRegistry._() {
    _registerBuiltins();
  }

  /// Creates a new registry (for testing or custom configurations).
  ConstantRegistry.custom();

  void _registerBuiltins() {
    // Circle constants
    register('pi', circle.pi);
    register('tau', circle.tau);

    // Famous mathematical constants
    register('e', mathematical.e);
    register('phi', mathematical.phi);
    register('gamma', mathematical.gamma);
    register('Omega', mathematical.omega);
    register('delta', mathematical.delta);
    register('zeta3', mathematical.zeta3);
    register('G', mathematical.gravitationalConstant);
    register('infty', mathematical.infty);
    register('hbar', mathematical.hbar);

    // Common values
    register('sqrt2', common.sqrt2);
    register('sqrt3', common.sqrt3);
    register('ln2', common.ln2);
    register('ln10', common.ln10);
  }

  /// Registers a constant.
  void register(String name, double value) {
    _constants[name] = value;
  }

  /// Checks if a constant is registered.
  bool hasConstant(String name) => _constants.containsKey(name);

  /// Gets a constant value. Returns null if not found.
  double? get(String name) => _constants[name];

  /// Gets all registered constant names.
  Iterable<String> get names => _constants.keys;
}
