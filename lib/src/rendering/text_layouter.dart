import 'package:flutter/material.dart';
import 'package:kinsoku/kinsoku.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/text_decoration.dart';
import '../utils/rotation_rules.dart';
import '../utils/kinsoku_adapter.dart';

/// Layout information for a single character
class CharacterLayout {
  /// The character string
  final String character;

  /// Position to draw the character
  final Offset position;

  /// Rotation angle in radians
  final double rotation;

  /// Font size for this character
  final double fontSize;

  /// Character type
  final CharacterType type;

  /// Index in the original text
  final int textIndex;

  const CharacterLayout({
    required this.character,
    required this.position,
    required this.rotation,
    required this.fontSize,
    required this.type,
    required this.textIndex,
  });
}

/// Layout information for ruby text
class RubyLayout {
  /// Position to draw the ruby text
  final Offset position;

  /// The ruby text string
  final String ruby;

  /// Font size for ruby
  final double fontSize;

  const RubyLayout({
    required this.position,
    required this.ruby,
    required this.fontSize,
  });
}

/// Text layouter for vertical text
class TextLayouter {
  // Reusable TextPainter instance to avoid repeated allocations
  static final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  /// Calculate the advance (vertical distance) for a character
  double _calculateAdvance(
    String char,
    double rotation,
    double charFontSize,
    double fontSize,
    VerticalTextStyle style,
    String text,
    int textIndex,
  ) {
    double advance;
    if (rotation != 0.0) {
      // Rotated character: use actual text width for advance
      _textPainter.text = TextSpan(
        text: char,
        style: TextStyle(fontSize: charFontSize),
      );
      _textPainter.layout();
      advance = _textPainter.width + style.characterSpacing;
    } else {
      // Non-rotated character: use fontSize
      advance = fontSize + style.characterSpacing;
    }

    // Apply half-width yakumono adjustment
    if (style.enableHalfWidthYakumono) {
      final yakumonoWidth = YakumonoAdjuster.getYakumonoWidth(char);
      if (yakumonoWidth < 1.0) {
        advance = (fontSize * yakumonoWidth) + style.characterSpacing;
      }
    }

    // Apply kerning if enabled and there's a next character
    if (style.enableKerning && textIndex < text.length - 1) {
      final nextChar = text[textIndex + 1];
      final kerning = KerningProcessor.getKerning(char, nextChar);
      advance += kerning * fontSize;
    }

    // Apply consecutive yakumono spacing
    if (textIndex < text.length - 1) {
      final nextChar = text[textIndex + 1];
      final yakumonoSpacing = YakumonoAdjuster.getConsecutiveYakumonoSpacing(
        char,
        nextChar,
        useVerticalGlyphs: style.useVerticalGlyphs,
      );
      advance += yakumonoSpacing * fontSize;
    }

    return advance;
  }

  /// Layout text characters for vertical display
  ///
  /// Returns a list of character layouts with positions and rotations
  List<CharacterLayout> layoutText(
    String text,
    VerticalTextStyle style,
    double maxHeight, {
    double startX = 0.0,
    Set<int>? tatechuyokoIndices,
    Map<int, double>? warichuHeights,
  }) {
    final layouts = <CharacterLayout>[];
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    // Apply indent (字下げ) - shift starting Y position
    final indentOffset = style.indent * fontSize;
    // Apply firstLineIndent (段落字下げ) - only for first line
    final firstLineIndentOffset = style.firstLineIndent * fontSize;
    // First line includes both indent and firstLineIndent
    double currentY = indentOffset + firstLineIndentOffset;
    double currentX = startX;
    int lineStartIndex = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      // Handle newline characters
      if (char == '\n') {
        // Move to next column (left)
        currentX -= fontSize + style.lineSpacing;
        // Subsequent lines don't have firstLineIndent
        currentY = indentOffset;
        lineStartIndex = i + 1;
        continue;
      }

      // Skip characters that are part of tatechuyoko (except the first one)
      if (tatechuyokoIndices != null && tatechuyokoIndices.contains(i)) {
        // Check if this is the first character of a tatechuyoko range
        if (i == 0 || !tatechuyokoIndices.contains(i - 1)) {
          // This is the first character - create a placeholder layout
          final type = CharacterClassifier.classify(char);

          final position = Offset(currentX, currentY);
          layouts.add(CharacterLayout(
            character: char,
            position: position,
            rotation: 0.0,
            fontSize: fontSize,
            type: type,
            textIndex: i,
          ));

          // Advance by one character space for the entire tatechuyoko
          double advance = fontSize + style.characterSpacing;
          currentY += advance;
        }
        // Skip remaining characters in tatechuyoko range
        continue;
      }
      final type = CharacterClassifier.classify(char);

      // Use base font size for all characters
      double charFontSize = fontSize;

      // Calculate rotation
      double rotation;
      if (style.useVerticalGlyphs && type == CharacterType.yakumono) {
        // When using vertical glyphs, most characters are handled by the font
        // Characters that the font handles: ―（U+2015）、ー（U+30FC）、—（U+2014）、–（U+2013）、－（U+FF0D）、：
        // Characters that need rotation: ；
        const needsRotationWithVert = {'；'};
        if (needsRotationWithVert.contains(char)) {
          rotation = RotationRules.getRotationAngle(char, type, style.rotateLatinCharacters);
        } else {
          rotation = 0.0;
        }
      } else {
        rotation = RotationRules.getRotationAngle(
          char,
          type,
          style.rotateLatinCharacters,
        );
      }

      // Apply gyoto indent for opening brackets at line start
      double xOffset = 0.0;
      if (style.enableGyotoIndent &&
          (layouts.isEmpty || layouts.last.position.dx != currentX)) {
        // This is a line start
        xOffset = YakumonoAdjuster.getGyotoIndent(char) * fontSize;
      }

      // Apply yakumono position adjustment
      Offset position = Offset(currentX + xOffset, currentY);
      if (style.adjustYakumono) {
        position = KinsokuAdapter.adjustYakumonoPosition(char, position, style);
      }

      // Create layout
      layouts.add(CharacterLayout(
        character: char,
        position: position,
        rotation: rotation,
        fontSize: charFontSize,
        type: type,
        textIndex: i,
      ));

      // Calculate advance using helper method
      final advance = _calculateAdvance(char, rotation, charFontSize, fontSize, style, text, i);
      currentY += advance;

      // Add space for warichu if this is the end of a warichu range
      if (warichuHeights != null && warichuHeights.containsKey(i)) {
        currentY += warichuHeights[i]!;
      }

      // Handle line wrapping with kinsoku processing
      if (maxHeight > 0 && currentY > maxHeight) {
        // Determine whether to hang or wrap based on character type
        // Characters in burasageAllowed (。、）」】』〉》) will hang (burasage)
        // Other gyoto kinsoku characters (ー) will be pushed in (oikomi)
        bool shouldHang = false;

        // Check if this character can hang (based on character type only)
        if (style.enableKinsoku && KinsokuProcessor.canHangAtLineEnd(char)) {
          shouldHang = true;
        }

        if (!shouldHang) {
          // Find proper break position using kinsoku rules
          // The character at position 'i' doesn't fit and would start the next line
          // Check if breaking before 'i' (so 'i' becomes the first char of next line) is valid
          int breakPosition = i;

          // If the current character can't start a line (gyoto kinsoku),
          // we need to look back to find a valid break position
          if (!KinsokuProcessor.canBreakAt(text, i)) {
            // Look back from i-1 to find a valid break position
            for (int j = i - 1; j >= lineStartIndex; j--) {
              if (KinsokuProcessor.canBreakAt(text, j)) {
                breakPosition = j;
                break;
              }
            }
          }

          // If we need to move characters to next line
          if (breakPosition < i) {
            // Move layouts after break position to next line
            currentX -= fontSize + style.lineSpacing;
            currentY = indentOffset;  // No firstLineIndent for subsequent lines

            // Find layouts that need to be moved (textIndex >= breakPosition)
            // Recalculate positions for moved characters
            for (int j = 0; j < layouts.length; j++) {
              final layout = layouts[j];

              // Skip layouts that should stay on current line
              if (layout.textIndex < breakPosition) {
                continue;
              }

              // Recalculate gyoto indent for first character of new line
              double newXOffset = 0.0;
              if (style.enableGyotoIndent && layout.textIndex == breakPosition) {
                newXOffset = YakumonoAdjuster.getGyotoIndent(layout.character) * fontSize;
              }

              Offset newPosition = Offset(currentX + newXOffset, currentY);
              if (style.adjustYakumono) {
                newPosition = KinsokuAdapter.adjustYakumonoPosition(layout.character, newPosition, style);
              }

              layouts[j] = CharacterLayout(
                character: layout.character,
                position: newPosition,
                rotation: layout.rotation,
                fontSize: layout.fontSize,
                type: layout.type,
                textIndex: layout.textIndex,
              );

              // Advance for next character using helper method
              final moveAdvance = _calculateAdvance(
                layout.character,
                layout.rotation,
                layout.fontSize,
                fontSize,
                style,
                text,
                layout.textIndex,
              );
              currentY += moveAdvance;
            }

            lineStartIndex = breakPosition;
          } else {
            // breakPosition == i, need to move current character to next line
            currentX -= fontSize + style.lineSpacing;
            currentY = indentOffset;  // No firstLineIndent for subsequent lines

            // Recalculate position for current character (i) at start of new line
            double newXOffset = 0.0;
            if (style.enableGyotoIndent) {
              newXOffset = YakumonoAdjuster.getGyotoIndent(char) * fontSize;
            }

            Offset newPosition = Offset(currentX + newXOffset, currentY);
            if (style.adjustYakumono) {
              newPosition = KinsokuAdapter.adjustYakumonoPosition(char, newPosition, style);
            }

            layouts[layouts.length - 1] = CharacterLayout(
              character: char,
              position: newPosition,
              rotation: rotation,
              fontSize: charFontSize,
              type: type,
              textIndex: i,
            );

            // Recalculate advance for current character using helper method
            final moveAdvance = _calculateAdvance(char, rotation, charFontSize, fontSize, style, text, i);
            currentY += moveAdvance;
            lineStartIndex = i;
          }
        } else {
          // shouldHang is true - let the character hang, but move to next line for subsequent characters
          currentX -= fontSize + style.lineSpacing;
          currentY = indentOffset;  // No firstLineIndent for subsequent lines
          lineStartIndex = i + 1;
        }
      }
    }

    // Apply line alignment (jizuki, tenzuki, center)
    if (maxHeight > 0 && layouts.isNotEmpty) {
      // Group layouts by line (X coordinate with tolerance for yakumono adjustment)
      final lineWidth = fontSize + style.lineSpacing;
      final lineGroups = <int, List<int>>{};
      for (int i = 0; i < layouts.length; i++) {
        final x = layouts[i].position.dx;
        // Calculate line index based on distance from start position
        // This accounts for yakumono position adjustments
        final lineIndex = ((startX - x) / lineWidth).round();
        lineGroups.putIfAbsent(lineIndex, () => []).add(i);
      }

      // Adjust Y position for each line based on alignment
      for (final indices in lineGroups.values) {
        if (indices.isEmpty) continue;

        // Find the maximum Y coordinate in this line
        double maxY = 0.0;
        for (final idx in indices) {
          final layout = layouts[idx];
          double yEnd = layout.position.dy + layout.fontSize;
          if (yEnd > maxY) {
            maxY = yEnd;
          }
        }

        // Calculate Y offset based on alignment
        double yOffset = 0.0;
        switch (style.alignment) {
          case TextAlignment.start:
            // Top alignment (天付き) - no offset
            yOffset = 0.0;
            break;
          case TextAlignment.center:
            // Center alignment - offset to center
            yOffset = (maxHeight - maxY) / 2;
            break;
          case TextAlignment.end:
            // Bottom alignment (地付き) - offset to bottom
            yOffset = maxHeight - maxY;
            break;
        }

        // Apply offset to all characters in this line
        for (final idx in indices) {
          final layout = layouts[idx];
          layouts[idx] = CharacterLayout(
            character: layout.character,
            position: Offset(layout.position.dx, layout.position.dy + yOffset),
            rotation: layout.rotation,
            fontSize: layout.fontSize,
            type: layout.type,
            textIndex: layout.textIndex,
          );
        }
      }
    }

    return layouts;
  }

  /// Layout ruby text for given base text
  List<RubyLayout> layoutRuby(
    String baseText,
    List<RubyText> rubyList,
    VerticalTextStyle style,
    List<CharacterLayout> characterLayouts,
    List<Kenten>? kentenList,
    List<TextDecorationAnnotation>? decorationList,
  ) {
    final layouts = <RubyLayout>[];
    final baseFontSize = style.baseStyle.fontSize ?? 16.0;
    final rubyFontSize = style.rubyStyle?.fontSize ?? (baseFontSize * 0.5);

    for (final ruby in rubyList) {
      // Find all character layouts in this ruby range
      final baseLayouts = <CharacterLayout>[];
      for (final layout in characterLayouts) {
        if (layout.textIndex >= ruby.startIndex &&
            layout.textIndex < ruby.startIndex + ruby.length) {
          baseLayouts.add(layout);
        }
      }
      if (baseLayouts.isEmpty) continue;

      // Group base characters by line (same X position = same line)
      final lineGroups = <double, List<CharacterLayout>>{};
      for (final layout in baseLayouts) {
        lineGroups.putIfAbsent(layout.position.dx, () => []).add(layout);
      }

      // Sort lines by X position (right to left)
      final sortedLines = lineGroups.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      // Calculate ruby split ratios based on character count per line
      final totalChars = baseLayouts.length;
      int rubyStartIndex = 0;

      for (int lineIdx = 0; lineIdx < sortedLines.length; lineIdx++) {
        final lineEntry = sortedLines[lineIdx];
        final lineX = lineEntry.key;
        final lineChars = lineEntry.value;
        lineChars.sort((a, b) => a.position.dy.compareTo(b.position.dy));

        final lineCharCount = lineChars.length;
        final isLastLine = lineIdx == sortedLines.length - 1;

        // Calculate ruby substring for this line
        int rubyCharCount;
        if (isLastLine) {
          // Last line gets all remaining ruby characters
          rubyCharCount = ruby.ruby.length - rubyStartIndex;
        } else {
          // Calculate proportionally
          rubyCharCount = ((ruby.ruby.length * lineCharCount) / totalChars).round();
        }

        // Make sure we don't exceed the ruby string length
        rubyCharCount = rubyCharCount.clamp(0, ruby.ruby.length - rubyStartIndex);

        if (rubyCharCount == 0) continue;

        final rubySubstring = ruby.ruby.substring(rubyStartIndex, rubyStartIndex + rubyCharCount);

        // Calculate layout for this line's ruby
        final firstChar = lineChars.first;
        final lastChar = lineChars.last;
        final baseY = firstChar.position.dy;
        final baseTextHeight = (lastChar.position.dy - firstChar.position.dy) +
                               baseFontSize + style.characterSpacing;

        // Calculate ruby text height using reusable TextPainter
        double rubyTextHeight = 0;
        final rubyTextStyle = (style.rubyStyle ?? style.baseStyle).copyWith(fontSize: rubyFontSize);
        for (int i = 0; i < rubySubstring.length; i++) {
          _textPainter.text = TextSpan(
            text: rubySubstring[i],
            style: rubyTextStyle,
          );
          _textPainter.layout();
          rubyTextHeight += _textPainter.height;
        }

        // Center ruby vertically with the base text
        final rubyY = baseY + (baseTextHeight - rubyTextHeight) / 2;

        // Check if any character in this ruby range has kenten
        bool hasKenten = false;
        if (kentenList != null) {
          for (final kenten in kentenList) {
            for (final charLayout in lineChars) {
              if (charLayout.textIndex >= kenten.startIndex &&
                  charLayout.textIndex < kenten.endIndex) {
                hasKenten = true;
                break;
              }
            }
            if (hasKenten) break;
          }
        }

        // Check if any character in this ruby range has decoration
        bool hasDecoration = false;
        if (decorationList != null) {
          for (final decoration in decorationList) {
            for (final charLayout in lineChars) {
              if (charLayout.textIndex >= decoration.startIndex &&
                  charLayout.textIndex < decoration.endIndex) {
                hasDecoration = true;
                break;
              }
            }
            if (hasDecoration) break;
          }
        }

        // Position ruby to the right of the character
        // If kenten or decoration exists, add extra space to avoid overlap
        // Kenten needs more space (0.5), decoration needs less (0.25)
        double sideOffset = 0.0;
        if (hasKenten) {
          sideOffset = baseFontSize * 0.5;
        } else if (hasDecoration) {
          sideOffset = baseFontSize * 0.25;
        }
        final rubyX = lineX + baseFontSize * 0.75 + sideOffset;

        layouts.add(RubyLayout(
          position: Offset(rubyX, rubyY),
          ruby: rubySubstring,
          fontSize: rubyFontSize,
        ));

        rubyStartIndex += rubyCharCount;
      }
    }

    return layouts;
  }

  /// Calculate the required width for vertical text layout
  ///
  /// This performs a layout pass to determine the actual number of lines
  /// needed, accounting for kinsoku, rotated characters, etc.
  double calculateRequiredWidth(
    String text,
    VerticalTextStyle style,
    double maxHeight, {
    double startX = 0.0,
    Set<int>? tatechuyokoIndices,
    Map<int, double>? warichuHeights,
    double annotationWidth = 0.0,
  }) {
    // Perform layout to get actual character positions
    final layouts = layoutText(
      text,
      style,
      maxHeight,
      startX: startX,
      tatechuyokoIndices: tatechuyokoIndices,
      warichuHeights: warichuHeights,
    );

    if (layouts.isEmpty) {
      return annotationWidth;
    }

    // Find minimum X coordinate from all character positions
    double minX = layouts.first.position.dx;
    for (final layout in layouts) {
      if (layout.position.dx < minX) {
        minX = layout.position.dx;
      }
    }

    final fontSize = style.baseStyle.fontSize ?? 16.0;

    // Calculate required width: startX - minX + fontSize (for rightmost line) + annotationWidth
    return startX - minX + fontSize + annotationWidth;
  }
}
