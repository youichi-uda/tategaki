import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kinsoku_method.dart';
import '../utils/character_classifier.dart';
import '../utils/rotation_rules.dart';
import '../utils/kerning_processor.dart';
import '../utils/kinsoku_processor.dart';
import '../utils/yakumono_adjuster.dart';

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

    double currentY = 0.0;
    double currentX = startX;
    int lineStartIndex = 0;

    for (int i = 0; i < text.length; i++) {
      // Skip characters that are part of tatechuyoko (except the first one)
      if (tatechuyokoIndices != null && tatechuyokoIndices.contains(i)) {
        // Check if this is the first character of a tatechuyoko range
        if (i == 0 || !tatechuyokoIndices.contains(i - 1)) {
          // This is the first character - create a placeholder layout
          final char = text[i];
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

      final char = text[i];
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
      if (style.enableGyotoIndent && layouts.isEmpty || (layouts.isNotEmpty && layouts.last.position.dx != currentX)) {
        // This is a line start
        xOffset = YakumonoAdjuster.getGyotoIndent(char) * fontSize;
      }

      // Apply yakumono position adjustment
      Offset position = Offset(currentX + xOffset, currentY);
      if (style.adjustYakumono) {
        position = YakumonoAdjuster.adjustPosition(char, position, style);
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

      // Calculate advance
      // For rotated characters (90 degrees), the advance should be based on the
      // text width (which becomes the vertical extent after rotation)
      double advance;
      if (rotation != 0.0) {
        // Rotated character: use actual text width for advance
        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: TextStyle(fontSize: charFontSize),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        advance = textPainter.width + style.characterSpacing;
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
      if (style.enableKerning && i < text.length - 1) {
        final nextChar = text[i + 1];
        final kerning = KerningProcessor.getKerning(char, nextChar);
        advance += kerning * fontSize;
      }

      // Apply consecutive yakumono spacing
      if (i < text.length - 1) {
        final nextChar = text[i + 1];
        final yakumonoSpacing = YakumonoAdjuster.getConsecutiveYakumonoSpacing(
          char,
          nextChar,
          useVerticalGlyphs: style.useVerticalGlyphs,
        );
        advance += yakumonoSpacing * fontSize;
      }

      currentY += advance;

      // Add space for warichu if this is the end of a warichu range
      if (warichuHeights != null && warichuHeights.containsKey(i)) {
        currentY += warichuHeights[i]!;
      }

      // Handle line wrapping with kinsoku processing
      if (maxHeight > 0 && currentY > maxHeight) {
        // Determine whether to hang or wrap based on character type
        // Small characters (。、) can hang (burasage)
        // Full-size characters (！？…… etc) must be pushed in (oikomi)
        bool shouldHang = false;

        if (style.kinsokuMethod == KinsokuMethod.burasage) {
          // Only allow hanging for small characters that are explicitly allowed
          if (KinsokuProcessor.canHangAtLineEnd(char)) {
            shouldHang = true;
          }
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
            currentY = 0.0;

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
                newPosition = YakumonoAdjuster.adjustPosition(layout.character, newPosition, style);
              }

              layouts[j] = CharacterLayout(
                character: layout.character,
                position: newPosition,
                rotation: layout.rotation,
                fontSize: layout.fontSize,
                type: layout.type,
                textIndex: layout.textIndex,
              );

              // Advance for next character
              double moveAdvance;
              if (layout.rotation != 0.0) {
                // Rotated character: use actual text width for advance
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: layout.character,
                    style: TextStyle(fontSize: layout.fontSize),
                  ),
                  textDirection: TextDirection.ltr,
                );
                textPainter.layout();
                moveAdvance = textPainter.width + style.characterSpacing;
              } else {
                // Non-rotated character: use fontSize
                moveAdvance = layout.fontSize + style.characterSpacing;
              }

              // Apply half-width yakumono adjustment
              if (style.enableHalfWidthYakumono) {
                final yakumonoWidth = YakumonoAdjuster.getYakumonoWidth(layout.character);
                if (yakumonoWidth < 1.0) {
                  moveAdvance = (layout.fontSize * yakumonoWidth) + style.characterSpacing;
                }
              }

              // Apply kerning if there's a next character in the original text
              if (style.enableKerning && layout.textIndex < text.length - 1) {
                final nextChar = text[layout.textIndex + 1];
                final kerning = KerningProcessor.getKerning(layout.character, nextChar);
                moveAdvance += kerning * layout.fontSize;
              }

              // Apply consecutive yakumono spacing
              if (layout.textIndex < text.length - 1) {
                final nextChar = text[layout.textIndex + 1];
                final yakumonoSpacing = YakumonoAdjuster.getConsecutiveYakumonoSpacing(
                  layout.character,
                  nextChar,
                  useVerticalGlyphs: style.useVerticalGlyphs,
                );
                moveAdvance += yakumonoSpacing * layout.fontSize;
              }

              currentY += moveAdvance;
            }

            lineStartIndex = breakPosition;
          } else {
            // breakPosition == i, need to move current character to next line
            currentX -= fontSize + style.lineSpacing;
            currentY = 0.0;

            // Recalculate position for current character (i) at start of new line
            double newXOffset = 0.0;
            if (style.enableGyotoIndent) {
              newXOffset = YakumonoAdjuster.getGyotoIndent(char) * fontSize;
            }

            Offset newPosition = Offset(currentX + newXOffset, currentY);
            if (style.adjustYakumono) {
              newPosition = YakumonoAdjuster.adjustPosition(char, newPosition, style);
            }

            layouts[layouts.length - 1] = CharacterLayout(
              character: char,
              position: newPosition,
              rotation: rotation,
              fontSize: charFontSize,
              type: type,
              textIndex: i,
            );

            // Recalculate advance for current character
            double moveAdvance;
            if (rotation != 0.0) {
              // Rotated character: use actual text width for advance
              final textPainter = TextPainter(
                text: TextSpan(
                  text: char,
                  style: TextStyle(fontSize: charFontSize),
                ),
                textDirection: TextDirection.ltr,
              );
              textPainter.layout();
              moveAdvance = textPainter.width + style.characterSpacing;
            } else {
              // Non-rotated character: use fontSize
              moveAdvance = fontSize + style.characterSpacing;
            }

            if (style.enableHalfWidthYakumono) {
              final yakumonoWidth = YakumonoAdjuster.getYakumonoWidth(char);
              if (yakumonoWidth < 1.0) {
                moveAdvance = (fontSize * yakumonoWidth) + style.characterSpacing;
              }
            }

            currentY += moveAdvance;
            lineStartIndex = i;
          }
        }
        // If shouldHang is true, we don't wrap and let the character hang
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

        // Calculate ruby text height
        double rubyTextHeight = 0;
        for (int i = 0; i < rubySubstring.length; i++) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: rubySubstring[i],
              style: (style.rubyStyle ?? style.baseStyle).copyWith(fontSize: rubyFontSize),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          rubyTextHeight += textPainter.height;
        }

        // Center ruby vertically with the base text
        final rubyY = baseY + (baseTextHeight - rubyTextHeight) / 2;
        final rubyX = lineX + baseFontSize * 0.75;

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
}
