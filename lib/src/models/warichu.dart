/// Warichu (inline annotations) for vertical text
///
/// Warichu are inline annotations displayed in two smaller lines
/// within the main vertical text flow
class Warichu {
  /// Starting index in the main text where warichu begins
  final int startIndex;

  /// Length of the warichu text
  final int length;

  /// Text content of the warichu
  final String text;

  /// Position to split the warichu into two lines (index within warichu text)
  /// If null, splits at the middle
  final int? splitIndex;

  const Warichu({
    required this.startIndex,
    required this.length,
    required this.text,
    this.splitIndex,
  });

  /// End index of the warichu text (exclusive)
  int get endIndex => startIndex + length;

  /// Get the first line of warichu
  String get firstLine {
    if (splitIndex == null) {
      // Split at middle
      final mid = (text.length / 2).ceil();
      return text.substring(0, mid);
    }
    return text.substring(0, splitIndex);
  }

  /// Get the second line of warichu
  String get secondLine {
    if (splitIndex == null) {
      // Split at middle
      final mid = (text.length / 2).ceil();
      return text.substring(mid);
    }
    return text.substring(splitIndex!);
  }

  @override
  String toString() {
    return 'Warichu(startIndex: $startIndex, length: $length, text: "$text", splitIndex: $splitIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Warichu &&
        other.startIndex == startIndex &&
        other.length == length &&
        other.text == text &&
        other.splitIndex == splitIndex;
  }

  @override
  int get hashCode => Object.hash(startIndex, length, text, splitIndex);
}
