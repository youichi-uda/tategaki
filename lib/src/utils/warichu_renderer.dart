import 'package:flutter/material.dart';
import '../models/warichu.dart';

/// Renderer for warichu (inline annotations)
class WarichuRenderer {
  /// Draw warichu at the specified position
  ///
  /// Warichu is displayed as two smaller vertical lines to the left
  /// (below in vertical text) of the main text.
  static void drawWarichu(
    Canvas canvas,
    Offset position,
    Warichu warichu,
    TextStyle baseStyle,
    double fontSize,
    double characterSpacing,
  ) {
    // Warichu uses smaller font size (typically 50% of main text)
    final warichuFontSize = fontSize * 0.5;
    final warichuStyle = baseStyle.copyWith(fontSize: warichuFontSize);

    // Calculate positions for the two lines
    // First line: align top-right with main text
    // - Main text right edge: position.dx + fontSize / 2
    // - First line center X: position.dx + fontSize / 2 - warichuFontSize / 2
    // - = position.dx + fontSize * 0.25
    // Second line: main text right edge - (grid size half + spacing)
    // - Main text right edge: position.dx + fontSize / 2
    // - Move left by: fontSize / 2 + spacing (grid size half + spacing)
    // - Second line right edge: position.dx + fontSize / 2 - fontSize / 2 - spacing
    // - = position.dx - spacing
    // - Second line center X: position.dx - spacing - warichuFontSize / 2
    // - = position.dx - spacing - fontSize / 4
    final spacing = fontSize * 0.05;
    final firstLineX = position.dx + fontSize * 0.25;
    final secondLineX = position.dx - spacing * 0.5 - fontSize * 0.25;

    // Draw first line (further from main text)
    _drawVerticalLine(
      canvas,
      Offset(firstLineX, position.dy),
      warichu.firstLine,
      warichuStyle,
      warichuFontSize,
    );

    // Draw second line (closer to main text)
    _drawVerticalLine(
      canvas,
      Offset(secondLineX, position.dy),
      warichu.secondLine,
      warichuStyle,
      warichuFontSize,
    );
  }

  /// Draw a vertical line of text
  static void _drawVerticalLine(
    Canvas canvas,
    Offset startPosition,
    String text,
    TextStyle style,
    double fontSize,
  ) {
    if (text.isEmpty) return;

    double currentY = startPosition.dy;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      final textPainter = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Center the character horizontally
      final charX = startPosition.dx - textPainter.width / 2;

      textPainter.paint(canvas, Offset(charX, currentY));

      // Move down for next character
      currentY += fontSize;
    }
  }

  /// Calculate the height needed for warichu
  static double getWarichuHeight(
    Warichu warichu,
    double fontSize,
  ) {
    final warichuFontSize = fontSize * 0.5;
    // Height is based on the longer of the two lines
    final maxLength = warichu.firstLine.length > warichu.secondLine.length
        ? warichu.firstLine.length
        : warichu.secondLine.length;
    return maxLength * warichuFontSize;
  }

  /// Calculate the width needed for warichu
  static double getWarichuWidth(double fontSize) {
    // Warichu extends to the right of the main text
    // Total width is approximately 0.6 * fontSize for both lines
    return fontSize * 0.6;
  }
}
