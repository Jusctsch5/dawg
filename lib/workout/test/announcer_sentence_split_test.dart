import 'package:dawg/workout/announcer_sentence_split.dart';
import 'package:test/test.dart';

void main() {
  group('splitAnnouncerSentences', () {
    test('splits on periods', () {
      expect(
        splitAnnouncerSentences('Stand tall. Crunch down. Return with control.'),
        ['Stand tall.', 'Crunch down.', 'Return with control.'],
      );
    });

    test('keeps text without periods as one chunk', () {
      expect(splitAnnouncerSentences('Ready Go!'), ['Ready Go!']);
      expect(splitAnnouncerSentences('5'), ['5']);
    });

    test('trims whitespace and skips empty segments', () {
      expect(
        splitAnnouncerSentences('  First.   Second.  '),
        ['First.', 'Second.'],
      );
    });

    test('empty input yields no chunks', () {
      expect(splitAnnouncerSentences(''), isEmpty);
      expect(splitAnnouncerSentences('   '), isEmpty);
    });
  });
}
