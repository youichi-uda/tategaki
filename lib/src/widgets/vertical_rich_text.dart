import 'package:flutter/material.dart';
import '../models/vertical_text_span.dart';
import '../models/vertical_text_style.dart';
import '../rendering/vertical_rich_text_painter.dart';

/// A widget that displays vertical rich text with multiple styles
///
/// Similar to RichText but for vertical Japanese text layout.
/// Uses VerticalTextSpan to define styled text segments.
class VerticalRichText extends StatelessWidget {
  /// The root text span defining the content and styles
  final VerticalTextSpan textSpan;

  /// Maximum height for text before wrapping to next line
  ///
  /// If 0 or not specified, text will not wrap
  final double maxHeight;

  const VerticalRichText({
    super.key,
    required this.textSpan,
    this.maxHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VerticalRichTextPainter(
        textSpan: textSpan,
        maxHeight: maxHeight,
      ),
      size: _calculateSize(),
    );
  }

  Size _calculateSize() {
    // Flatten the span to get all styled characters
    final characters = textSpan.flatten();
    if (characters.isEmpty) {
      return Size.zero;
    }

    // Use the first character's style as base for size calculation
    final baseStyle = characters.first.style;
    final fontSize = baseStyle.baseStyle.fontSize ?? 16.0;
    final numChars = characters.length;

    // Calculate height (vertical extent in vertical text)
    double height = numChars * (fontSize + baseStyle.characterSpacing);

    // Calculate width (horizontal extent in vertical text)
    double width = fontSize;

    // Handle wrapping
    if (maxHeight > 0 && height > maxHeight) {
      final linesNeeded = (height / maxHeight).ceil();
      height = maxHeight;
      width = fontSize * linesNeeded + baseStyle.lineSpacing * (linesNeeded - 1);
    }

    return Size(width, height);
  }
}
