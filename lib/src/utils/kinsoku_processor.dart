/// Kinsoku processing (Japanese line breaking rules)
class KinsokuProcessor {
  /// Characters that cannot appear at the start of a line (gyoto kinsoku)
  static const Set<String> gyotoKinsoku = {
    '。', '、', '．', '，', // Periods and commas
    '）', '」', '】', '』', '〉', '》', // Closing brackets
    '！', '？', '：', '；', // Full-width punctuation
    '!', '?', ':', ';',    // Half-width punctuation
    '・', // Middle dot (U+30FB)
    'ー', // Long vowel mark (U+30FC)
    '―', // Horizontal bar / Dash (U+2015)
    '—', // Em dash (U+2014)
    '–', // En dash (U+2013)
    '－', // Fullwidth hyphen-minus (U+FF0D)
    '…', // Ellipsis (U+2026)
    '‥', // Two-dot leader (U+2025)
    'っ', 'ゃ', 'ゅ', 'ょ', 'ゎ', // Small hiragana
    'ッ', 'ャ', 'ュ', 'ョ', 'ヮ', // Small katakana
    'ぁ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', // Small hiragana vowels
    'ァ', 'ィ', 'ゥ', 'ェ', 'ォ', // Small katakana vowels
  };

  /// Small characters that can hang at line end (burasage allowed)
  /// These are typically punctuation marks that take less visual space
  static const Set<String> burasageAllowed = {
    '。', '、', '．', '，', // Periods and commas only
  };

  /// Full-size characters that cannot hang (must use oikomi)
  /// These include ellipsis, exclamation marks, question marks, etc.
  static const Set<String> burasageForbidden = {
    '！', '？', // Full-width punctuation
    '!', '?',   // Half-width punctuation
    '…', '‥', // Leaders (always used in pairs)
    '）', '」', '】', '』', '〉', '》', // Closing brackets
    '：', '；', // Colon and semicolon
    'ー', '―', '—', '–', '－', // Dashes
  };

  /// Characters that cannot appear at the end of a line (gyomatsu kinsoku)
  static const Set<String> gyomatsuKinsoku = {
    '（', '「', '【', '『', '〈', '《', // Opening brackets
  };

  /// Characters that must appear in pairs (e.g., ……, ‥‥)
  /// Cannot break between two consecutive instances
  static const Set<String> pairedCharacters = {
    '…', // Ellipsis (always used as ……)
    '‥', // Two-dot leader (always used as ‥‥)
  };

  /// Characters that cannot be separated when consecutive
  /// (e.g., !!, ??, !?, ?!)
  static const Set<String> consecutiveCharacters = {
    '！', '？', // Full-width exclamation and question marks
    '!', '?',   // Half-width exclamation and question marks
  };

  /// Check if we can break the line at the specified position
  ///
  /// [text] The full text
  /// [position] The position to check (0-based index)
  ///
  /// Returns true if line can be broken at this position
  static bool canBreakAt(String text, int position) {
    // Empty string or negative position
    if (position < 0) {
      return false;
    }

    // Can always break at the start or end of text
    if (position == 0 || position >= text.length) {
      return true;
    }

    final charBefore = text[position - 1];
    final charAfter = text[position];

    // Cannot break if next character is gyoto kinsoku
    if (gyotoKinsoku.contains(charAfter)) {
      return false;
    }

    // Cannot break if previous character is gyomatsu kinsoku
    if (gyomatsuKinsoku.contains(charBefore)) {
      return false;
    }

    // Cannot break between paired characters (……, ‥‥)
    if (pairedCharacters.contains(charBefore) && charBefore == charAfter) {
      return false;
    }

    // Cannot break between consecutive punctuation (!!, ??, !?, ?!)
    if (consecutiveCharacters.contains(charBefore) &&
        consecutiveCharacters.contains(charAfter)) {
      return false;
    }

    return true;
  }

  /// Find the best position to break the line
  /// 
  /// [text] The full text
  /// [targetPosition] The ideal position to break
  /// 
  /// Returns the actual position where the line should break,
  /// adjusted for kinsoku rules
  static int findBreakPosition(String text, int targetPosition) {
    if (targetPosition <= 0 || targetPosition >= text.length) {
      return targetPosition;
    }

    // First, try to break at the target position
    if (canBreakAt(text, targetPosition)) {
      return targetPosition;
    }

    // Try positions before (oidashi - pushing out)
    for (int offset = 1; offset <= 3; offset++) {
      final pos = targetPosition - offset;
      if (pos > 0 && canBreakAt(text, pos)) {
        return pos;
      }
    }

    // Try positions after (oikomi - pulling in)
    for (int offset = 1; offset <= 3; offset++) {
      final pos = targetPosition + offset;
      if (pos < text.length && canBreakAt(text, pos)) {
        return pos;
      }
    }

    // If no good position found, return target position
    // (This shouldn't happen often, but is a fallback)
    return targetPosition;
  }

  /// Check if a character is gyoto kinsoku (line-start forbidden)
  static bool isGyotoKinsoku(String char) {
    return gyotoKinsoku.contains(char);
  }

  /// Check if a character is gyomatsu kinsoku (line-end forbidden)
  static bool isGyomatsuKinsoku(String char) {
    return gyomatsuKinsoku.contains(char);
  }

  /// Check if a character can hang at line end (burasage allowed)
  /// Returns true for small punctuation like 。、
  /// Returns false for full-size characters like ！？……
  static bool canHangAtLineEnd(String char) {
    return burasageAllowed.contains(char);
  }

  /// Check if a character cannot hang at line end (must use oikomi)
  static bool mustUseOikomi(String char) {
    return burasageForbidden.contains(char);
  }
}
