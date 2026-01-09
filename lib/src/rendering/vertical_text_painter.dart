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

  VerticalTextPainter({
    required this.text,
    required this.style,
    this.ruby,
    this.kenten,
    this.tatechuyoko,
    this.autoTatechuyoko = false,
    TextLayouter? layouter,
    this.maxHeight = 0,
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

    // Layout the text
    final characterLayouts = layouter.layoutText(text, style, maxHeight);

    // Draw each character (skip tatechuyoko characters)
    for (int i = 0; i < characterLayouts.length; i++) {
      if (!tatechuyokoIndices.contains(i)) {
        _drawCharacter(canvas, characterLayouts[i]);
      }
    }

    // Draw tatechuyoko
    for (final tcy in tatechuyokoRanges) {
      _drawTatechuyoko(canvas, tcy, characterLayouts);
    }

    // Draw ruby if present
    if (ruby != null && ruby!.isNotEmpty) {
      final rubyLayouts = layouter.layoutRuby(text, ruby!, style);
      for (final rubyLayout in rubyLayouts) {
        _drawRuby(canvas, rubyLayout);
      }
    }

    // Draw kenten if present
    if (kenten != null && kenten!.isNotEmpty) {
      _drawKenten(canvas, characterLayouts);
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

  void _drawKenten(Canvas canvas, List<CharacterLayout> characterLayouts) {
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final color = style.baseStyle.color ?? Colors.black;

    for (final kentenItem in kenten!) {
      for (int i = kentenItem.startIndex;
          i < kentenItem.endIndex && i < characterLayouts.length;
          i++) {
        final charLayout = characterLayouts[i];
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

    // Get position from first character in the range
    if (tcy.startIndex >= characterLayouts.length) return;
    final baseLayout = characterLayouts[tcy.startIndex];

    // Calculate tatechuyoko layout
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final tcyLayout = TatechuyokoDetector.layoutTatechuyoko(
      tcyText,
      baseLayout.position,
      fontSize,
    );

    canvas.save();

    // Move to position
    canvas.translate(tcyLayout.position.dx, tcyLayout.position.dy);

    // Draw tatechuyoko text horizontally (no rotation)
    final textPainter = TextPainter(
      text: TextSpan(
        text: tcyText,
        style: style.baseStyle.copyWith(fontSize: tcyLayout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Center horizontally in the character cell
    final offsetX = (fontSize - textPainter.width) / 2;
    textPainter.paint(canvas, Offset(offsetX, 0));

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
        oldDelegate.maxHeight != maxHeight;
  }
}
