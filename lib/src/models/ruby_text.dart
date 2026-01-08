/// Ruby text (furigana) annotation for vertical text
/// 
/// Ruby text is phonetic guide text displayed alongside Japanese characters
class RubyText {
  /// Starting index of the base text in the full string
  final int startIndex;

  /// Length of the base text
  final int length;

  /// Ruby text (furigana) to display
  final String ruby;

  const RubyText({
    required this.startIndex,
    required this.length,
    required this.ruby,
  });

  /// End index of the base text (exclusive)
  int get endIndex => startIndex + length;

  @override
  String toString() {
    return 'RubyText(startIndex: $startIndex, length: $length, ruby: $ruby)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RubyText &&
        other.startIndex == startIndex &&
        other.length == length &&
        other.ruby == ruby;
  }

  @override
  int get hashCode => Object.hash(startIndex, length, ruby);
}
