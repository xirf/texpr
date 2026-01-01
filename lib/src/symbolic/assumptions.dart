/// Defines properties of variables and expressions.
enum Assumption {
  real,
  integer,
  positive,
  negative,
  nonNegative,
  nonZero,
  complex, // Default is real in this system but good to have
}

/// Manages assumptions about variables in the symbolic environment.
class Assumptions {
  final Map<String, Set<Assumption>> _variableAssumptions = {};

  /// Creates an empty assumptions context.
  Assumptions();

  /// Sets an assumption for a variable.
  void assume(String variable, Assumption assumption) {
    _variableAssumptions.putIfAbsent(variable, () => {}).add(assumption);
    _propagate(variable, assumption);
  }

  /// Checks if a variable has a specific property.
  bool check(String variable, Assumption assumption) {
    final assumptions = _variableAssumptions[variable];
    if (assumptions == null) return false;
    return assumptions.contains(assumption);
  }

  /// Infers additional properties based on a new assumption.
  void _propagate(String variable, Assumption newAssumption) {
    final set = _variableAssumptions[variable]!;
    switch (newAssumption) {
      case Assumption.positive:
        set.add(Assumption.nonNegative);
        set.add(Assumption.nonZero);
        set.add(Assumption.real);
        break;
      case Assumption.negative:
        set.add(Assumption.nonZero);
        set.add(Assumption.real);
        break;
      case Assumption.nonNegative:
        set.add(Assumption.real);
        break;
      case Assumption.integer:
        set.add(Assumption.real);
        break;
      default:
        break;
    }
  }

  /// Merges another assumptions object into this one.
  void merge(Assumptions other) {
    other._variableAssumptions.forEach((v, s) {
      _variableAssumptions.putIfAbsent(v, () => {}).addAll(s);
    });
  }
}
