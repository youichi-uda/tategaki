import 'package:flutter/painting.dart';
import 'kinsoku_method.dart';

/// Style configuration for vertical text layout
class VerticalTextStyle {
  /// Base text style for characters
  final TextStyle baseStyle;

  /// Spacing between lines (horizontal spacing in vertical text)
  final double lineSpacing;

  /// Spacing between characters (vertical spacing in vertical text)
  final double characterSpacing;

  /// Whether to rotate Latin characters and numbers
  final bool rotateLatinCharacters;

  /// Whether to adjust yakumono (punctuation) positioning
  final bool adjustYakumono;

  /// Text style for ruby (furigana) text
  final TextStyle? rubyStyle;

  /// Method for kinsoku processing (line breaking rules)
  /// - oikomi (追い込み): Push forbidden characters to previous line
  /// - burasage (ぶら下げ): Allow forbidden characters to hang beyond maxHeight
  final KinsokuMethod kinsokuMethod;

  /// Enable half-width yakumono processing
  final bool enableHalfWidthYakumono;

  /// Enable gyoto indent (indenting opening brackets at line start)
  final bool enableGyotoIndent;

  /// Enable kerning (advanced character spacing)
  final bool enableKerning;

  /// Use vertical glyphs (OpenType 'vert' feature)
  /// When true, assumes the font provides vertical glyphs and skips rotation
  /// processing for yakumono (brackets, dashes, etc.)
  final bool useVerticalGlyphs;

  const VerticalTextStyle({
    this.baseStyle = const TextStyle(),
    this.lineSpacing = 0.0,
    this.characterSpacing = 0.0,
    this.rotateLatinCharacters = true,
    this.adjustYakumono = true,
    this.rubyStyle,
    this.kinsokuMethod = KinsokuMethod.oikomi,
    this.enableHalfWidthYakumono = false,
    this.enableGyotoIndent = false,
    this.enableKerning = false,
    this.useVerticalGlyphs = false,
  });

  /// Create a copy with modified properties
  VerticalTextStyle copyWith({
    TextStyle? baseStyle,
    double? lineSpacing,
    double? characterSpacing,
    bool? rotateLatinCharacters,
    bool? adjustYakumono,
    TextStyle? rubyStyle,
    KinsokuMethod? kinsokuMethod,
    bool? enableHalfWidthYakumono,
    bool? enableGyotoIndent,
    bool? enableKerning,
    bool? useVerticalGlyphs,
  }) {
    return VerticalTextStyle(
      baseStyle: baseStyle ?? this.baseStyle,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      characterSpacing: characterSpacing ?? this.characterSpacing,
      rotateLatinCharacters: rotateLatinCharacters ?? this.rotateLatinCharacters,
      adjustYakumono: adjustYakumono ?? this.adjustYakumono,
      rubyStyle: rubyStyle ?? this.rubyStyle,
      kinsokuMethod: kinsokuMethod ?? this.kinsokuMethod,
      enableHalfWidthYakumono: enableHalfWidthYakumono ?? this.enableHalfWidthYakumono,
      enableGyotoIndent: enableGyotoIndent ?? this.enableGyotoIndent,
      enableKerning: enableKerning ?? this.enableKerning,
      useVerticalGlyphs: useVerticalGlyphs ?? this.useVerticalGlyphs,
    );
  }
}
