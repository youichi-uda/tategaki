import 'dart:ui';
import '../models/figure.dart';
import '../models/vertical_text_style.dart';
import '../rendering/text_layouter.dart';

/// Layout information for a figure
class FigureLayout {
  /// Position where the figure should be drawn
  final Offset position;

  /// Size of the figure
  final Size size;

  /// Bounding rectangle of the figure
  final Rect bounds;

  /// Layout information for caption if present
  final CaptionLayout? caption;

  const FigureLayout({
    required this.position,
    required this.size,
    required this.bounds,
    this.caption,
  });
}

/// Layout information for figure caption
class CaptionLayout {
  /// Character layouts for the caption text
  final List<CharacterLayout> characters;

  /// Size of the caption area
  final Size size;

  const CaptionLayout({
    required this.characters,
    required this.size,
  });
}

/// Handles layout calculations for figures in vertical text
class FigureLayouter {
  /// Calculate layout for a figure
  static FigureLayout layoutFigure(
    Figure figure,
    double availableWidth,
    double availableHeight,
  ) {
    // Determine figure size
    final figureWidth = figure.width ?? availableWidth * 0.8;
    final figureHeight = figure.height ?? availableHeight * 0.3;
    final size = Size(figureWidth, figureHeight);

    // Calculate position based on alignment
    Offset position;
    switch (figure.alignment) {
      case FigureAlignment.inline:
      case FigureAlignment.center:
        position = Offset((availableWidth - figureWidth) / 2, 0);
        break;
      case FigureAlignment.left:
        // Left in vertical layout means bottom
        position = Offset(availableWidth - figureWidth, 0);
        break;
      case FigureAlignment.right:
        // Right in vertical layout means top
        position = const Offset(0, 0);
        break;
    }

    final bounds = Rect.fromLTWH(
      position.dx,
      position.dy,
      figureWidth,
      figureHeight,
    );

    // Layout caption if present
    CaptionLayout? captionLayout;
    if (figure.caption != null && figure.caption!.isNotEmpty) {
      captionLayout = layoutCaption(
        figure.caption!,
        figure.captionStyle ?? const VerticalTextStyle(),
        figureWidth,
      );
    }

    return FigureLayout(
      position: position,
      size: size,
      bounds: bounds,
      caption: captionLayout,
    );
  }

  /// Calculate wrap areas for text around a figure
  static List<Rect> calculateWrapAreas(
    Figure figure,
    FigureLayout layout,
    double lineHeight,
  ) {
    if (figure.wrap == FigureWrap.none) {
      return [];
    }

    final wrapAreas = <Rect>[];

    // Calculate areas where text should not be placed
    // In vertical text, wrapping occurs above and below the figure
    switch (figure.alignment) {
      case FigureAlignment.inline:
      case FigureAlignment.center:
        // Text wraps on both sides
        wrapAreas.add(Rect.fromLTWH(
          layout.bounds.left - lineHeight,
          layout.bounds.top,
          lineHeight,
          layout.bounds.height,
        ));
        wrapAreas.add(Rect.fromLTWH(
          layout.bounds.right,
          layout.bounds.top,
          lineHeight,
          layout.bounds.height,
        ));
        break;
      case FigureAlignment.left:
        // Text wraps on the right side
        wrapAreas.add(Rect.fromLTWH(
          layout.bounds.left - lineHeight,
          layout.bounds.top,
          lineHeight,
          layout.bounds.height,
        ));
        break;
      case FigureAlignment.right:
        // Text wraps on the left side
        wrapAreas.add(Rect.fromLTWH(
          layout.bounds.right,
          layout.bounds.top,
          lineHeight,
          layout.bounds.height,
        ));
        break;
    }

    return wrapAreas;
  }

  /// Layout caption text for a figure
  static CaptionLayout layoutCaption(
    String caption,
    VerticalTextStyle style,
    double maxWidth,
  ) {
    // Use TextLayouter to layout caption vertically
    final layouter = TextLayouter();
    final characters = layouter.layoutText(
      caption,
      style,
      0, // No height limit for caption
    );

    // Calculate caption size
    double width = 0;
    double height = 0;
    for (final char in characters) {
      width = (char.position.dx + char.fontSize).clamp(width, double.infinity);
      height = (char.position.dy + char.fontSize).clamp(height, double.infinity);
    }

    return CaptionLayout(
      characters: characters,
      size: Size(width, height),
    );
  }
}
