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
      expect(YakumonoAdjuster.getGyotoIndent('（'), 0.1);
      expect(YakumonoAdjuster.getGyotoIndent('「'), 0.1);
      expect(YakumonoAdjuster.getGyotoIndent('【'), 0.1);

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

      // Ellipsis followed by normal character (should be widened)
      final spacing3 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('…', 'あ');
      expect(spacing3, greaterThan(0)); // Should be positive (widened)

      // Two-dot leader followed by normal character (should be widened)
      final spacing4 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('‥', 'い');
      expect(spacing4, greaterThan(0)); // Should be positive (widened)

      // Ellipsis with useVerticalGlyphs (should NOT be widened)
      final spacing6 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('…', 'あ', useVerticalGlyphs: true);
      expect(spacing6, 0.0); // Should be 0 when using vertical glyphs

      // Two-dot leader with useVerticalGlyphs (should NOT be widened)
      final spacing7 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('‥', 'い', useVerticalGlyphs: true);
      expect(spacing7, 0.0); // Should be 0 when using vertical glyphs

      // Full-width exclamation mark followed by normal character (should be widened)
      final spacing8 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('！', 'あ');
      expect(spacing8, greaterThan(0)); // Should be positive (widened)

      // Full-width question mark followed by normal character (should be widened)
      final spacing9 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('？', 'い');
      expect(spacing9, greaterThan(0)); // Should be positive (widened)

      // Full-width punctuation with useVerticalGlyphs (should NOT be widened)
      final spacing10 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('！', 'あ', useVerticalGlyphs: true);
      expect(spacing10, 0.0); // Should be 0 when using vertical glyphs

      // Normal characters
      final spacing5 = YakumonoAdjuster.getConsecutiveYakumonoSpacing('あ', 'い');
      expect(spacing5, 0.0);
    });
  });
}
