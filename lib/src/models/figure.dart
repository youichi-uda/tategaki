import 'package:flutter/widgets.dart';
import 'vertical_text_style.dart';

/// Alignment options for figures in vertical text
enum FigureAlignment {
  /// Inline placement within text flow
  inline,

  /// Left alignment (bottom in vertical layout)
  left,

  /// Right alignment (top in vertical layout)
  right,

  /// Center alignment
  center,
}

/// Text wrapping options for figures
enum FigureWrap {
  /// No text wrapping around figure
  none,

  /// Text wraps around the figure
  wrap,
}

/// Represents a figure (image) within vertical text layout
class Figure {
  /// The widget to display (typically an Image widget)
  final Widget child;

  /// Width of the figure (null for automatic sizing)
  final double? width;

  /// Height of the figure (null for automatic sizing)
  final double? height;

  /// How the figure should be aligned
  final FigureAlignment alignment;

  /// Whether text should wrap around the figure
  final FigureWrap wrap;

  /// Optional caption text
  final String? caption;

  /// Style for the caption text
  final VerticalTextStyle? captionStyle;

  /// Position in the text where the figure should be inserted
  final int position;

  const Figure({
    required this.child,
    required this.position,
    this.width,
    this.height,
    this.alignment = FigureAlignment.center,
    this.wrap = FigureWrap.none,
    this.caption,
    this.captionStyle,
  });
}
