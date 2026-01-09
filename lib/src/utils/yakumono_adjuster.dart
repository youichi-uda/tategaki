import 'dart:ui';
import '../models/vertical_text_style.dart';
import 'character_classifier.dart';

/// Yakumono (Japanese punctuation) position adjuster
class YakumonoAdjuster {
  /// Adjust yakumono position for better typography
  static Offset adjustPosition(
    String character,
    Offset basePosition,
    VerticalTextStyle style,
  ) {
    if (!style.adjustYakumono) {
      return basePosition;
    }

    final fontSize = style.baseStyle.fontSize ?? 16.0;

    // Apply fine-tuning based on character type
    double xOffset = 0.0;
    double yOffset = 0.0;

    // Position punctuation marks at top-right of the virtual cell
    if (_isPunctuation(character)) {
      // Move right and up within the virtual cell
      xOffset = fontSize * 0.75;  // Move right by 3/4 of fontSize
      yOffset = -fontSize * 0.75; // Move up by 3/4 of fontSize
    } else if (CharacterClassifier.isSmallKana(character)) {
      // Position small kana: vertically centered, horizontally to the right (JLREQ)
      xOffset = fontSize * 0.25;  // Move right by 1/4 of fontSize
      yOffset = 0.0;              // Keep vertically centered
    } else if (_isDash(character)) {
      // Shift dashes to the left (they appear too far right when rotated)
      if (character == '–') {
        // En dash needs less adjustment
        xOffset = -fontSize * 0.1;
      } else {
        xOffset = -fontSize * 0.2;
      }
    } else if (_isOpeningBracket(character)) {
      // Shift opening brackets to the left and down
      xOffset = -fontSize * 0.3;
      yOffset = fontSize * 0.1;
    } else if (_isClosingBracket(character)) {
      // Shift closing brackets to the left and up
      xOffset = -fontSize * 0.3;
      yOffset = -fontSize * 0.1;
    } else if (character == '：' || character == '；') {
      // Shift colon and semicolon to the left
      xOffset = -fontSize * 0.2;
    } else if (character == '・') {
      // Shift middle dot up
      yOffset = -fontSize * 0.2;
    } else if (_isLeader(character)) {
      // Shift ellipsis and two-dot leader to the left
      xOffset = -fontSize * 0.25;
    }

    return Offset(basePosition.dx + xOffset, basePosition.dy + yOffset);
  }

  /// Check if yakumono should be treated as half-width
  static bool isHalfWidthYakumono(String character) {
    const halfWidthYakumono = {'。', '、', '・', '！', '？', '：', '；'};
    return halfWidthYakumono.contains(character);
  }

  /// Get width of yakumono (0.5 for half-width, 1.0 for full-width)
  static double getYakumonoWidth(String character) {
    return isHalfWidthYakumono(character) ? 0.5 : 1.0;
  }

  /// Check if yakumono can be hung (burasage-gumi)
  static bool canHang(String character) {
    const hangableYakumono = {'。', '、', '！', '？'};
    return hangableYakumono.contains(character);
  }

  /// Get gyoto indent amount for opening brackets
  static double getGyotoIndent(String character) {
    if (_isOpeningBracket(character)) {
      return 0.1; // 0.1 character width
    }
    return 0.0;
  }

  /// Get spacing adjustment for consecutive yakumono
  static double getConsecutiveYakumonoSpacing(
    String char1,
    String char2, {
    bool useVerticalGlyphs = false,
  }) {
    // Widen spacing after ellipsis and two-dot leader
    // (but not when using vertical glyphs, as the font handles spacing)
    if (_isLeader(char1) && !useVerticalGlyphs) {
      return 0.4; // Add extra space after leaders
    }

    // Widen spacing after full-size exclamation and question marks
    // (but not when using vertical glyphs)
    if (_isFullSizePunctuation(char1) && !useVerticalGlyphs) {
      return 0.4; // Add extra space after ！？
    }

    // Tighten spacing between closing bracket and punctuation
    if (_isClosingBracket(char1) && _isPunctuation(char2)) {
      return -0.3;
    }

    // Tighten spacing between punctuation and closing bracket
    if (_isPunctuation(char1) && _isClosingBracket(char2)) {
      return -0.3;
    }

    return 0.0;
  }

  static bool _isOpeningBracket(String character) {
    const openingBrackets = {'（', '「', '【', '『', '〈', '《'};
    return openingBrackets.contains(character);
  }

  static bool _isClosingBracket(String character) {
    const closingBrackets = {'）', '」', '】', '』', '〉', '》'};
    return closingBrackets.contains(character);
  }

  static bool _isPunctuation(String character) {
    const punctuation = {'。', '、'};
    return punctuation.contains(character);
  }

  static bool _isDash(String character) {
    const dashes = {
      'ー', // Long vowel mark (U+30FC)
      '―', // Horizontal bar / Dash (U+2015)
      '—', // Em dash (U+2014)
      '–', // En dash (U+2013)
      '－', // Fullwidth hyphen-minus (U+FF0D)
    };
    return dashes.contains(character);
  }

  static bool _isLeader(String character) {
    const leaders = {
      '…', // Ellipsis (U+2026)
      '‥', // Two-dot leader (U+2025)
    };
    return leaders.contains(character);
  }

  static bool _isFullSizePunctuation(String character) {
    const fullSizePunctuation = {
      '！', // Full-width exclamation mark
      '？', // Full-width question mark
    };
    return fullSizePunctuation.contains(character);
  }
}
