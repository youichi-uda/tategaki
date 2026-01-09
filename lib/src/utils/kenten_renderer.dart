import 'dart:math' as math;
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
      case KentenStyle.doubleCircle:
        _drawDoubleCircle(canvas, position, size, strokePaint);
        break;
      case KentenStyle.filledTriangle:
        _drawFilledTriangle(canvas, position, size, paint);
        break;
      case KentenStyle.triangle:
        _drawTriangle(canvas, position, size, strokePaint);
        break;
      case KentenStyle.x:
        _drawX(canvas, position, size, strokePaint);
        break;
      case KentenStyle.filledDiamond:
        _drawFilledDiamond(canvas, position, size, paint);
        break;
      case KentenStyle.diamond:
        _drawDiamond(canvas, position, size, strokePaint);
        break;
      case KentenStyle.filledSquare:
        _drawFilledSquare(canvas, position, size, paint);
        break;
      case KentenStyle.square:
        _drawSquare(canvas, position, size, strokePaint);
        break;
      case KentenStyle.filledStar:
        _drawFilledStar(canvas, position, size, paint);
        break;
      case KentenStyle.star:
        _drawStar(canvas, position, size, strokePaint);
        break;
      case KentenStyle.sideline:
        _drawSideline(canvas, position, size, strokePaint);
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

  static void _drawDoubleCircle(Canvas canvas, Offset position, double size, Paint paint) {
    // Draw outer circle
    canvas.drawCircle(position, size * 0.22, paint);
    // Draw inner circle
    canvas.drawCircle(position, size * 0.12, paint);
  }

  static void _drawX(Canvas canvas, Offset position, double size, Paint paint) {
    final xSize = size * 0.25;
    // Draw X mark (two diagonal lines)
    canvas.drawLine(
      Offset(position.dx - xSize, position.dy - xSize),
      Offset(position.dx + xSize, position.dy + xSize),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx - xSize, position.dy + xSize),
      Offset(position.dx + xSize, position.dy - xSize),
      paint,
    );
  }

  static void _drawFilledDiamond(Canvas canvas, Offset position, double size, Paint paint) {
    final path = Path();
    final diamondSize = size * 0.25;

    path.moveTo(position.dx, position.dy - diamondSize);
    path.lineTo(position.dx + diamondSize, position.dy);
    path.lineTo(position.dx, position.dy + diamondSize);
    path.lineTo(position.dx - diamondSize, position.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  static void _drawDiamond(Canvas canvas, Offset position, double size, Paint paint) {
    final path = Path();
    final diamondSize = size * 0.25;

    path.moveTo(position.dx, position.dy - diamondSize);
    path.lineTo(position.dx + diamondSize, position.dy);
    path.lineTo(position.dx, position.dy + diamondSize);
    path.lineTo(position.dx - diamondSize, position.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  static void _drawFilledSquare(Canvas canvas, Offset position, double size, Paint paint) {
    final squareSize = size * 0.2;
    final rect = Rect.fromCenter(
      center: position,
      width: squareSize * 2,
      height: squareSize * 2,
    );
    canvas.drawRect(rect, paint);
  }

  static void _drawSquare(Canvas canvas, Offset position, double size, Paint paint) {
    final squareSize = size * 0.2;
    final rect = Rect.fromCenter(
      center: position,
      width: squareSize * 2,
      height: squareSize * 2,
    );
    canvas.drawRect(rect, paint);
  }

  static void _drawFilledStar(Canvas canvas, Offset position, double size, Paint paint) {
    final path = _createStarPath(position, size * 0.25);
    canvas.drawPath(path, paint);
  }

  static void _drawStar(Canvas canvas, Offset position, double size, Paint paint) {
    final path = _createStarPath(position, size * 0.25);
    canvas.drawPath(path, paint);
  }

  static Path _createStarPath(Offset position, double radius) {
    final path = Path();
    const numPoints = 5;
    final angle = -math.pi / 2; // Start from top

    for (int i = 0; i < numPoints * 2; i++) {
      final currentAngle = angle + (math.pi * i / numPoints);
      final currentRadius = (i % 2 == 0) ? radius : radius * 0.4;
      final x = position.dx + currentRadius * math.cos(currentAngle);
      final y = position.dy + currentRadius * math.sin(currentAngle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  static void _drawSideline(Canvas canvas, Offset position, double size, Paint paint) {
    final lineLength = size * 0.8;
    // Draw vertical line to the right of character
    canvas.drawLine(
      Offset(position.dx, position.dy - lineLength / 2),
      Offset(position.dx, position.dy + lineLength / 2),
      paint..strokeWidth = 1.5,
    );
  }

  /// Calculate position for kenten relative to character
  static Offset getKentenPosition(
    Offset characterPosition,
    double fontSize,
    bool isVertical,
  ) {
    if (isVertical) {
      // Place to the right of character in vertical text
      // Position: More right, at the vertical center of the virtual cell
      // X: characterPosition.dx + offset (right side of character)
      // Y: characterPosition.dy + fontSize / 2 (center of virtual cell)
      //
      // The kenten is positioned at the center of the fontSize-based virtual cell,
      // not the actual text height
      return Offset(
        characterPosition.dx + fontSize * 0.75,  // More to the right
        characterPosition.dy + fontSize / 2,     // Center of virtual cell
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
