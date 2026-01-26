import 'package:flutter_test/flutter_test.dart';
import 'package:tategaki/tategaki.dart';

void main() {
  group('TatechuyokoDetector', () {
    test('detects 2-digit numbers', () {
      final result = TatechuyokoDetector.detectAuto('令和06年12月25日');

      expect(result.length, 3); // 06, 12, 25

      expect(result[0].startIndex, 2); // 06
      expect(result[0].length, 2);

      expect(result[1].startIndex, 5); // 12
      expect(result[1].length, 2);

      expect(result[2].startIndex, 8); // 25
      expect(result[2].length, 2);
    });

    test('detects full-width numbers', () {
      final result = TatechuyokoDetector.detectAuto('１２月');

      expect(result.length, 1);
      expect(result[0].startIndex, 0); // １２
      expect(result[0].length, 2);
    });

    test('detects single digits as tatechuyoko', () {
      final result = TatechuyokoDetector.detectAuto('1月2日');

      expect(result.length, 2); // 1, 2
      expect(result[0].startIndex, 0); // 1
      expect(result[0].length, 1);
      expect(result[1].startIndex, 2); // 2
      expect(result[1].length, 1);
    });

    test('does not detect 2-digit pairs in 3+ digit numbers', () {
      final result = TatechuyokoDetector.detectAuto('2024年');

      // Should not detect any pairs because 2024 is a 4-digit number
      expect(result.length, 0);
    });

    test('detects 2-letter alphabets', () {
      final result = TatechuyokoDetector.detectAuto('ABとCDとXY');

      expect(result.length, 3); // AB, CD, XY
      expect(result[0].startIndex, 0); // AB
      expect(result[0].length, 2);
      expect(result[1].startIndex, 3); // CD
      expect(result[1].length, 2);
      expect(result[2].startIndex, 6); // XY
      expect(result[2].length, 2);
    });

    test('does not detect 2-letter pairs in 3+ letter sequences', () {
      final result = TatechuyokoDetector.detectAuto('ABCとDEFG');

      // Should not detect any pairs because ABC and DEFG are 3+ letter sequences
      expect(result.length, 0);
    });

    test('detects both numbers and alphabets', () {
      final result = TatechuyokoDetector.detectAuto('AB12とCD34');

      expect(result.length, 4); // AB, 12, CD, 34
      expect(result[0].startIndex, 0); // AB
      expect(result[1].startIndex, 2); // 12
      expect(result[2].startIndex, 5); // CD
      expect(result[3].startIndex, 7); // 34
    });

    test('detects consecutive half-width punctuation', () {
      final result = TatechuyokoDetector.detectAuto('驚いた!!本当に!?信じられない??');

      expect(result.length, 3); // !!, !?, ??
      expect(result[0].startIndex, 3); // !!
      expect(result[0].length, 2);
      expect(result[1].startIndex, 8); // !?
      expect(result[1].length, 2);
      expect(result[2].startIndex, 16); // ??
      expect(result[2].length, 2);
    });

    test('detects all patterns together', () {
      final result = TatechuyokoDetector.detectAuto('AB12本当!?驚き!!');

      expect(result.length, 4); // AB, 12, !?, !!
      expect(result[0].startIndex, 0); // AB
      expect(result[1].startIndex, 2); // 12
      expect(result[2].startIndex, 6); // !?
      expect(result[3].startIndex, 10); // !!
    });

    test('handles text without numbers', () {
      final result = TatechuyokoDetector.detectAuto('これは普通のテキストです');

      expect(result.length, 0);
    });

    test('handles empty string', () {
      final result = TatechuyokoDetector.detectAuto('');

      expect(result.length, 0);
    });

    test('correctly calculates layout', () {
      final layout = TatechuyokoDetector.layoutTatechuyoko(
        '12',
        const Offset(0, 0),
        20.0, // base font size
      );

      expect(layout.fontSize, lessThan(20.0)); // Should be smaller
      expect(layout.height, 20.0); // Should take one character height
    });
  });
}
