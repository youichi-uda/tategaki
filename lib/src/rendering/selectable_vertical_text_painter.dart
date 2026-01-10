import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/tatechuyoko.dart';
import 'text_layouter.dart';

/// Custom painter for selectable vertical Japanese text
class SelectableVerticalTextPainter extends CustomPainter {
  final String text;
  final VerticalTextStyle style;
  final double maxHeight;
  final bool showGrid;
  final List<RubyText> rubyList;
  final List<Kenten> kentenList;
  final List<Tatechuyoko> tatechuyokoList;
  final int? selectionStart;
  final int? selectionEnd;
  final Color selectionColor;
  final Color handleColor;
  final bool showHandles;
  final void Function(List<CharacterLayout>)? onLayoutsCalculated;

  SelectableVerticalTextPainter({
    required this.text,
    required this.style,
    this.maxHeight = 0,
    this.showGrid = false,
    this.rubyList = const [],
    this.kentenList = const [],
    this.tatechuyokoList = const [],
    this.selectionStart,
    this.selectionEnd,
    this.selectionColor = const Color(0x6633B5E5),
    this.handleColor = const Color(0xFF2196F3),
    this.showHandles = true,
    this.onLayoutsCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    // Layout the text
    final layouter = TextLayouter();
    final layouts = layouter.layoutText(
      text,
      style,
      maxHeight,
    );

    // Notify parent of layouts for hit testing
    onLayoutsCalculated?.call(layouts);

    final fontSize = style.baseStyle.fontSize ?? 16.0;

    // Draw selection background
    if (selectionStart != null && selectionEnd != null) {
      _drawSelection(canvas, layouts, fontSize);
    }

    // Draw each character
    for (final layout in layouts) {
      _drawCharacter(canvas, layout);
    }

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, layouts, size);
    }

    // Draw selection handles
    if (showHandles && selectionStart != null && selectionEnd != null) {
      _drawSelectionHandles(canvas, layouts, fontSize);
    }
  }

  void _drawSelectionHandles(Canvas canvas, List<CharacterLayout> layouts, double fontSize) {
    final start = selectionStart! < selectionEnd! ? selectionStart! : selectionEnd!;
    final end = selectionStart! < selectionEnd! ? selectionEnd! : selectionStart!;

    if (end - start == 0) return;

    // Find start and end character layouts
    CharacterLayout? startLayout;
    CharacterLayout? endLayout;

    for (final layout in layouts) {
      if (layout.textIndex == start) {
        startLayout = layout;
      }
      if (layout.textIndex == end - 1) {
        endLayout = layout;
      }
    }

    const handleRadius = 6.0;

    // Draw start handle (top of selection in vertical text)
    if (startLayout != null) {
      _drawHandle(
        canvas,
        Offset(startLayout.position.dx, startLayout.position.dy),
        fontSize,
        handleRadius,
        isStart: true,
      );
    }

    // Draw end handle (bottom of selection in vertical text)
    if (endLayout != null) {
      _drawHandle(
        canvas,
        Offset(endLayout.position.dx, endLayout.position.dy + fontSize),
        fontSize,
        handleRadius,
        isStart: false,
      );
    }
  }

  void _drawHandle(
    Canvas canvas,
    Offset position,
    double fontSize,
    double radius,
    {required bool isStart}
  ) {
    final paint = Paint()
      ..color = handleColor
      ..style = PaintingStyle.fill;

    // Draw horizontal line (for vertical text, handles extend to the left)
    final lineStart = Offset(position.dx - fontSize / 2, position.dy);
    final lineEnd = Offset(position.dx + fontSize / 2, position.dy);
    canvas.drawLine(
      lineStart,
      lineEnd,
      Paint()
        ..color = handleColor
        ..strokeWidth = 2.0,
    );

    // Draw circle handle at left edge
    final handleCenter = Offset(
      position.dx - fontSize / 2 - radius,
      position.dy,
    );
    canvas.drawCircle(handleCenter, radius, paint);

    // Draw white border
    canvas.drawCircle(
      handleCenter,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawSelection(Canvas canvas, List<CharacterLayout> layouts, double fontSize) {
    final start = selectionStart! < selectionEnd! ? selectionStart! : selectionEnd!;
    final end = selectionStart! < selectionEnd! ? selectionEnd! : selectionStart!;

    final paint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.fill;

    for (final layout in layouts) {
      final index = layout.textIndex;
      if (index >= start && index < end) {
        final rect = Rect.fromLTWH(
          layout.position.dx - fontSize / 2,
          layout.position.dy,
          fontSize,
          fontSize,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  // Reusable TextPainter instance to avoid repeated allocations
  static final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  void _drawCharacter(Canvas canvas, CharacterLayout layout) {
    canvas.save();

    // Move to character position
    canvas.translate(layout.position.dx, layout.position.dy);

    // Reuse text painter
    _textPainter.text = TextSpan(
      text: layout.character,
      style: style.baseStyle.copyWith(fontSize: layout.fontSize),
    );

    _textPainter.layout();

    // Calculate offset based on rotation
    double offsetX, offsetY;

    // Get the virtual cell size (fontSize)
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    if (layout.rotation != 0.0) {
      // For rotated characters (90 degrees clockwise)
      // Rotate first
      canvas.rotate(layout.rotation);

      // In the rotated coordinate system, apply positioning within virtual cell:
      offsetX = 0;
      // Vertical positioning - use text height / 2 to center at position.dx
      offsetY = -_textPainter.height / 2;
    } else {
      // For non-rotated characters
      // Center horizontally (X axis) within the virtual cell
      offsetX = -(_textPainter.width / 2);
      // Center vertically (Y axis) within the virtual cell (fontSize)
      offsetY = (fontSize - _textPainter.height) / 2;
    }

    // Draw the character
    _textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, List<CharacterLayout> characterLayouts, Size size) {
    final baseFontSize = style.baseStyle.fontSize ?? 16.0;

    final characterPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final layout in characterLayouts) {
      final rect = Rect.fromCenter(
        center: Offset(layout.position.dx, layout.position.dy + baseFontSize / 2),
        width: baseFontSize,
        height: baseFontSize,
      );
      canvas.drawRect(rect, characterPaint);
    }
  }

  @override
  bool shouldRepaint(SelectableVerticalTextPainter oldDelegate) {
    return text != oldDelegate.text ||
        style != oldDelegate.style ||
        maxHeight != oldDelegate.maxHeight ||
        showGrid != oldDelegate.showGrid ||
        rubyList != oldDelegate.rubyList ||
        kentenList != oldDelegate.kentenList ||
        tatechuyokoList != oldDelegate.tatechuyokoList ||
        selectionStart != oldDelegate.selectionStart ||
        selectionEnd != oldDelegate.selectionEnd ||
        selectionColor != oldDelegate.selectionColor ||
        handleColor != oldDelegate.handleColor ||
        showHandles != oldDelegate.showHandles;
  }
}
