/// Legacy placeholder that older app versions persisted as the current
/// user's name (e.g. `donorName: 'You'` in listings, donations and pickups).
const String legacyYouPlaceholder = 'You';

/// Returns a human-readable donor name, replacing empty strings and the
/// legacy 'You' placeholder with [fallback].
String sanitizeDonorName(String? name, {String fallback = 'A donor'}) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty || trimmed == legacyYouPlaceholder) return fallback;
  return trimmed;
}

/// Rewrites notification messages authored by legacy code that embedded the
/// literal 'You' placeholder as the actor's name
/// (e.g. "You offered you a direct donation: ...").
String sanitizeLegacyNotificationMessage(String message) {
  return message.replaceFirstMapped(
    RegExp('^$legacyYouPlaceholder (offered|rescheduled|cancelled|marked) '),
    (m) => 'A donor ${m.group(1)} ',
  );
}
