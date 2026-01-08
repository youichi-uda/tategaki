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

    test('does not detect single digits', () {
      final result = TatechuyokoDetector.detectAuto('1月2日');

      expect(result.length, 0); // Single digits not detected
    });

    test('does not detect 3+ digit numbers', () {
      final result = TatechuyokoDetector.detectAuto('2024年');

      expect(result.length, 1); // Only detects first two digits: 20
      expect(result[0].startIndex, 0);
      expect(result[0].length, 2);
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
