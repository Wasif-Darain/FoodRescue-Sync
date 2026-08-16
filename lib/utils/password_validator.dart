import 'package:flutter/material.dart';

/// Minimum number of characters required for a valid password.
const kMinPasswordLength = 8;

/// Estimated strength levels for a password, each with a label and color.
enum PasswordStrength {
  empty('Empty', Color(0xFFE5E7EB)),
  weak('Weak', Color(0xFFEF4444)),
  fair('Fair', Color(0xFFF59E0B)),
  good('Good', Color(0xFF10B981)),
  strong('Strong', Color(0xFF059669));

  const PasswordStrength(this.label, this.color);

  final String label;
  final Color color;
}

/// A single criterion that a password can satisfy.
class PasswordCriterion {
  final String label;
  final bool Function(String) check;
  const PasswordCriterion(this.label, this.check);
}

/// The complete, ordered list of password criteria.
final List<PasswordCriterion> kPasswordCriteria = [
  PasswordCriterion(
    'At least $kMinPasswordLength characters',
    (p) => p.length >= kMinPasswordLength,
  ),
  PasswordCriterion(
    'Contains an uppercase letter',
    (p) => RegExp(r'[A-Z]').hasMatch(p),
  ),
  PasswordCriterion(
    'Contains a lowercase letter',
    (p) => RegExp(r'[a-z]').hasMatch(p),
  ),
  PasswordCriterion(
    'Contains a number',
    (p) => RegExp(r'[0-9]').hasMatch(p),
  ),
  PasswordCriterion(
    'Contains a special character',
    (p) => RegExp(r'[^a-zA-Z0-9]').hasMatch(p),
  ),
];

/// The result of validating a password against all criteria.
class PasswordValidationResult {
  /// Number of criteria met (0–5).
  final int score;

  /// Estimated strength level.
  final PasswordStrength strength;

  /// Criteria that the password does NOT yet satisfy.
  final List<PasswordCriterion> unmet;

  /// Whether the password satisfies every criterion.
  final bool isValid;

  const PasswordValidationResult({
    required this.score,
    required this.strength,
    required this.unmet,
    required this.isValid,
  });

  /// Validates [password] against [kPasswordCriteria].
  factory PasswordValidationResult.validate(String password) {
    final unmet = kPasswordCriteria
        .where((c) => !c.check(password))
        .toList();
    final score = kPasswordCriteria.length - unmet.length;
    final strength = _strengthFromScore(score, password);

    return PasswordValidationResult(
      score: score,
      strength: strength,
      unmet: unmet,
      isValid: unmet.isEmpty,
    );
  }

  static PasswordStrength _strengthFromScore(int score, String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.fair;
    if (score == 3) return PasswordStrength.good;
    return PasswordStrength.strong;
  }
}
