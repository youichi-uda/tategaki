import 'package:flutter/painting.dart';
import 'package:kinsoku/kinsoku.dart';

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

  /// Enable kinsoku processing (line breaking rules)
  /// When enabled, characters in burasageAllowed (。、）」】』〉》) will hang,
  /// and other gyoto kinsoku characters (ー) will be pushed in (oikomi).
  /// Default: true
  final bool enableKinsoku;

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

  /// Line alignment
  /// - [TextAlignment.start]: Top alignment (天付き)
  /// - [TextAlignment.center]: Center alignment
  /// - [TextAlignment.end]: Bottom alignment (地付き)
  final TextAlignment alignment;

  /// Text indent in character units (字下げ)
  ///
  /// For vertical text, this shifts the starting position down by
  /// `indent * fontSize` pixels.
  ///
  /// Example: `indent: 2` shifts text down by 2 character widths.
  final int indent;

  const VerticalTextStyle({
    this.baseStyle = const TextStyle(),
    this.lineSpacing = 0.0,
    this.characterSpacing = 0.0,
    this.rotateLatinCharacters = true,
    this.adjustYakumono = true,
    this.rubyStyle,
    this.enableKinsoku = true,
    this.enableHalfWidthYakumono = true,
    this.enableGyotoIndent = true,
    this.enableKerning = true,
    this.useVerticalGlyphs = false,
    this.alignment = TextAlignment.center,
    this.indent = 0,
  });

  /// Create a copy with modified properties
  VerticalTextStyle copyWith({
    TextStyle? baseStyle,
    double? lineSpacing,
    double? characterSpacing,
    bool? rotateLatinCharacters,
    bool? adjustYakumono,
    TextStyle? rubyStyle,
    bool? enableKinsoku,
    bool? enableHalfWidthYakumono,
    bool? enableGyotoIndent,
    bool? enableKerning,
    bool? useVerticalGlyphs,
    TextAlignment? alignment,
    int? indent,
  }) {
    return VerticalTextStyle(
      baseStyle: baseStyle ?? this.baseStyle,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      characterSpacing: characterSpacing ?? this.characterSpacing,
      rotateLatinCharacters: rotateLatinCharacters ?? this.rotateLatinCharacters,
      adjustYakumono: adjustYakumono ?? this.adjustYakumono,
      rubyStyle: rubyStyle ?? this.rubyStyle,
      enableKinsoku: enableKinsoku ?? this.enableKinsoku,
      enableHalfWidthYakumono: enableHalfWidthYakumono ?? this.enableHalfWidthYakumono,
      enableGyotoIndent: enableGyotoIndent ?? this.enableGyotoIndent,
      enableKerning: enableKerning ?? this.enableKerning,
      useVerticalGlyphs: useVerticalGlyphs ?? this.useVerticalGlyphs,
      alignment: alignment ?? this.alignment,
      indent: indent ?? this.indent,
    );
  }

  /// Create a VerticalTextStyle configured for using vertical glyphs (OpenType 'vert' feature)
  ///
  /// This factory method returns a style optimized for fonts with proper vertical glyph support.
  /// When using vertical glyphs, most punctuation rotation is handled by the font,
  /// so manual adjustments are disabled.
  factory VerticalTextStyle.withVerticalGlyphs({
    TextStyle baseStyle = const TextStyle(),
    double lineSpacing = 0.0,
    double characterSpacing = 0.0,
    bool rotateLatinCharacters = true,
    TextStyle? rubyStyle,
    bool enableKinsoku = true,
  }) {
    return VerticalTextStyle(
      baseStyle: baseStyle,
      lineSpacing: lineSpacing,
      characterSpacing: characterSpacing,
      rotateLatinCharacters: rotateLatinCharacters,
      adjustYakumono: false,  // Font handles yakumono positioning
      rubyStyle: rubyStyle,
      enableKinsoku: enableKinsoku,
      enableHalfWidthYakumono: false,  // Font handles this
      enableGyotoIndent: false,  // Font handles this
      enableKerning: false,  // Font handles this
      useVerticalGlyphs: true,
    );
  }
}
