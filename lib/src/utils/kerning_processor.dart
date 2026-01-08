/// Kerning processor for advanced character spacing
class KerningProcessor {
  /// Kerning pairs (character combinations and their spacing adjustment)
  /// Negative values mean tighter spacing
  static const Map<String, Map<String, double>> kerningPairs = {
    '。': {
      '、': -0.5,
      'っ': -0.3,
      'ゃ': -0.3,
      'ゅ': -0.3,
      'ょ': -0.3,
      '）': -0.4,
      '」': -0.4,
      '】': -0.4,
      '』': -0.4,
    },
    '、': {
      'っ': -0.3,
      'ゃ': -0.3,
      'ゅ': -0.3,
      'ょ': -0.3,
      '）': -0.4,
      '」': -0.4,
      '】': -0.4,
      '』': -0.4,
    },
    '）': {
      '。': -0.4,
      '、': -0.4,
      '！': -0.3,
      '？': -0.3,
    },
    '」': {
      '。': -0.4,
      '、': -0.4,
      '！': -0.3,
      '？': -0.3,
    },
    '】': {
      '。': -0.4,
      '、': -0.4,
    },
    '』': {
      '。': -0.4,
      '、': -0.4,
    },
  };

  /// Get kerning adjustment between two characters
  /// 
  /// Returns the spacing adjustment (negative = tighter, positive = looser)
  /// in units of character width (e.g., -0.3 means 0.3 characters tighter)
  static double getKerning(String char1, String char2) {
    if (kerningPairs.containsKey(char1) &&
        kerningPairs[char1]!.containsKey(char2)) {
      return kerningPairs[char1]![char2]!;
    }
    return 0.0;
  }

  /// Get standard yakumono kerning (for punctuation marks)
  static double getYakumonoKerning(String character) {
    // Standard spacing reduction for common yakumono
    const yakumonoKerning = {
      '。': -0.2,
      '、': -0.2,
      '！': -0.15,
      '？': -0.15,
      '：': -0.1,
      '；': -0.1,
    };

    return yakumonoKerning[character] ?? 0.0;
  }

  /// Calculate oikomi (line-end compression) adjustment
  /// 
  /// Distributes spacing reduction evenly across characters to fit
  /// text within the target width
  /// 
  /// [text] The text to adjust
  /// [lineStart] Start index of the line
  /// [lineEnd] End index of the line
  /// [targetWidth] The width to fit within
  /// [currentWidth] The current width of the text
  /// 
  /// Returns per-character spacing adjustment
  static double calculateOikomiAdjustment(
    String text,
    int lineStart,
    int lineEnd,
    double targetWidth,
    double currentWidth,
  ) {
    if (currentWidth <= targetWidth) {
      return 0.0;
    }

    final excess = currentWidth - targetWidth;
    final numChars = lineEnd - lineStart;

    if (numChars <= 1) {
      return 0.0;
    }

    // Distribute excess evenly, but cap at 0.1 character width per space
    final perCharAdjustment = -excess / (numChars - 1);
    return perCharAdjustment.clamp(-0.1, 0.0);
  }
}
