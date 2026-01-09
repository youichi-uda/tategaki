import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
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

  const CharacterLayout({
    required this.character,
    required this.position,
    required this.rotation,
    required this.fontSize,
    required this.type,
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
  }) {
    final layouts = <CharacterLayout>[];
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    double currentY = 0.0;
    double currentX = startX;
    int lineStartIndex = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final type = CharacterClassifier.classify(char);

      // Calculate character size
      double charFontSize = fontSize;
      if (CharacterClassifier.isSmallKana(char)) {
        charFontSize = fontSize * 0.7;
      }

      // Calculate rotation
      final rotation = RotationRules.getRotationAngle(
        char,
        type,
        style.rotateLatinCharacters,
      );

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
      ));

      // Calculate advance
      double advance = fontSize + style.characterSpacing;

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
        final yakumonoSpacing = YakumonoAdjuster.getConsecutiveYakumonoSpacing(char, nextChar);
        advance += yakumonoSpacing * fontSize;
      }

      currentY += advance;

      // Handle line wrapping with kinsoku processing
      if (maxHeight > 0 && currentY > maxHeight) {
        // Check if current character can hang (burasage-gumi)
        bool shouldHang = false;
        if (style.enableBurasageGumi && YakumonoAdjuster.canHang(char)) {
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
            currentY = 0.0;

            // Recalculate positions for moved characters
            for (int j = breakPosition + 1; j < layouts.length; j++) {
              final layout = layouts[j];

              // Recalculate gyoto indent for first character of new line
              double newXOffset = 0.0;
              if (style.enableGyotoIndent && j == breakPosition + 1) {
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
              );

              // Advance for next character
              double moveAdvance = layout.fontSize + style.characterSpacing;

              // Apply half-width yakumono adjustment
              if (style.enableHalfWidthYakumono) {
                final yakumonoWidth = YakumonoAdjuster.getYakumonoWidth(layout.character);
                if (yakumonoWidth < 1.0) {
                  moveAdvance = (layout.fontSize * yakumonoWidth) + style.characterSpacing;
                }
              }

              if (style.enableKerning && j < layouts.length - 1) {
                final nextChar = layouts[j + 1].character;
                final kerning = KerningProcessor.getKerning(layout.character, nextChar);
                moveAdvance += kerning * layout.fontSize;
              }

              // Apply consecutive yakumono spacing
              if (j < layouts.length - 1) {
                final nextChar = layouts[j + 1].character;
                final yakumonoSpacing = YakumonoAdjuster.getConsecutiveYakumonoSpacing(
                  layout.character,
                  nextChar,
                );
                moveAdvance += yakumonoSpacing * layout.fontSize;
              }

              currentY += moveAdvance;
            }

            lineStartIndex = breakPosition + 1;
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
            );

            // Recalculate advance for current character
            double moveAdvance = fontSize + style.characterSpacing;
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
      if (ruby.startIndex >= characterLayouts.length) continue;

      // Get position from first character in ruby range
      final baseLayout = characterLayouts[ruby.startIndex];
      final baseX = baseLayout.position.dx;
      final baseY = baseLayout.position.dy;

      // Calculate actual height covered by base text
      // Use the actual layout positions: from first char Y to last char Y + last char's actual height
      final lastCharIndex = (ruby.startIndex + ruby.length - 1).clamp(0, characterLayouts.length - 1);
      final lastCharLayout = characterLayouts[lastCharIndex];
      final lastCharY = lastCharLayout.position.dy;

      // Get the actual rendered height of the last character
      final lastCharPainter = TextPainter(
        text: TextSpan(
          text: lastCharLayout.character,
          style: style.baseStyle.copyWith(fontSize: lastCharLayout.fontSize),
        ),
        textDirection: TextDirection.ltr,
      );
      lastCharPainter.layout();

      // Base text height is from first character Y to last character Y + last character's actual height
      final baseTextHeight = (lastCharY - baseY) + lastCharPainter.height;

      // Calculate total height of ruby text using actual TextPainter height
      double rubyTextHeight = 0;
      for (int i = 0; i < ruby.ruby.length; i++) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: ruby.ruby[i],
            style: (style.rubyStyle ?? style.baseStyle).copyWith(fontSize: rubyFontSize),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        rubyTextHeight += textPainter.height;
      }

      // Center ruby vertically with the base text
      final rubyY = baseY + (baseTextHeight - rubyTextHeight) / 2;

      // Place ruby to the right of base text (move further right)
      final rubyX = baseX + baseFontSize * 0.75;

      layouts.add(RubyLayout(
        position: Offset(rubyX, rubyY),
        ruby: ruby.ruby,
        fontSize: rubyFontSize,
      ));
    }

    return layouts;
  }
}
