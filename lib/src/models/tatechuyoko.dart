/// Tatechuyoko (horizontal text within vertical layout)
/// 
/// Used for displaying numbers, dates, and other horizontal text
/// within vertical text layout
class Tatechuyoko {
  /// Starting index of the text to display horizontally
  final int startIndex;

  /// Length of the text to display horizontally
  final int length;

  const Tatechuyoko({
    required this.startIndex,
    required this.length,
  });

  /// End index of the horizontal text (exclusive)
  int get endIndex => startIndex + length;

  @override
  String toString() {
    return 'Tatechuyoko(startIndex: $startIndex, length: $length)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tatechuyoko &&
        other.startIndex == startIndex &&
        other.length == length;
  }

  @override
  int get hashCode => Object.hash(startIndex, length);
}
