---
trigger: always_on
---

**Documentation Standards**

- Document classes and their primary responsibilities
- Document public methods with their parameters, return types, and side effects
- Add inline comments only for complex logic that isn't self-explanatory through naming

**Forward Compatibility**

- Design with extension points for anticipated changes
- Favor composition over inheritance for flexibility
- Use dependency injection to support future implementations
- Consider interface abstractions where multiple implementations are likely

**Simplicity Principles**

- Solve the current problem without premature optimization
- Prefer clear, straightforward solutions over clever abstractions
- Add complexity only when concrete requirements demand it
- Refactor toward simplicity as patterns emerge

**API Deprecation Policy (Dart)**

- Mark public APIs as deprecated before removal
- Include deprecation notice with:
  - Version when deprecation started
  - Reason for deprecation
  - Recommended alternative or migration path
- Maintain deprecated APIs for at least 1 major version after deprecation
- Remove deprecated APIs only in major version releases (following semver)

Example deprecation:

```dart
@Deprecated('Use newMethod() instead. Will be removed in 3.0.0')
void oldMethod() {
  // implementation
}
```

- Add to CHANGELOG.md when deprecating
- Consider runtime warnings in debug mode for critical deprecations
