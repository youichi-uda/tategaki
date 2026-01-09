import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/tatechuyoko.dart';
import '../utils/kenten_renderer.dart';
import '../utils/tatechuyoko_detector.dart';
import 'text_layouter.dart';

/// Custom painter for vertical text
class VerticalTextPainter extends CustomPainter {
  final String text;
  final VerticalTextStyle style;
  final List<RubyText>? ruby;
  final List<Kenten>? kenten;
  final List<Tatechuyoko>? tatechuyoko;
  final bool autoTatechuyoko;
  final TextLayouter layouter;
  final double maxHeight;
  final bool showGrid;

  VerticalTextPainter({
    required this.text,
    required this.style,
    this.ruby,
    this.kenten,
    this.tatechuyoko,
    this.autoTatechuyoko = false,
    TextLayouter? layouter,
    this.maxHeight = 0,
    this.showGrid = false,
  }) : layouter = layouter ?? TextLayouter();

  @override
  void paint(Canvas canvas, Size size) {
    // Get tatechuyoko ranges
    List<Tatechuyoko> tatechuyokoRanges = tatechuyoko ?? [];
    if (autoTatechuyoko) {
      tatechuyokoRanges = TatechuyokoDetector.detectAuto(text);
    }

    // Create set of indices that are part of tatechuyoko
    final tatechuyokoIndices = <int>{};
    for (final tcy in tatechuyokoRanges) {
      for (int i = tcy.startIndex; i < tcy.startIndex + tcy.length; i++) {
        tatechuyokoIndices.add(i);
      }
    }

    // Calculate starting X position (right edge minus one character width)
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final startX = size.width - fontSize;

    // Layout the text (pass tatechuyoko indices to skip them in layout)
    final characterLayouts = layouter.layoutText(
      text,
      style,
      maxHeight,
      startX: startX,
      tatechuyokoIndices: tatechuyokoIndices,
    );

    // Draw each character (skip tatechuyoko characters)
    for (final layout in characterLayouts) {
      if (!tatechuyokoIndices.contains(layout.textIndex)) {
        _drawCharacter(canvas, layout);
      }
    }

    // Draw tatechuyoko
    for (final tcy in tatechuyokoRanges) {
      _drawTatechuyoko(canvas, tcy, characterLayouts);
    }

    // Draw ruby if present
    if (ruby != null && ruby!.isNotEmpty) {
      final rubyLayouts = layouter.layoutRuby(text, ruby!, style, characterLayouts);
      for (final rubyLayout in rubyLayouts) {
        _drawRuby(canvas, rubyLayout);
      }
    }

    // Draw kenten if present
    if (kenten != null && kenten!.isNotEmpty) {
      _drawKenten(canvas, characterLayouts);
    }

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, characterLayouts, size);
    }
  }

  void _drawGrid(Canvas canvas, List<CharacterLayout> characterLayouts, Size size) {
    final baseFontSize = style.baseStyle.fontSize ?? 16.0;

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

    for (int i = 0; i < characterLayouts.length; i++) {
      final charLayout = characterLayouts[i];
      final x = charLayout.position.dx;
      final y = charLayout.position.dy;

      // Use fontSize as the cell size (virtual body)
      // This is consistent for all characters regardless of actual glyph size
      final cellWidth = baseFontSize;
      final cellHeight = baseFontSize;

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
      if (i < characterLayouts.length - 1) {
        final spacingHeight = style.characterSpacing;

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

  void _drawCharacter(Canvas canvas, CharacterLayout layout) {
    canvas.save();

    // Move to character position
    canvas.translate(layout.position.dx, layout.position.dy);

    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(
        text: layout.character,
        style: style.baseStyle.copyWith(fontSize: layout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Calculate offset based on rotation
    double offsetX, offsetY;

    // Get the virtual cell size (fontSize)
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    if (layout.rotation != 0.0) {
      // For rotated characters (90 degrees clockwise)
      // Rotate first
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

    // Draw the character
    textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  void _drawRuby(Canvas canvas, RubyLayout layout) {
    // Draw ruby characters vertically one by one
    final rubyFontSize = layout.fontSize;
    double currentY = layout.position.dy;

    for (int i = 0; i < layout.ruby.length; i++) {
      final char = layout.ruby[i];

      final textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: (style.rubyStyle ?? style.baseStyle).copyWith(
            fontSize: rubyFontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Center the character horizontally
      final offsetX = -(textPainter.width / 2);
      textPainter.paint(canvas, Offset(layout.position.dx + offsetX, currentY));

      // Move to next character position (vertically)
      // Use actual text height instead of fontSize
      currentY += textPainter.height;
    }
  }

  void _drawKenten(Canvas canvas, List<CharacterLayout> characterLayouts) {
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final color = style.baseStyle.color ?? Colors.black;

    for (final kentenItem in kenten!) {
      for (int textIdx = kentenItem.startIndex; textIdx < kentenItem.endIndex; textIdx++) {
        // Find the layout for this text index
        CharacterLayout? charLayout;
        for (final layout in characterLayouts) {
          if (layout.textIndex == textIdx) {
            charLayout = layout;
            break;
          }
        }
        if (charLayout == null) continue;

        final kentenPos = KentenRenderer.getKentenPosition(
          charLayout.position,
          fontSize,
          true, // isVertical
        );

        KentenRenderer.drawKenten(
          canvas,
          kentenPos,
          kentenItem.style,
          fontSize,
          color,
        );
      }
    }
  }

  void _drawTatechuyoko(
    Canvas canvas,
    Tatechuyoko tcy,
    List<CharacterLayout> characterLayouts,
  ) {
    if (tcy.startIndex >= text.length) return;

    // Extract tatechuyoko text
    final endIndex = (tcy.startIndex + tcy.length).clamp(0, text.length);
    final tcyText = text.substring(tcy.startIndex, endIndex);

    // Find the layout for the first character of this tatechuyoko range
    CharacterLayout? baseLayout;
    for (final layout in characterLayouts) {
      if (layout.textIndex == tcy.startIndex) {
        baseLayout = layout;
        break;
      }
    }
    if (baseLayout == null) return;

    // Calculate tatechuyoko layout
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final tcyLayout = TatechuyokoDetector.layoutTatechuyoko(
      tcyText,
      baseLayout.position,
      fontSize,
    );

    canvas.save();

    // Draw tatechuyoko text horizontally (no rotation)
    final textPainter = TextPainter(
      text: TextSpan(
        text: tcyText,
        style: style.baseStyle.copyWith(fontSize: tcyLayout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Center the tatechuyoko text both horizontally and vertically in the character cell
    // Horizontal: center at the character position (same as regular characters)
    final offsetX = tcyLayout.position.dx - (textPainter.width / 2);
    // Vertical: center within the fontSize-based virtual cell
    final offsetY = tcyLayout.position.dy + (fontSize - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VerticalTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.ruby != ruby ||
        oldDelegate.kenten != kenten ||
        oldDelegate.tatechuyoko != tatechuyoko ||
        oldDelegate.autoTatechuyoko != autoTatechuyoko ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.showGrid != showGrid;
  }
}
