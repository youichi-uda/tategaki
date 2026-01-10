import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/text_decoration.dart';

/// Renderer for text decorations (sidelines, etc.)
class DecorationRenderer {
  /// Draw decoration at the specified position range
  ///
  /// [canvas] Canvas to draw on
  /// [startPosition] Top position of the decoration
  /// [endPosition] Bottom position of the decoration (Y coordinate)
  /// [type] Type of decoration line
  /// [fontSize] Font size for calculating line thickness and position
  /// [color] Color of the decoration line
  /// [thickness] Custom thickness (null = auto)
  static void drawDecoration(
    Canvas canvas,
    Offset startPosition,
    double endY,
    TextDecorationLineType type,
    double fontSize,
    Color color, {
    double? thickness,
  }) {
    final lineThickness = thickness ?? (fontSize * 0.05).clamp(1.0, 3.0);
    final xOffset = fontSize * 0.65; // Position to the right of character

    final paint = Paint()
      ..color = color
      ..strokeWidth = lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final x = startPosition.dx + xOffset;
    final startY = startPosition.dy;

    switch (type) {
      case TextDecorationLineType.sideline:
        // Simple straight line
        canvas.drawLine(
          Offset(x, startY),
          Offset(x, endY),
          paint,
        );
        break;

      case TextDecorationLineType.doubleSideline:
        // Double line
        final gap = lineThickness * 2;
        canvas.drawLine(
          Offset(x, startY),
          Offset(x, endY),
          paint,
        );
        canvas.drawLine(
          Offset(x + gap, startY),
          Offset(x + gap, endY),
          paint,
        );
        break;

      case TextDecorationLineType.wavySideline:
        // Wavy line
        _drawWavyLine(canvas, x, startY, endY, paint, fontSize);
        break;

      case TextDecorationLineType.dottedSideline:
        // Dotted line
        _drawDottedLine(canvas, x, startY, endY, paint, fontSize);
        break;
    }
  }

  /// Draw a wavy line
  static void _drawWavyLine(
    Canvas canvas,
    double x,
    double startY,
    double endY,
    Paint paint,
    double fontSize,
  ) {
    final path = Path();
    final waveHeight = fontSize * 0.1;
    final waveLength = fontSize * 0.3;

    path.moveTo(x, startY);

    double y = startY;
    bool goRight = true;

    while (y < endY) {
      final nextY = (y + waveLength).clamp(y, endY);
      final controlY = y + (nextY - y) / 2;
      final controlX = goRight ? x + waveHeight : x - waveHeight;

      path.quadraticBezierTo(controlX, controlY, x, nextY);

      y = nextY;
      goRight = !goRight;
    }

    canvas.drawPath(path, paint);
  }

  /// Draw a dotted line
  static void _drawDottedLine(
    Canvas canvas,
    double x,
    double startY,
    double endY,
    Paint paint,
    double fontSize,
  ) {
    final dotRadius = paint.strokeWidth;
    final dotSpacing = fontSize * 0.2;

    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    double y = startY + dotRadius;
    while (y < endY) {
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      y += dotSpacing;
    }
  }

  /// Calculate position for decoration relative to character
  static Offset getDecorationPosition(
    Offset characterPosition,
    double fontSize,
  ) {
    // Place to the right of character in vertical text
    return Offset(
      characterPosition.dx + fontSize * 0.65,
      characterPosition.dy,
    );
  }
}
