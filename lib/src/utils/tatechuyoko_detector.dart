import 'dart:ui';
import '../models/tatechuyoko.dart';

/// Layout information for tatechuyoko (horizontal text in vertical layout)
class TatechuyokoLayout {
  final Offset position;
  final double width;
  final double height;
  final double fontSize;

  const TatechuyokoLayout({
    required this.position,
    required this.width,
    required this.height,
    required this.fontSize,
  });
}

/// Detector and layouter for tatechuyoko
class TatechuyokoDetector {
  /// Automatically detect tatechuyoko patterns in text
  ///
  /// Detects:
  /// - 2-digit numbers (10-99) only when not part of 3+ digit numbers
  /// - 2-letter alphabets (AB, CD, etc.) only when not part of 3+ letter sequences
  /// - Consecutive half-width punctuation (!!, ??, !?, ?!)
  static List<Tatechuyoko> detectAuto(String text) {
    final detected = <Tatechuyoko>[];

    for (int i = 0; i < text.length; i++) {
      // Check for 2-digit number
      if (i < text.length - 1 &&
          _isDigit(text[i]) &&
          _isDigit(text[i + 1])) {
        // Make sure it's not part of a 3+ digit number
        // Check if there's a digit before
        if (i > 0 && _isDigit(text[i - 1])) {
          continue; // Part of longer number, skip
        }
        // Check if there's a digit after the second digit
        if (i + 2 < text.length && _isDigit(text[i + 2])) {
          continue; // Part of longer number, skip
        }

        detected.add(Tatechuyoko(startIndex: i, length: 2));
        i++; // Skip next character as it's part of this tatechuyoko
        continue;
      }

      // Check for 2-letter alphabet
      if (i < text.length - 1 &&
          _isAlphabet(text[i]) &&
          _isAlphabet(text[i + 1])) {
        // Make sure it's not part of a 3+ letter sequence
        // Check if there's an alphabet before
        if (i > 0 && _isAlphabet(text[i - 1])) {
          continue; // Part of longer sequence, skip
        }
        // Check if there's an alphabet after the second letter
        if (i + 2 < text.length && _isAlphabet(text[i + 2])) {
          continue; // Part of longer sequence, skip
        }

        detected.add(Tatechuyoko(startIndex: i, length: 2));
        i++; // Skip next character as it's part of this tatechuyoko
        continue;
      }

      // Check for consecutive half-width punctuation (!!, ??, !?, ?!)
      if (i < text.length - 1 &&
          _isHalfWidthPunctuation(text[i]) &&
          _isHalfWidthPunctuation(text[i + 1])) {
        detected.add(Tatechuyoko(startIndex: i, length: 2));
        i++; // Skip next character as it's part of this tatechuyoko
      }
    }

    return detected;
  }

  /// Calculate layout for tatechuyoko text
  static TatechuyokoLayout layoutTatechuyoko(
    String text,
    Offset basePosition,
    double baseFontSize,
  ) {
    // Tatechuyoko text should be scaled to fit exactly in one character cell
    // Use 85% of base font size to fit comfortably
    final fontSize = baseFontSize * 0.85;

    // Calculate width needed for the horizontal text
    final width = fontSize * text.length * 0.6; // Approximate

    return TatechuyokoLayout(
      position: basePosition,
      width: width,
      height: baseFontSize, // Takes up one character height
      fontSize: fontSize,
    );
  }

  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x0030 && code <= 0x0039) || // 0-9
           (code >= 0xFF10 && code <= 0xFF19);   // ０-９ (full-width)
  }

  static bool _isAlphabet(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x0041 && code <= 0x005A) || // A-Z
           (code >= 0x0061 && code <= 0x007A) || // a-z
           (code >= 0xFF21 && code <= 0xFF3A) || // Ａ-Ｚ (full-width)
           (code >= 0xFF41 && code <= 0xFF5A);   // ａ-ｚ (full-width)
  }

  static bool _isHalfWidthPunctuation(String char) {
    return char == '!' || char == '?';
  }
}
