import 'package:flutter/material.dart';
import 'kenten.dart';

/// Base class for vertical text spans (similar to Flutter's TextSpan)
///
/// This is the base class for all vertical text composition.
/// It can contain plain text, styled text, or special annotations.
abstract class VerticalTextSpan {
  /// The text content of this span
  final String? text;

  /// Child spans (for nested composition)
  final List<VerticalTextSpan>? children;

  /// Text style for this span
  final TextStyle? style;

  const VerticalTextSpan({
    this.text,
    this.children,
    this.style,
  }) : assert(text != null || children != null,
            'Either text or children must be provided');

  /// Get the plain text representation of this span and its children
  ///
  /// Note: WarichuSpan text is NOT included in plain text as warichu
  /// is an inline annotation, not part of the main text flow.
  String toPlainText() {
    final buffer = StringBuffer();

    // WarichuSpan text is not part of the main text
    if (this is! WarichuSpan) {
      if (text != null) {
        buffer.write(text);
      }
    }

    if (children != null) {
      for (final child in children!) {
        buffer.write(child.toPlainText());
      }
    }
    return buffer.toString();
  }

  /// Get the total text length including all children
  ///
  /// Note: WarichuSpan text is NOT counted as it's not part of the main text.
  int get textLength {
    int length = 0;

    // WarichuSpan text is not part of the main text
    if (this is! WarichuSpan) {
      length = text?.length ?? 0;
    }

    if (children != null) {
      for (final child in children!) {
        length += child.textLength;
      }
    }
    return length;
  }

  /// Visit this span and all child spans with their start indices
  void visitSpans(void Function(VerticalTextSpan span, int startIndex) visitor) {
    _visitSpansRecursive(visitor, 0);
  }

  int _visitSpansRecursive(
    void Function(VerticalTextSpan span, int startIndex) visitor,
    int currentIndex,
  ) {
    visitor(this, currentIndex);

    int index = currentIndex;

    // WarichuSpan text is not part of the main text, so don't advance index
    if (this is! WarichuSpan) {
      if (text != null) {
        index += text!.length;
      }
    }

    if (children != null) {
      for (final child in children!) {
        index = child._visitSpansRecursive(visitor, index);
      }
    }
    return index;
  }
}

/// Plain text span with optional styling
class TextSpanV extends VerticalTextSpan {
  const TextSpanV({
    String? text,
    List<VerticalTextSpan>? children,
    super.style,
  }) : super(text: text, children: children);
}

/// Text span with ruby (furigana) annotation
class RubySpan extends VerticalTextSpan {
  /// The ruby text to display above the base text
  final String ruby;

  const RubySpan({
    required String text,
    required this.ruby,
    super.style,
  }) : super(text: text);
}

/// Text span with warichu (inline annotation in two lines)
class WarichuSpan extends VerticalTextSpan {
  /// Where to split the text into two lines (optional)
  /// If null, splits at the middle
  final int? splitIndex;

  const WarichuSpan({
    required String text,
    this.splitIndex,
    super.style,
  }) : super(text: text);

  /// Get the first line of warichu
  String get firstLine {
    if (text == null) return '';
    if (splitIndex == null) {
      final mid = (text!.length / 2).ceil();
      return text!.substring(0, mid);
    }
    return text!.substring(0, splitIndex);
  }

  /// Get the second line of warichu
  String get secondLine {
    if (text == null) return '';
    if (splitIndex == null) {
      final mid = (text!.length / 2).ceil();
      return text!.substring(mid);
    }
    return text!.substring(splitIndex!);
  }
}

/// Text span with kenten (emphasis marks)
class KentenSpan extends VerticalTextSpan {
  /// The style of kenten marks
  final KentenStyle kentenStyle;

  const KentenSpan({
    required String text,
    required this.kentenStyle,
    super.style,
  }) : super(text: text);
}

/// Text span for tatechuyoko (horizontal text within vertical)
class TatechuyokoSpan extends VerticalTextSpan {
  const TatechuyokoSpan({
    required String text,
    super.style,
  }) : super(text: text);
}
