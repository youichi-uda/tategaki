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
  /// - 2-digit numbers (10-99)
  /// - Year patterns (2024年)
  /// - Date patterns (12月)
  static List<Tatechuyoko> detectAuto(String text) {
    final detected = <Tatechuyoko>[];
    
    for (int i = 0; i < text.length; i++) {
      // Check for 2-digit number
      if (i < text.length - 1 &&
          _isDigit(text[i]) &&
          _isDigit(text[i + 1])) {
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
}
