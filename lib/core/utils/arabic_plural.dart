/// Formats a count + Arabic noun with correct number agreement, instead of
/// naive `'$count $noun'` concatenation (which is wrong for the dual and
/// the 3-10 plural cases in Arabic).
///
/// Arabic numeral-noun agreement: 0 -> a dedicated "none" phrase, 1 -> bare
/// singular noun (no digit), 2 -> the dual form, 3-10 -> digit + plural
/// noun, 11+ -> digit + the singular noun form again.
String formatArabicCount(
  int count, {
  required String zero,
  required String singular,
  required String dual,
  required String pluralFew,
  required String pluralMany,
}) {
  if (count == 0) return zero;
  if (count == 1) return singular;
  if (count == 2) return dual;
  if (count >= 3 && count <= 10) return '$count $pluralFew';
  return '$count $pluralMany';
}
