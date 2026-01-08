import 'package:flutter/painting.dart';

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

  /// Enable burasage-gumi (hanging punctuation at line end)
  final bool enableBurasageGumi;

  /// Enable half-width yakumono processing
  final bool enableHalfWidthYakumono;

  /// Enable gyoto indent (indenting opening brackets at line start)
  final bool enableGyotoIndent;

  /// Enable kerning (advanced character spacing)
  final bool enableKerning;

  const VerticalTextStyle({
    this.baseStyle = const TextStyle(),
    this.lineSpacing = 0.0,
    this.characterSpacing = 0.0,
    this.rotateLatinCharacters = true,
    this.adjustYakumono = true,
    this.rubyStyle,
    this.enableBurasageGumi = false,
    this.enableHalfWidthYakumono = false,
    this.enableGyotoIndent = false,
    this.enableKerning = false,
  });

  /// Create a copy with modified properties
  VerticalTextStyle copyWith({
    TextStyle? baseStyle,
    double? lineSpacing,
    double? characterSpacing,
    bool? rotateLatinCharacters,
    bool? adjustYakumono,
    TextStyle? rubyStyle,
    bool? enableBurasageGumi,
    bool? enableHalfWidthYakumono,
    bool? enableGyotoIndent,
    bool? enableKerning,
  }) {
    return VerticalTextStyle(
      baseStyle: baseStyle ?? this.baseStyle,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      characterSpacing: characterSpacing ?? this.characterSpacing,
      rotateLatinCharacters: rotateLatinCharacters ?? this.rotateLatinCharacters,
      adjustYakumono: adjustYakumono ?? this.adjustYakumono,
      rubyStyle: rubyStyle ?? this.rubyStyle,
      enableBurasageGumi: enableBurasageGumi ?? this.enableBurasageGumi,
      enableHalfWidthYakumono: enableHalfWidthYakumono ?? this.enableHalfWidthYakumono,
      enableGyotoIndent: enableGyotoIndent ?? this.enableGyotoIndent,
      enableKerning: enableKerning ?? this.enableKerning,
    );
  }
}
