import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../rendering/vertical_text_painter.dart';

/// A widget that displays vertical Japanese text (tategaki)
class VerticalText extends StatelessWidget {
  /// The text to display vertically
  final String text;

  /// Style configuration for the vertical text
  final VerticalTextStyle style;

  /// Ruby (furigana) annotations
  final List<RubyText>? ruby;

  /// Maximum height for text before wrapping to next line
  /// 
  /// If 0 or not specified, text will not wrap
  final double maxHeight;

  const VerticalText(
    this.text, {
    super.key,
    this.style = const VerticalTextStyle(),
    this.ruby,
    this.maxHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VerticalTextPainter(
        text: text,
        style: style,
        ruby: ruby,
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
    // Account for ruby text if present
    double width = fontSize;
    if (ruby != null && ruby!.isNotEmpty) {
      width += fontSize; // Add space for ruby
    }

    // Handle wrapping
    if (maxHeight > 0 && height > maxHeight) {
      final linesNeeded = (height / maxHeight).ceil();
      height = maxHeight;
      width = fontSize * linesNeeded + style.lineSpacing * (linesNeeded - 1);
    }

    return Size(width, height);
  }
}
