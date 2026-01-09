import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/tatechuyoko.dart';
import '../rendering/vertical_text_painter.dart';

/// A widget that displays vertical Japanese text (tategaki)
class VerticalText extends StatelessWidget {
  /// The text to display vertically
  final String text;

  /// Style configuration for the vertical text
  final VerticalTextStyle style;

  /// Ruby (furigana) annotations
  final List<RubyText>? ruby;

  /// Kenten (emphasis dots) annotations
  final List<Kenten>? kenten;

  /// Tatechuyoko (horizontal text within vertical) annotations
  final List<Tatechuyoko>? tatechuyoko;

  /// Auto-detect and apply tatechuyoko to 2-digit numbers
  final bool autoTatechuyoko;

  /// Maximum height for text before wrapping to next line
  ///
  /// If 0 or not specified, text will not wrap
  final double maxHeight;

  const VerticalText(
    this.text, {
    super.key,
    this.style = const VerticalTextStyle(),
    this.ruby,
    this.kenten,
    this.tatechuyoko,
    this.autoTatechuyoko = false,
    this.maxHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VerticalTextPainter(
        text: text,
        style: style,
        ruby: ruby,
        kenten: kenten,
        tatechuyoko: tatechuyoko,
        autoTatechuyoko: autoTatechuyoko,
        maxHeight: maxHeight,
      ),
      size: _calculateSize(),
    );
  }

  Size _calculateSize() {
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final numChars = text.length;

    // Calculate height (vertical extent in vertical text)
    double height = numChars * (fontSize + style.characterSpacing);

    // Calculate width (horizontal extent in vertical text)
    // Base width is one character width
    double width = fontSize;

    // Add space for ruby text if present
    if (ruby != null && ruby!.isNotEmpty) {
      final rubyFontSize = style.rubyStyle?.fontSize ?? (fontSize * 0.5);
      width += rubyFontSize + fontSize * 0.2; // Ruby size + margin
    }

    // Add space for kenten if present
    if (kenten != null && kenten!.isNotEmpty) {
      width += fontSize * 0.5; // Extra space for kenten on the right
    }

    // Handle wrapping
    if (maxHeight > 0 && height > maxHeight) {
      final linesNeeded = (height / maxHeight).ceil();
      height = maxHeight;

      // Width for multiple lines
      double lineWidth = fontSize;
      if (ruby != null && ruby!.isNotEmpty) {
        final rubyFontSize = style.rubyStyle?.fontSize ?? (fontSize * 0.5);
        lineWidth += rubyFontSize + fontSize * 0.2;
      }
      if (kenten != null && kenten!.isNotEmpty) {
        lineWidth += fontSize * 0.5;
      }

      width = lineWidth * linesNeeded + style.lineSpacing * (linesNeeded - 1);
    }

    return Size(width, height);
  }
}
