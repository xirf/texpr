import '../rewrite_rule.dart';
import 'arithmetic_rules.dart';
import 'trig_rules.dart';
import 'log_rules.dart';
import 'simplification_rules.dart';

export 'arithmetic_rules.dart';
export 'trig_rules.dart';
export 'log_rules.dart';
export 'simplification_rules.dart';
// export 'custom_rules.dart'; // Future extension

/// Rules that reduce complexity or are generally always desirable.
final List<RewriteRule> allSimplificationRules = [
  ...allArithmeticRules,
  ...simplificationTrigRules,
  ...extraSimplificationRules,
  ...allLogRules.where((r) =>
      r.category == RuleCategory.simplification ||
      r.category == RuleCategory.identity),
];

/// Rules that increase complexity or expand terms.
final List<RewriteRule> allExpansionRules = [
  ...expansionTrigRules,
  ...allLogRules.where((r) => r.category == RuleCategory.expansion),
];
