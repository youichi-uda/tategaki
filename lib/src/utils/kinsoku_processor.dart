/// Kinsoku processing (Japanese line breaking rules)
///
/// This class implements Japanese line breaking rules based on a simplified version
/// of JIS X 4051 and JLREQ (Requirements for Japanese Text Layout).
///
/// ## Line Breaking Rules:
///
/// ### 1. Line-start prohibition (行頭禁則, gyoto kinsoku)
/// Characters that cannot appear at the start of a line:
/// - Periods and commas: 。、
/// - Closing bracket: 」
/// - Long vowel mark: ー
///
/// ### 2. Line-end prohibition (行末禁則, gyomatsu kinsoku)
/// Characters that cannot appear at the end of a line:
/// - Opening brackets: （「【『〈《
///
/// ### 3. Hanging (ぶら下げ, burasage)
/// When line-start prohibited characters appear at line end, they can either:
/// - Hang outside the text box (burasage) - only for: 。、」
/// - Be pushed into the previous line (oikomi) - for: ー
///
/// ### 4. Separation prohibition (分離禁止)
/// Characters that must stay together when consecutive:
/// - Leaders: …… (two ellipses), ‥‥ (two two-dot leaders)
/// - Dashes: ーー、――、——、––、－－
/// - Exclamation/Question marks: ！！、？？、！？、？！
///
/// When separation would occur, these are handled by oikomi (push-in), not burasage.
/// Leaders and dashes can appear at line start if not being separated from their pair.
///
/// ### 5. Processing order:
/// 1. Check gyoto kinsoku (line-start prohibition)
/// 2. Check gyomatsu kinsoku (line-end prohibition)
/// 3. Check separation prohibition for paired characters
/// 4. Apply burasage (hanging) or oikomi (push-in) as appropriate
class KinsokuProcessor {
  /// Characters that cannot appear at the start of a line (gyoto kinsoku)
  ///
  /// When these characters would appear at line start, the line must be broken
  /// at an earlier position (oikomi) or the character can hang outside the text
  /// box (burasage) if it's in burasageAllowed.
  static const Set<String> gyotoKinsoku = {
    '。', '、', // Periods and commas (can hang)
    '」', // Closing bracket (can hang)
    'ー', // Long vowel mark (cannot hang, must use oikomi)
  };

  /// Small characters that can hang at line end (burasage allowed)
  ///
  /// These characters can extend beyond the text box boundary instead of
  /// being pushed into the previous line.
  static const Set<String> burasageAllowed = {
    '。', '、', // Periods and commas
    '」', // Closing bracket
  };

  /// Characters that cannot hang (must use oikomi when line breaking)
  ///
  /// When these characters would be separated from their pair or appear at
  /// line end, they must be pushed into the previous line (oikomi).
  static const Set<String> burasageForbidden = {
    '…', '‥', // Leaders (always used in pairs: ……, ‥‥)
    'ー', '―', '—', '–', '－', // Dashes and long vowel mark
  };

  /// Characters that cannot appear at the end of a line (gyomatsu kinsoku)
  ///
  /// When these characters would appear at line end, the following character
  /// must be pushed to the next line with this character.
  static const Set<String> gyomatsuKinsoku = {
    '（', '「', '【', '『', '〈', '《', // Opening brackets
  };

  /// Characters that must appear in pairs (e.g., ……, ‥‥, ――)
  ///
  /// Cannot break between two consecutive instances.
  /// When separation would occur, use oikomi (not burasage) to keep them together.
  static const Set<String> pairedCharacters = {
    '…', // Ellipsis (always used as ……)
    '‥', // Two-dot leader (always used as ‥‥)
    'ー', // Long vowel mark (U+30FC)
    '―', // Horizontal bar / Dash (U+2015)
    '—', // Em dash (U+2014)
    '–', // En dash (U+2013)
    '－', // Fullwidth hyphen-minus (U+FF0D)
  };

  /// Characters that cannot be separated when consecutive
  ///
  /// Consecutive combinations like ！！、？？、！？、？！ must not be split.
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
