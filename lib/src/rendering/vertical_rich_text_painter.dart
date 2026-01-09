import 'package:flutter/material.dart';
import '../models/vertical_text_span.dart';
import '../models/vertical_text_style.dart';
import '../models/kinsoku_method.dart';
import '../utils/character_classifier.dart';
import '../utils/rotation_rules.dart';
import '../utils/kerning_processor.dart';
import '../utils/kinsoku_processor.dart';
import '../utils/yakumono_adjuster.dart';

/// Custom painter for vertical rich text with multiple styles
class VerticalRichTextPainter extends CustomPainter {
  final VerticalTextSpan textSpan;
  final double maxHeight;
  final bool showGrid;

  VerticalRichTextPainter({
    required this.textSpan,
    this.maxHeight = 0,
    this.showGrid = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Flatten the span tree to get styled characters
    final styledChars = textSpan.flatten();
    if (styledChars.isEmpty) return;

    // Layout each character with its specific style
    final layouts = _layoutStyledCharacters(styledChars, size);

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, layouts);
    }

    // Draw each character
    for (final layout in layouts) {
      _drawCharacter(canvas, layout);
    }
  }

  List<_StyledCharacterLayout> _layoutStyledCharacters(
    List<StyledCharacter> styledChars,
    Size size,
  ) {
    final layouts = <_StyledCharacterLayout>[];

    // Calculate starting X position (right edge)
    final firstFontSize = styledChars.isNotEmpty
        ? (styledChars[0].style.baseStyle.fontSize ?? 16.0)
        : 16.0;
    double currentY = 0.0;
    double currentX = size.width - firstFontSize;
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
      // For rotated characters (90 degrees), the advance should be based on the
      // text width (which becomes the vertical extent after rotation)
      double advance;
      if (rotation != 0.0) {
        // Rotated character: use actual text width for advance
        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: style.baseStyle.copyWith(fontSize: charFontSize),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        advance = textPainter.width + style.characterSpacing;
      } else {
        // Non-rotated character: use fontSize
        advance = fontSize + style.characterSpacing;

        // Apply half-width yakumono adjustment
        if (style.enableHalfWidthYakumono) {
          final yakumonoWidth = YakumonoAdjuster.getYakumonoWidth(char);
          if (yakumonoWidth < 1.0) {
            advance = (fontSize * yakumonoWidth) + style.characterSpacing;
          }
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
        // Determine whether to hang or wrap based on kinsoku method
        bool shouldHang = false;

        if (style.kinsokuMethod == KinsokuMethod.burasage) {
          // Burasage: Allow line-start forbidden characters (gyoto kinsoku) to hang
          if (KinsokuProcessor.isGyotoKinsoku(char)) {
            shouldHang = true;
          }
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

  void _drawGrid(Canvas canvas, List<_StyledCharacterLayout> layouts) {
    final characterPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final spacingPaint = Paint()
      ..color = Colors.orange.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerLinePaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < layouts.length; i++) {
      final layout = layouts[i];
      final x = layout.position.dx;
      final y = layout.position.dy;
      final fontSize = layout.style.baseStyle.fontSize ?? 16.0;
      final characterSpacing = layout.style.characterSpacing;

      // Use fontSize as the cell size (virtual body)
      // This is consistent for all characters regardless of actual glyph size
      final cellWidth = fontSize;
      final cellHeight = fontSize;

      // Draw character cell (fontSize × fontSize square)
      final characterRect = Rect.fromLTWH(
        x - cellWidth / 2,
        y,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(characterRect, characterPaint);

      // Draw horizontal center line (at cell center)
      final cellCenterY = y + cellHeight / 2;
      canvas.drawLine(
        Offset(x - cellWidth / 2, cellCenterY),
        Offset(x + cellWidth / 2, cellCenterY),
        centerLinePaint,
      );

      // Draw vertical center line for character cell
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + cellHeight),
        centerLinePaint,
      );

      // Draw spacing area (characterSpacing) if not the last character
      if (i < layouts.length - 1) {
        final spacingHeight = characterSpacing;

        if (spacingHeight > 0) {
          final spacingRect = Rect.fromLTWH(
            x - cellWidth / 2,
            y + cellHeight,
            cellWidth,
            spacingHeight,
          );
          canvas.drawRect(spacingRect, spacingPaint);
        }
      }
    }
  }

  void _drawCharacter(Canvas canvas, _StyledCharacterLayout layout) {
    canvas.save();

    // Move to character position
    canvas.translate(layout.position.dx, layout.position.dy);

    // Create text painter with the character's specific style
    final textPainter = TextPainter(
      text: TextSpan(
        text: layout.character,
        style: layout.style.baseStyle.copyWith(fontSize: layout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Get the virtual cell size (fontSize)
    final fontSize = layout.style.baseStyle.fontSize ?? 16.0;

    // Calculate offset based on rotation
    double offsetX, offsetY;

    if (layout.rotation != 0.0) {
      // For rotated characters (90 degrees clockwise)
      canvas.rotate(layout.rotation);

      // In the rotated coordinate system, apply centering within virtual cell:
      // Horizontal center
      offsetX = 0;
      // Vertical positioning
      offsetY = -textPainter.width;
    } else {
      // For non-rotated characters
      // Center horizontally (X axis) within the virtual cell
      offsetX = -(textPainter.width / 2);
      // Center vertically (Y axis) within the virtual cell (fontSize)
      offsetY = (fontSize - textPainter.height) / 2;
    }

    textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VerticalRichTextPainter oldDelegate) {
    return oldDelegate.textSpan != textSpan ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.showGrid != showGrid;
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
