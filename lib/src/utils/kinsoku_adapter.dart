import 'dart:ui';
import 'package:kinsoku/kinsoku.dart';
import '../models/vertical_text_style.dart';

/// Adapter to bridge kinsoku package with tategaki's Flutter-specific types
///
/// This adapter converts between:
/// - Position (from kinsoku) ↔ Offset (Flutter)
/// - Extracts style parameters for kinsoku functions
class KinsokuAdapter {
  /// Adjust yakumono position using kinsoku package
  ///
  /// Converts Flutter's Offset to kinsoku's Position, calls YakumonoAdjuster,
  /// and converts the result back to Offset.
  static Offset adjustYakumonoPosition(
    String character,
    Offset basePosition,
    VerticalTextStyle style,
  ) {
    if (!style.adjustYakumono) {
      return basePosition;
    }

    // Convert Offset to Position
    final kinsokuPos = Position(basePosition.dx, basePosition.dy);
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    // Call kinsoku's YakumonoAdjuster
    final adjusted = YakumonoAdjuster.adjustPosition(
      character,
      kinsokuPos,
      fontSize: fontSize,
      adjustYakumono: true,
      useVerticalGlyphs: style.useVerticalGlyphs,
    );

    // Convert Position back to Offset
    return Offset(adjusted.x, adjusted.y);
  }
}
