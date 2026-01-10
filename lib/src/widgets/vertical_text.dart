import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/tatechuyoko.dart';
import '../models/warichu.dart';
import '../models/vertical_text_span.dart';
import '../rendering/vertical_text_painter.dart';

/// A widget that displays vertical Japanese text (tategaki)
class VerticalText extends StatelessWidget {
  /// The text to display vertically
  final String? text;

  /// Span-based text composition (alternative to plain text)
  final VerticalTextSpan? span;

  /// Style configuration for the vertical text
  final VerticalTextStyle style;

  /// Ruby (furigana) annotations (used with plain text)
  final List<RubyText>? ruby;

  /// Kenten (emphasis dots) annotations (used with plain text)
  final List<Kenten>? kenten;

  /// Warichu (inline annotations) annotations (used with plain text)
  final List<Warichu>? warichu;

  /// Tatechuyoko (horizontal text within vertical) annotations (used with plain text)
  final List<Tatechuyoko>? tatechuyoko;

  /// Auto-detect and apply tatechuyoko to 2-digit numbers
  final bool autoTatechuyoko;

  /// Maximum height for text before wrapping to next line
  ///
  /// If 0 or not specified, text will not wrap
  final double maxHeight;

  /// Show grid overlay for debugging character positions
  final bool showGrid;

  const VerticalText(
    this.text, {
    super.key,
    this.style = const VerticalTextStyle(),
    this.ruby,
    this.kenten,
    this.warichu,
    this.tatechuyoko,
    this.autoTatechuyoko = false,
    this.maxHeight = 0,
    this.showGrid = false,
  })  : span = null,
        assert(text != null, 'text must not be null');

  /// Creates a vertical text widget with rich text composition
  ///
  /// This constructor uses a span-based API similar to Flutter's Text.rich()
  /// which makes it easier to compose text with different styles and annotations.
  ///
  /// Example:
  /// ```dart
  /// VerticalText.rich(
  ///   TextSpanV(
  ///     children: [
  ///       RubySpan(text: '東京', ruby: 'とうきょう'),
  ///       TextSpanV(text: 'と'),
  ///       RubySpan(text: '大阪', ruby: 'おおさか'),
  ///       TextSpanV(text: 'は日本の大都市である。'),
  ///     ],
  ///   ),
  /// )
  /// ```
  const VerticalText.rich(
    this.span, {
    super.key,
    this.style = const VerticalTextStyle(),
    this.autoTatechuyoko = false,
    this.maxHeight = 0,
    this.showGrid = false,
  })  : text = null,
        ruby = null,
        kenten = null,
        warichu = null,
        tatechuyoko = null,
        assert(span != null, 'span must not be null');

  @override
  Widget build(BuildContext context) {
    // Get default text color from theme if not specified
    final defaultColor = style.baseStyle.color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        const Color(0xFF000000);

    // Merge default color with user style
    final effectiveStyle = style.copyWith(
      baseStyle: style.baseStyle.copyWith(color: defaultColor),
    );

    return CustomPaint(
      painter: VerticalTextPainter(
        text: text,
        span: span,
        style: effectiveStyle,
        ruby: ruby,
        kenten: kenten,
        warichu: warichu,
        tatechuyoko: tatechuyoko,
        autoTatechuyoko: autoTatechuyoko,
        maxHeight: maxHeight,
        showGrid: showGrid,
      ),
      size: _calculateSize(effectiveStyle),
    );
  }

  Size _calculateSize(VerticalTextStyle effectiveStyle) {
    final fontSize = effectiveStyle.baseStyle.fontSize ?? 16.0;
    final numChars = span != null ? span!.textLength : text!.length;

    // Calculate height (vertical extent in vertical text)
    double height = numChars * (fontSize + effectiveStyle.characterSpacing);

    // Calculate width (horizontal extent in vertical text)
    // Base width is one character width
    double width = fontSize;

    // Add space for ruby text if present
    if (ruby != null && ruby!.isNotEmpty) {
      final rubyFontSize = effectiveStyle.rubyStyle?.fontSize ?? (fontSize * 0.5);
      width += rubyFontSize + fontSize * 0.2; // Ruby size + margin
    }

    // Add space for kenten if present
    if (kenten != null && kenten!.isNotEmpty) {
      width += fontSize * 0.5; // Extra space for kenten on the right
    }

    // Add space for warichu if present
    if (warichu != null && warichu!.isNotEmpty) {
      // Warichu doesn't extend beyond main text width
      // No extra space needed
    }

    // Handle wrapping
    if (maxHeight > 0 && height > maxHeight) {
      final linesNeeded = (height / maxHeight).ceil();
      height = maxHeight;

      // Width for multiple lines
      double lineWidth = fontSize;
      if (ruby != null && ruby!.isNotEmpty) {
        final rubyFontSize = effectiveStyle.rubyStyle?.fontSize ?? (fontSize * 0.5);
        lineWidth += rubyFontSize + fontSize * 0.2;
      }
      if (kenten != null && kenten!.isNotEmpty) {
        lineWidth += fontSize * 0.5;
      }
      // Warichu doesn't extend beyond main text width

      width = lineWidth * linesNeeded + effectiveStyle.lineSpacing * (linesNeeded - 1);
    }

    return Size(width, height);
  }
}
