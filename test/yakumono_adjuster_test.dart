import 'package:flutter_test/flutter_test.dart';
import 'package:tategaki/tategaki.dart';

void main() {
  group('YakumonoAdjuster', () {
    test('identifies half-width yakumono', () {
      expect(YakumonoAdjuster.isHalfWidthYakumono('。'), true);
      expect(YakumonoAdjuster.isHalfWidthYakumono('、'), true);
      expect(YakumonoAdjuster.isHalfWidthYakumono('！'), true);
      expect(YakumonoAdjuster.isHalfWidthYakumono('？'), true);

      expect(YakumonoAdjuster.isHalfWidthYakumono('あ'), false);
      expect(YakumonoAdjuster.isHalfWidthYakumono('（'), false);
    });

    test('returns correct widths', () {
      // Half-width yakumono
      expect(YakumonoAdjuster.getYakumonoWidth('。'), 0.5);
      expect(YakumonoAdjuster.getYakumonoWidth('、'), 0.5);

      // Full-width characters
      expect(YakumonoAdjuster.getYakumonoWidth('あ'), 1.0);
      expect(YakumonoAdjuster.getYakumonoWidth('（'), 1.0);
    });

    test('identifies hangable yakumono', () {
      expect(YakumonoAdjuster.canHang('。'), true);
      expect(YakumonoAdjuster.canHang('、'), true);
      expect(YakumonoAdjuster.canHang('！'), true);
      expect(YakumonoAdjuster.canHang('？'), true);

      expect(YakumonoAdjuster.canHang('あ'), false);
      expect(YakumonoAdjuster.canHang('（'), false);
    });

    test('calculates gyoto indent for opening brackets', () {
      expect(YakumonoAdjuster.getGyotoIndent('（'), 0.5);
      expect(YakumonoAdjuster.getGyotoIndent('「'), 0.5);
      expect(YakumonoAdjuster.getGyotoIndent('【'), 0.5);

      expect(YakumonoAdjuster.getGyotoIndent('あ'), 0.0);
      expect(YakumonoAdjuster.getGyotoIndent('）'), 0.0);
    });

    test('calculates consecutive yakumono spacing', () {
      // Closing bracket followed by punctuation
      final spacing1 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('）', '。');
      expect(spacing1, lessThan(0)); // Should be negative (tightened)

      // Punctuation followed by closing bracket
      final spacing2 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('。', '」');
      expect(spacing2, lessThan(0));

      // Normal characters
      final spacing3 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('あ', 'い');
      expect(spacing3, 0.0);
    });
  });
}
