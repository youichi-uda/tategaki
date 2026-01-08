/// Styles for kenten (emphasis dots)
enum KentenStyle {
  /// Sesame dots (ゴマ点)
  sesame,

  /// Filled circle (黒丸)
  filledCircle,

  /// Hollow circle (白丸)
  circle,

  /// Filled triangle (黒三角)
  filledTriangle,

  /// Hollow triangle (白三角)
  triangle,
}

/// Kenten (emphasis dots) annotation for vertical text
/// 
/// Kenten are emphasis marks placed to the right of characters in vertical text
class Kenten {
  /// Starting index of the text to emphasize
  final int startIndex;

  /// Length of the text to emphasize
  final int length;

  /// Style of kenten to use
  final KentenStyle style;

  const Kenten({
    required this.startIndex,
    required this.length,
    required this.style,
  });

  /// End index of the emphasized text (exclusive)
  int get endIndex => startIndex + length;

  @override
  String toString() {
    return 'Kenten(startIndex: $startIndex, length: $length, style: $style)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Kenten &&
        other.startIndex == startIndex &&
        other.length == length &&
        other.style == style;
  }

  @override
  int get hashCode => Object.hash(startIndex, length, style);
}
