import 'vertical_text_style.dart';
import 'ruby_text.dart';
import 'kenten.dart';

/// A styled character with its global position in the flattened text
class StyledCharacter {
  /// The character string
  final String character;

  /// Style for this character
  final VerticalTextStyle style;

  /// Global index in the complete text
  final int globalIndex;

  const StyledCharacter({
    required this.character,
    required this.style,
    required this.globalIndex,
  });
}

/// A span of vertical text with optional children, similar to TextSpan
///
/// This allows creating rich text with multiple styles, ruby, and kenten
/// within a single vertical text widget.
class VerticalTextSpan {
  /// The text content of this span
  final String? text;

  /// Style for this span (inherits from parent if not specified)
  final VerticalTextStyle? style;

  /// Child spans (for nested styling)
  final List<VerticalTextSpan>? children;

  /// Ruby annotations for this span
  final List<RubyText>? ruby;

  /// Kenten (emphasis dots) for this span
  final List<Kenten>? kenten;

  const VerticalTextSpan({
    this.text,
    this.style,
    this.children,
    this.ruby,
    this.kenten,
  });

  /// Flatten the span tree into a list of styled characters
  ///
  /// This converts the hierarchical structure into a flat list that can
  /// be rendered sequentially, with proper style inheritance.
  List<StyledCharacter> flatten({
    VerticalTextStyle? inheritedStyle,
  }) {
    final result = <StyledCharacter>[];
    final effectiveStyle = style ?? inheritedStyle ?? const VerticalTextStyle();

    // Add characters from this span's text
    if (text != null && text!.isNotEmpty) {
      for (int i = 0; i < text!.length; i++) {
        result.add(StyledCharacter(
          character: text![i],
          style: effectiveStyle,
          globalIndex: result.length,
        ));
      }
    }

    // Recursively flatten children
    if (children != null) {
      for (final child in children!) {
        final childChars = child.flatten(inheritedStyle: effectiveStyle);
        // Update global indices
        for (final char in childChars) {
          result.add(StyledCharacter(
            character: char.character,
            style: char.style,
            globalIndex: result.length,
          ));
        }
      }
    }

    return result;
  }

  /// Get the total text length including all children
  int get textLength {
    int length = text?.length ?? 0;
    if (children != null) {
      for (final child in children!) {
        length += child.textLength;
      }
    }
    return length;
  }

  /// Get the complete text including all children
  String get fullText {
    final buffer = StringBuffer();
    if (text != null) {
      buffer.write(text);
    }
    if (children != null) {
      for (final child in children!) {
        buffer.write(child.fullText);
      }
    }
    return buffer.toString();
  }
}
