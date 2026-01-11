import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Layout information for a resolved gaiji
class GaijiLayout {
  /// Position to draw the gaiji
  final Offset position;

  /// Width of the gaiji image
  final double width;

  /// Height of the gaiji image
  final double height;

  /// The resolved image to draw
  final ui.Image image;

  /// Text index this gaiji replaces
  final int textIndex;

  const GaijiLayout({
    required this.position,
    required this.width,
    required this.height,
    required this.image,
    required this.textIndex,
  });
}

/// Renderer for gaiji (外字) images
class GaijiRenderer {
  /// Draw a gaiji image at the specified position
  ///
  /// For vertical text, the image is drawn within the character cell,
  /// centered both horizontally and vertically.
  /// The fontSize parameter is the character cell height, used to find the cell center.
  static void drawGaiji(
    Canvas canvas,
    GaijiLayout layout,
    double fontSize,
  ) {
    // Source rectangle (entire image)
    final srcRect = Rect.fromLTWH(
      0,
      0,
      layout.image.width.toDouble(),
      layout.image.height.toDouble(),
    );

    // Destination rectangle (centered in character cell)
    // For vertical text: position.dx is the center X, position.dy is the top Y
    // Center the gaiji at the middle of the character cell (fontSize height)
    final dstRect = Rect.fromCenter(
      center: Offset(
        layout.position.dx,
        layout.position.dy + fontSize / 2,  // Center of the character cell
      ),
      width: layout.width,
      height: layout.height,
    );

    // Draw the image
    canvas.drawImageRect(
      layout.image,
      srcRect,
      dstRect,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  /// Draw multiple gaiji images
  static void drawGaijiList(
    Canvas canvas,
    List<GaijiLayout> layouts,
    double fontSize,
  ) {
    for (final layout in layouts) {
      drawGaiji(canvas, layout, fontSize);
    }
  }
}
