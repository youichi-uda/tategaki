import 'package:flutter_test/flutter_test.dart';
import 'package:tategaki/tategaki.dart';

void main() {
  group('KinsokuProcessor', () {
    test('allows breaking before normal characters', () {
      expect(KinsokuProcessor.canBreakAt('あいう', 0), true);
      expect(KinsokuProcessor.canBreakAt('あいう', 1), true);
      expect(KinsokuProcessor.canBreakAt('あいう', 2), true);
    });

    test('disallows breaking before gyoto kinsoku characters', () {
      // Cannot break before 。
      expect(KinsokuProcessor.canBreakAt('あ。い', 1), false);
      // Cannot break before 、
      expect(KinsokuProcessor.canBreakAt('あ、い', 1), false);
      // Cannot break before ）
      expect(KinsokuProcessor.canBreakAt('あ）い', 1), false);
      // Cannot break before 」
      expect(KinsokuProcessor.canBreakAt('あ」い', 1), false);
    });

    test('disallows breaking after gyomatsu kinsoku characters', () {
      // Cannot break after （
      expect(KinsokuProcessor.canBreakAt('あ（い', 2), false);
      // Cannot break after 「
      expect(KinsokuProcessor.canBreakAt('あ「い', 2), false);
    });

    test('handles inseparable pairs', () {
      // Ellipsis should not be separated
      expect(KinsokuProcessor.canBreakAt('あ…い', 2), false);
    });

    test('finds proper break position', () {
      final text = 'これは文章。次の文';
      // If target is at 6 (after 。), should move to 5
      final breakPos = KinsokuProcessor.findBreakPosition(text, 6);
      expect(breakPos, lessThan(6));
    });

    test('handles edge cases', () {
      // Empty string
      expect(KinsokuProcessor.canBreakAt('', 0), true);

      // Single character
      expect(KinsokuProcessor.canBreakAt('あ', 0), true);

      // At end of string
      expect(KinsokuProcessor.canBreakAt('あいう', 3), true);
    });
  });
}
