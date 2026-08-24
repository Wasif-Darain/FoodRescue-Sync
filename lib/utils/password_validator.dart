import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';

/// Minimum number of characters required for a valid password.
const kMinPasswordLength = 8;

/// Estimated strength levels for a password, each with a color.
enum PasswordStrength {
  empty(Color(0xFFE5E7EB)),
  weak(Color(0xFFEF4444)),
  fair(Color(0xFFF59E0B)),
  good(Color(0xFF10B981)),
  strong(Color(0xFF059669));

  const PasswordStrength(this.color);

  final Color color;
}

String passwordStrengthLabel(AppLocalizations t, PasswordStrength strength) => switch (strength) {
  PasswordStrength.empty => t.pwStrengthEmpty,
  PasswordStrength.weak => t.pwStrengthWeak,
  PasswordStrength.fair => t.pwStrengthFair,
  PasswordStrength.good => t.pwStrengthGood,
  PasswordStrength.strong => t.pwStrengthStrong,
};

enum PasswordCriterionId { length, uppercase, lowercase, number, special }

String passwordCriterionLabel(AppLocalizations t, PasswordCriterionId id) => switch (id) {
  PasswordCriterionId.length => t.pwCriterionLength(kMinPasswordLength),
  PasswordCriterionId.uppercase => t.pwCriterionUppercase,
  PasswordCriterionId.lowercase => t.pwCriterionLowercase,
  PasswordCriterionId.number => t.pwCriterionNumber,
  PasswordCriterionId.special => t.pwCriterionSpecial,
};

/// A single criterion that a password can satisfy.
class PasswordCriterion {
  final PasswordCriterionId id;
  final bool Function(String) check;
  const PasswordCriterion(this.id, this.check);
}

/// The complete, ordered list of password criteria.
final List<PasswordCriterion> kPasswordCriteria = [
  PasswordCriterion(
    PasswordCriterionId.length,
    (p) => p.length >= kMinPasswordLength,
  ),
  PasswordCriterion(
    PasswordCriterionId.uppercase,
    (p) => RegExp(r'[A-Z]').hasMatch(p),
  ),
  PasswordCriterion(
    PasswordCriterionId.lowercase,
    (p) => RegExp(r'[a-z]').hasMatch(p),
  ),
  PasswordCriterion(
    PasswordCriterionId.number,
    (p) => RegExp(r'[0-9]').hasMatch(p),
  ),
  PasswordCriterion(
    PasswordCriterionId.special,
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
