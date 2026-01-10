import 'package:flutter/painting.dart';

/// Types of text decoration lines
enum TextDecorationLineType {
  /// Sideline (傍線) - vertical line beside the character
  /// For vertical text: drawn to the right of the character
  sideline,

  /// Double sideline (二重傍線)
  doubleSideline,

  /// Wavy sideline (波線)
  wavySideline,

  /// Dotted sideline (点線)
  dottedSideline,
}

/// Text decoration (傍線など) annotation for vertical text
///
/// Unlike kenten (emphasis dots), decorations are lines drawn beside characters
class TextDecorationAnnotation {
  /// Starting index of the text to decorate
  final int startIndex;

  /// Length of the text to decorate
  final int length;

  /// Type of decoration line
  final TextDecorationLineType type;

  /// Color of the decoration line (null = use text color)
  final Color? color;

  /// Thickness of the decoration line (null = auto based on font size)
  final double? thickness;

  const TextDecorationAnnotation({
    required this.startIndex,
    required this.length,
    this.type = TextDecorationLineType.sideline,
    this.color,
    this.thickness,
  });

  /// End index of the decorated text (exclusive)
  int get endIndex => startIndex + length;

  @override
  String toString() {
    return 'TextDecorationAnnotation(startIndex: $startIndex, length: $length, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextDecorationAnnotation &&
        other.startIndex == startIndex &&
        other.length == length &&
        other.type == type &&
        other.color == color &&
        other.thickness == thickness;
  }

  @override
  int get hashCode => Object.hash(startIndex, length, type, color, thickness);
}
