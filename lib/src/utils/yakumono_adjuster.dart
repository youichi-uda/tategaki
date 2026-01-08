import 'dart:ui';
import '../models/vertical_text_style.dart';

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

    // Apply fine-tuning based on character type
    double xOffset = 0.0;
    double yOffset = 0.0;

    // Adjust specific yakumono characters
    if (_isClosingBracket(character)) {
      // Slightly shift closing brackets
      xOffset = -2.0;
    } else if (_isOpeningBracket(character)) {
      // Slightly shift opening brackets
      xOffset = 2.0;
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
      return 0.5; // 0.5 character width
    }
    return 0.0;
  }

  /// Get spacing adjustment for consecutive yakumono
  static double getConsecutiveYakumonoSpacing(
    String char1,
    String char2,
  ) {
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
    const punctuation = {'。', '、', '！', '？', '：', '；'};
    return punctuation.contains(character);
  }
}
