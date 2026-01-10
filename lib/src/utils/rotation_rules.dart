import 'dart:math' as math;
import 'package:kinsoku/kinsoku.dart';

/// Rules for character rotation in vertical text layout
class RotationRules {
  /// Get rotation angle for a character in radians
  /// 
  /// [character] The character to check
  /// [type] The character type
  /// [rotateLatinCharacters] Whether to rotate Latin characters
  /// 
  /// Returns rotation angle in radians (0 for no rotation, π/2 for 90° rotation)
  static double getRotationAngle(
    String character,
    CharacterType type,
    bool rotateLatinCharacters,
  ) {
    switch (type) {
      case CharacterType.latin:
      case CharacterType.number:
        return rotateLatinCharacters ? math.pi / 2 : 0.0;
      
      case CharacterType.yakumono:
        return getYakumonoRotation(character);
      
      case CharacterType.punctuation:
        return math.pi / 2;
      
      default:
        return 0.0;
    }
  }

  /// Get rotation angle for yakumono (Japanese symbols)
  static double getYakumonoRotation(String character) {
    // Characters that should be rotated 90 degrees
    const rotatedYakumono = {
      '（', '）', '「', '」', '【', '】', '『', '』',
      '〈', '〉', '《', '》', // Brackets
      'ー', // Long vowel mark (U+30FC)
      '―', // Horizontal bar / Dash (U+2015)
      '—', // Em dash (U+2014)
      '–', // En dash (U+2013)
      '－', // Fullwidth hyphen-minus (U+FF0D)
      '…', '‥', // Leaders
      '〜', // Wave dash
      '：', '；', // Colon, Semicolon
    };

    if (rotatedYakumono.contains(character)) {
      return math.pi / 2;
    }

    // Punctuation marks that stay upright
    const uprightYakumono = {'。', '、', '！', '？', '・'};
    if (uprightYakumono.contains(character)) {
      return 0.0;
    }

    return 0.0;
  }
}
