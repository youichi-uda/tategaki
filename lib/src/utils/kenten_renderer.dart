import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/kenten.dart';

/// Renderer for kenten (emphasis dots)
class KentenRenderer {
  /// Draw kenten at the specified position
  static void drawKenten(
    Canvas canvas,
    Offset position,
    KentenStyle style,
    double size,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    switch (style) {
      case KentenStyle.sesame:
        _drawSesame(canvas, position, size, paint);
        break;
      case KentenStyle.filledCircle:
        _drawFilledCircle(canvas, position, size, paint);
        break;
      case KentenStyle.circle:
        _drawCircle(canvas, position, size, strokePaint);
        break;
      case KentenStyle.filledTriangle:
        _drawFilledTriangle(canvas, position, size, paint);
        break;
      case KentenStyle.triangle:
        _drawTriangle(canvas, position, size, strokePaint);
        break;
    }
  }

  static void _drawSesame(Canvas canvas, Offset position, double size, Paint paint) {
    // Draw small filled circle (sesame dot)
    canvas.drawCircle(position, size * 0.15, paint);
  }

  static void _drawFilledCircle(Canvas canvas, Offset position, double size, Paint paint) {
    // Draw medium filled circle
    canvas.drawCircle(position, size * 0.2, paint);
  }

  static void _drawCircle(Canvas canvas, Offset position, double size, Paint paint) {
    // Draw hollow circle
    canvas.drawCircle(position, size * 0.2, paint);
  }

  static void _drawFilledTriangle(Canvas canvas, Offset position, double size, Paint paint) {
    final path = Path();
    final triangleSize = size * 0.3;
    
    path.moveTo(position.dx, position.dy - triangleSize / 2);
    path.lineTo(position.dx - triangleSize / 2, position.dy + triangleSize / 2);
    path.lineTo(position.dx + triangleSize / 2, position.dy + triangleSize / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  static void _drawTriangle(Canvas canvas, Offset position, double size, Paint paint) {
    final path = Path();
    final triangleSize = size * 0.3;
    
    path.moveTo(position.dx, position.dy - triangleSize / 2);
    path.lineTo(position.dx - triangleSize / 2, position.dy + triangleSize / 2);
    path.lineTo(position.dx + triangleSize / 2, position.dy + triangleSize / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Calculate position for kenten relative to character
  static Offset getKentenPosition(
    Offset characterPosition,
    double fontSize,
    bool isVertical,
  ) {
    if (isVertical) {
      // Place to the right of character in vertical text
      // Position: More right, at about half the font height down
      // X: characterPosition.dx + offset (right side of character)
      // Y: characterPosition.dy + fontSize * 0.5 (half the font height down)
      return Offset(
        characterPosition.dx + fontSize * 0.75,  // More to the right
        characterPosition.dy + fontSize * 0.5,   // Half font height down
      );
    } else {
      // Place above character in horizontal text
      return Offset(
        characterPosition.dx + fontSize * 0.5,
        characterPosition.dy - fontSize * 0.3,
      );
    }
  }
}
