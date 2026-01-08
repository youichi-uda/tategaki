import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import 'text_layouter.dart';

/// Custom painter for vertical text
class VerticalTextPainter extends CustomPainter {
  final String text;
  final VerticalTextStyle style;
  final List<RubyText>? ruby;
  final TextLayouter layouter;
  final double maxHeight;

  VerticalTextPainter({
    required this.text,
    required this.style,
    this.ruby,
    TextLayouter? layouter,
    this.maxHeight = 0,
  }) : layouter = layouter ?? TextLayouter();

  @override
  void paint(Canvas canvas, Size size) {
    // Layout the text
    final characterLayouts = layouter.layoutText(text, style, maxHeight);

    // Draw each character
    for (final layout in characterLayouts) {
      _drawCharacter(canvas, layout);
    }

    // Draw ruby if present
    if (ruby != null && ruby!.isNotEmpty) {
      final rubyLayouts = layouter.layoutRuby(text, ruby!, style);
      for (final rubyLayout in rubyLayouts) {
        _drawRuby(canvas, rubyLayout);
      }
    }
  }

  void _drawCharacter(Canvas canvas, CharacterLayout layout) {
    canvas.save();

    // Move to character position
    canvas.translate(layout.position.dx, layout.position.dy);

    // Rotate if needed
    if (layout.rotation != 0.0) {
      canvas.rotate(layout.rotation);
    }

    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(
        text: layout.character,
        style: style.baseStyle.copyWith(fontSize: layout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Draw the character
    textPainter.paint(canvas, const Offset(0, 0));

    canvas.restore();
  }

  void _drawRuby(Canvas canvas, RubyLayout layout) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: layout.ruby,
        style: (style.rubyStyle ?? style.baseStyle).copyWith(
          fontSize: layout.fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    );

    textPainter.layout();

    // Draw ruby text
    textPainter.paint(canvas, layout.position);
  }

  @override
  bool shouldRepaint(covariant VerticalTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.ruby != ruby ||
        oldDelegate.maxHeight != maxHeight;
  }
}
