/// Splits announcement text into speakable chunks at sentence boundaries.
///
/// Splits on `.` so cancel/pause can take effect between sentences. Text
/// without a period is spoken as a single chunk (e.g. countdown digits).
List<String> splitAnnouncerSentences(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const [];

  if (!trimmed.contains('.')) {
    return [trimmed];
  }

  return trimmed
      .split('.')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map((s) => '$s.')
      .toList();
}
