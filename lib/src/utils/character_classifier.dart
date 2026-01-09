/// Character types for vertical text layout
enum CharacterType {
  /// Kanji (Chinese characters)
  kanji,

  /// Hiragana (Japanese phonetic script)
  hiragana,

  /// Katakana (Japanese phonetic script for foreign words)
  katakana,

  /// Latin alphabet (A-Z, a-z)
  latin,

  /// Numbers (0-9)
  number,

  /// Punctuation marks
  punctuation,

  /// Yakumono (Japanese typography symbols)
  yakumono,

  /// Space characters
  space,
}

/// Classifier for determining character types and properties
class CharacterClassifier {
  /// Classify a single character
  static CharacterType classify(String character) {
    if (character.isEmpty) return CharacterType.space;
    
    final codeUnit = character.codeUnitAt(0);
    
    // Space
    if (codeUnit == 0x0020 || codeUnit == 0x3000) {
      return CharacterType.space;
    }
    
    // Latin alphabet
    if ((codeUnit >= 0x0041 && codeUnit <= 0x005A) || // A-Z
        (codeUnit >= 0x0061 && codeUnit <= 0x007A)) { // a-z
      return CharacterType.latin;
    }
    
    // Numbers
    if (codeUnit >= 0x0030 && codeUnit <= 0x0039) { // 0-9
      return CharacterType.number;
    }
    
    // Hiragana
    if (codeUnit >= 0x3040 && codeUnit <= 0x309F) {
      return CharacterType.hiragana;
    }

    // Yakumono (Japanese punctuation and symbols)
    // Check this before Katakana to catch long vowel mark (ー, U+30FC)
    if (_isYakumono(character)) {
      return CharacterType.yakumono;
    }

    // Katakana
    if (codeUnit >= 0x30A0 && codeUnit <= 0x30FF) {
      return CharacterType.katakana;
    }
    
    // Punctuation
    if (_isPunctuation(codeUnit)) {
      return CharacterType.punctuation;
    }
    
    // CJK Unified Ideographs (Kanji)
    if ((codeUnit >= 0x4E00 && codeUnit <= 0x9FFF) ||
        (codeUnit >= 0x3400 && codeUnit <= 0x4DBF) ||
        (codeUnit >= 0x20000 && codeUnit <= 0x2A6DF)) {
      return CharacterType.kanji;
    }
    
    return CharacterType.kanji; // Default for unknown characters
  }

  /// Check if character is yakumono (Japanese typography symbols)
  static bool _isYakumono(String character) {
    const yakumonoChars = {
      '。', '、', '・', '（', '）', '「', '」', '【', '】',
      '『', '』', '〈', '〉', '《', '》', '！', '？', '：', '；',
      'ー', // Long vowel mark (U+30FC)
      '―', // Horizontal bar / Dash (U+2015)
      '—', // Em dash (U+2014)
      '–', // En dash (U+2013)
      '－', // Fullwidth hyphen-minus (U+FF0D)
      '〜', '…', '‥', '＿', '＝'
    };
    return yakumonoChars.contains(character);
  }

  /// Check if code unit is punctuation
  static bool _isPunctuation(int codeUnit) {
    return (codeUnit >= 0x0021 && codeUnit <= 0x002F) || // !"#$%&'()*+,-./
           (codeUnit >= 0x003A && codeUnit <= 0x0040) || // :;<=>?@
           (codeUnit >= 0x005B && codeUnit <= 0x0060) || // [\]^_`
           (codeUnit >= 0x007B && codeUnit <= 0x007E);   // {|}~
  }

  /// Check if character needs rotation in vertical text
  static bool needsRotation(String character) {
    final type = classify(character);
    return type == CharacterType.latin ||
           type == CharacterType.number ||
           _isRotatableYakumono(character);
  }

  /// Check if yakumono should be rotated
  static bool _isRotatableYakumono(String character) {
    const rotatableYakumono = {
      '（', '）', '「', '」', '【', '】', '『', '』',
      '〈', '〉', '《', '》',
      'ー', // Long vowel mark (U+30FC)
      '―', // Horizontal bar / Dash (U+2015)
      '—', // Em dash (U+2014)
      '–', // En dash (U+2013)
      '－', // Fullwidth hyphen-minus (U+FF0D)
      '〜', '…', '‥'
    };
    return rotatableYakumono.contains(character);
  }

  /// Check if character is small kana (っゃゅょなど)
  static bool isSmallKana(String character) {
    const smallKana = {
      'ぁ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', // small hiragana vowels
      'ゃ', 'ゅ', 'ょ', 'ゎ', 'っ', // small hiragana
      'ァ', 'ィ', 'ゥ', 'ェ', 'ォ', // small katakana vowels
      'ャ', 'ュ', 'ョ', 'ヮ', 'ッ', // small katakana
    };
    return smallKana.contains(character);
  }

  /// Check if character is a long vowel mark
  static bool isLongVowelMark(String character) {
    return character == 'ー';
  }

  /// Check if character is opening bracket
  static bool isOpeningBracket(String character) {
    const openingBrackets = {'（', '「', '【', '『', '〈', '《'};
    return openingBrackets.contains(character);
  }

  /// Check if character is closing bracket
  static bool isClosingBracket(String character) {
    const closingBrackets = {'）', '」', '】', '』', '〉', '》'};
    return closingBrackets.contains(character);
  }
}
