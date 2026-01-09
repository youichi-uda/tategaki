import 'package:flutter/material.dart';
import '../models/vertical_text_span.dart';
import '../models/vertical_text_style.dart';
import '../utils/character_classifier.dart';
import '../utils/rotation_rules.dart';
import '../utils/kerning_processor.dart';
import '../utils/kinsoku_processor.dart';
import '../utils/yakumono_adjuster.dart';
import 'text_layouter.dart';

/// Custom painter for vertical rich text with multiple styles
class VerticalRichTextPainter extends CustomPainter {
  final VerticalTextSpan textSpan;
  final double maxHeight;

  VerticalRichTextPainter({
    required this.textSpan,
    this.maxHeight = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Flatten the span tree to get styled characters
    final styledChars = textSpan.flatten();
    if (styledChars.isEmpty) return;

    // Layout each character with its specific style
    final layouts = _layoutStyledCharacters(styledChars);

    // Draw each character
    for (final layout in layouts) {
      _drawCharacter(canvas, layout);
    }
  }

  List<_StyledCharacterLayout> _layoutStyledCharacters(
    List<StyledCharacter> styledChars,
  ) {
    final layouts = <_StyledCharacterLayout>[];

    double currentY = 0.0;
    double currentX = 0.0;
    int lineStartIndex = 0;

    for (int i = 0; i < styledChars.length; i++) {
      final styledChar = styledChars[i];
      final char = styledChar.character;
      final style = styledChar.style;
      final type = CharacterClassifier.classify(char);
      final fontSize = style.baseStyle.fontSize ?? 16.0;

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
      if (style.enableGyotoIndent &&
          (layouts.isEmpty || layouts.last.position.dx != currentX)) {
        xOffset = YakumonoAdjuster.getGyotoIndent(char) * fontSize;
      }

      // Apply yakumono position adjustment
      Offset position = Offset(currentX + xOffset, currentY);
      if (style.adjustYakumono) {
        position = YakumonoAdjuster.adjustPosition(char, position, style);
      }

      // Create layout
      layouts.add(_StyledCharacterLayout(
        character: char,
        position: position,
        rotation: rotation,
        fontSize: charFontSize,
        style: style,
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

      // Apply kerning if enabled
      if (style.enableKerning && i < styledChars.length - 1) {
        final nextChar = styledChars[i + 1].character;
        final kerning = KerningProcessor.getKerning(char, nextChar);
        advance += kerning * fontSize;
      }

      // Apply consecutive yakumono spacing
      if (i < styledChars.length - 1) {
        final nextChar = styledChars[i + 1].character;
        final yakumonoSpacing =
            YakumonoAdjuster.getConsecutiveYakumonoSpacing(char, nextChar);
        advance += yakumonoSpacing * fontSize;
      }

      currentY += advance;

      // Handle line wrapping
      if (maxHeight > 0 && currentY > maxHeight) {
        // Check if current character can hang
        bool shouldHang = false;
        if (style.enableBurasageGumi && YakumonoAdjuster.canHang(char)) {
          shouldHang = true;
        }

        if (!shouldHang) {
          // Find proper break position
          final fullText = textSpan.fullText;
          int breakPosition = i;

          for (int j = i; j >= lineStartIndex; j--) {
            if (KinsokuProcessor.canBreakAt(fullText, j)) {
              breakPosition = j;
              break;
            }
          }

          // Move characters to next line if needed
          if (breakPosition < i) {
            currentX -= fontSize + style.lineSpacing;
            currentY = 0.0;

            // Recalculate positions for moved characters
            for (int j = breakPosition + 1; j < layouts.length; j++) {
              final layout = layouts[j];
              final layoutStyle = layout.style;

              double newXOffset = 0.0;
              if (layoutStyle.enableGyotoIndent && j == breakPosition + 1) {
                newXOffset = YakumonoAdjuster.getGyotoIndent(layout.character) *
                    layout.fontSize;
              }

              Offset newPosition = Offset(currentX + newXOffset, currentY);
              if (layoutStyle.adjustYakumono) {
                newPosition = YakumonoAdjuster.adjustPosition(
                  layout.character,
                  newPosition,
                  layoutStyle,
                );
              }

              layouts[j] = _StyledCharacterLayout(
                character: layout.character,
                position: newPosition,
                rotation: layout.rotation,
                fontSize: layout.fontSize,
                style: layout.style,
              );

              double moveAdvance =
                  layout.fontSize + layoutStyle.characterSpacing;

              if (layoutStyle.enableHalfWidthYakumono) {
                final yakumonoWidth =
                    YakumonoAdjuster.getYakumonoWidth(layout.character);
                if (yakumonoWidth < 1.0) {
                  moveAdvance =
                      (layout.fontSize * yakumonoWidth) + layoutStyle.characterSpacing;
                }
              }

              if (layoutStyle.enableKerning && j < layouts.length - 1) {
                final nextChar = layouts[j + 1].character;
                final kerning =
                    KerningProcessor.getKerning(layout.character, nextChar);
                moveAdvance += kerning * layout.fontSize;
              }

              if (j < layouts.length - 1) {
                final nextChar = layouts[j + 1].character;
                final yakumonoSpacing =
                    YakumonoAdjuster.getConsecutiveYakumonoSpacing(
                  layout.character,
                  nextChar,
                );
                moveAdvance += yakumonoSpacing * layout.fontSize;
              }

              currentY += moveAdvance;
            }

            lineStartIndex = breakPosition + 1;
          } else {
            currentY = 0.0;
            currentX -= fontSize + style.lineSpacing;
            lineStartIndex = i + 1;
          }
        }
      }
    }

    return layouts;
  }

  void _drawCharacter(Canvas canvas, _StyledCharacterLayout layout) {
    canvas.save();

    // Move to character position
    canvas.translate(layout.position.dx, layout.position.dy);

    // Rotate if needed
    if (layout.rotation != 0.0) {
      canvas.rotate(layout.rotation);
    }

    // Create text painter with the character's specific style
    final textPainter = TextPainter(
      text: TextSpan(
        text: layout.character,
        style: layout.style.baseStyle.copyWith(fontSize: layout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(0, 0));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VerticalRichTextPainter oldDelegate) {
    return oldDelegate.textSpan != textSpan ||
        oldDelegate.maxHeight != maxHeight;
  }
}

/// Internal class for styled character layout
class _StyledCharacterLayout {
  final String character;
  final Offset position;
  final double rotation;
  final double fontSize;
  final VerticalTextStyle style;

  const _StyledCharacterLayout({
    required this.character,
    required this.position,
    required this.rotation,
    required this.fontSize,
    required this.style,
  });
}
