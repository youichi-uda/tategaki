import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiny_segmenter_dart/tiny_segmenter_dart.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/warichu.dart';
import '../models/tatechuyoko.dart';
import '../models/text_decoration.dart';
import '../models/gaiji.dart';
import '../rendering/text_layouter.dart';
import '../rendering/vertical_text_painter.dart';

/// A vertical text widget that only starts selection on long press.
///
/// Unlike [SelectionAreaVerticalText] which works with Flutter's SelectionArea,
/// this widget handles gestures internally and only allows selection to start
/// with a long press gesture, similar to Android Chrome's behavior.
///
/// This is ideal for reading apps where drag gestures should scroll the content
/// rather than select text.
///
/// ```dart
/// LongPressSelectableVerticalText(
///   text: '縦書きテキスト',
///   style: VerticalTextStyle(baseStyle: TextStyle(fontSize: 24)),
/// )
/// ```
class LongPressSelectableVerticalText extends StatefulWidget {
  /// The text to display
  final String text;

  /// Style configuration for the text
  final VerticalTextStyle style;

  /// Maximum height for line breaking (0 = no limit)
  final double maxHeight;

  /// Ruby text annotations
  final List<RubyText> rubyList;

  /// Kenten (emphasis marks) annotations
  final List<Kenten> kentenList;

  /// Warichu (inline notes) annotations
  final List<Warichu> warichuList;

  /// Tatechuyoko (horizontal text in vertical) annotations
  final List<Tatechuyoko> tatechuyokoList;

  /// Text decoration annotations
  final List<TextDecorationAnnotation> decorationList;

  /// Gaiji (custom character images) annotations
  final List<Gaiji> gaijiList;

  /// Whether to automatically detect and apply tatechuyoko
  final bool autoTatechuyoko;

  /// Selection color (if null, uses theme default)
  final Color? selectionColor;

  /// Long press duration before selection starts (default: 500ms)
  final Duration longPressDuration;

  const LongPressSelectableVerticalText({
    super.key,
    required this.text,
    this.style = const VerticalTextStyle(),
    this.maxHeight = 0,
    this.rubyList = const [],
    this.kentenList = const [],
    this.warichuList = const [],
    this.tatechuyokoList = const [],
    this.decorationList = const [],
    this.gaijiList = const [],
    this.autoTatechuyoko = false,
    this.selectionColor,
    this.longPressDuration = const Duration(milliseconds: 500),
  });

  @override
  State<LongPressSelectableVerticalText> createState() =>
      _LongPressSelectableVerticalTextState();
}

class _LongPressSelectableVerticalTextState
    extends State<LongPressSelectableVerticalText> {
  // Selection state
  int _selectionStart = -1;
  int _selectionEnd = -1;
  bool _isSelecting = false;

  // Layout cache
  List<CharacterLayout>? _characterLayouts;
  Size? _computedSize;
  late TextLayouter _layouter;

  // TinySegmenter for word detection
  static final TinySegmenter _segmenter = TinySegmenter();
  List<_WordRange>? _wordRanges;

  // Context menu
  OverlayEntry? _contextMenuOverlay;

  @override
  void initState() {
    super.initState();
    _layouter = TextLayouter();
  }

  @override
  void didUpdateWidget(LongPressSelectableVerticalText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.maxHeight != widget.maxHeight) {
      _characterLayouts = null;
      _computedSize = null;
      _wordRanges = null;
      _clearSelection();
    }
  }

  @override
  void dispose() {
    _hideContextMenu();
    super.dispose();
  }

  void _clearSelection() {
    setState(() {
      _selectionStart = -1;
      _selectionEnd = -1;
      _isSelecting = false;
    });
  }

  void _ensureLayout(BoxConstraints constraints) {
    if (_characterLayouts != null && _computedSize != null) return;

    final fontSize = widget.style.baseStyle.fontSize ?? 16.0;
    final effectiveMaxHeight =
        widget.maxHeight > 0 ? widget.maxHeight : constraints.maxHeight;

    // Collect tatechuyoko indices
    Set<int>? tatechuyokoIndices;
    if (widget.tatechuyokoList.isNotEmpty || widget.autoTatechuyoko) {
      tatechuyokoIndices = <int>{};
      for (final t in widget.tatechuyokoList) {
        for (int i = t.startIndex; i < t.startIndex + t.length; i++) {
          tatechuyokoIndices.add(i);
        }
      }
    }

    // First pass: layout to calculate size
    final initialLayouts = _layouter.layoutText(
      widget.text,
      widget.style,
      effectiveMaxHeight,
      tatechuyokoIndices: tatechuyokoIndices,
    );

    // Calculate size
    if (initialLayouts.isEmpty) {
      _characterLayouts = initialLayouts;
      _computedSize = Size.zero;
      return;
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = 0;

    for (final layout in initialLayouts) {
      minX = math.min(minX, layout.position.dx - fontSize / 2);
      maxX = math.max(maxX, layout.position.dx + fontSize / 2);
      maxY = math.max(maxY, layout.position.dy + fontSize);
    }

    // Add ruby space
    final rubyFontSize = widget.style.rubyStyle?.fontSize ?? fontSize * 0.5;

    final width = (maxX - minX) + rubyFontSize + fontSize;
    final height =
        math.max(maxY, effectiveMaxHeight > 0 ? effectiveMaxHeight : maxY);

    _computedSize = Size(width, height);

    // Second pass: layout with correct startX
    final startX = _computedSize!.width - fontSize;
    _characterLayouts = _layouter.layoutText(
      widget.text,
      widget.style,
      effectiveMaxHeight,
      tatechuyokoIndices: tatechuyokoIndices,
      startX: startX,
    );
  }

  void _ensureWordRanges() {
    if (_wordRanges != null) return;

    final words = _segmenter.segment(widget.text);
    _wordRanges = [];
    int currentIndex = 0;

    for (final word in words) {
      _wordRanges!.add(_WordRange(currentIndex, currentIndex + word.length));
      currentIndex += word.length;
    }
  }

  _WordRange? _getWordRangeAt(int charIndex) {
    _ensureWordRanges();
    for (final range in _wordRanges!) {
      if (charIndex >= range.start && charIndex < range.end) {
        return range;
      }
    }
    return null;
  }

  int _getCharacterIndexAt(Offset localPosition) {
    if (_characterLayouts == null || _characterLayouts!.isEmpty) return -1;

    final fontSize = widget.style.baseStyle.fontSize ?? 16.0;
    double closestDistance = double.infinity;
    int closestIndex = -1;

    for (final layout in _characterLayouts!) {
      final charCenter = Offset(
        layout.position.dx,
        layout.position.dy + fontSize / 2,
      );
      final distance = (charCenter - localPosition).distance;

      if (distance < closestDistance && distance < fontSize * 2) {
        closestDistance = distance;
        closestIndex = layout.textIndex;
      }
    }

    return closestIndex;
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _hideContextMenu();

    final charIndex = _getCharacterIndexAt(details.localPosition);
    if (charIndex < 0) return;

    final wordRange = _getWordRangeAt(charIndex);

    setState(() {
      _isSelecting = true;
      if (wordRange != null) {
        _selectionStart = wordRange.start;
        _selectionEnd = wordRange.end;
      } else {
        _selectionStart = charIndex;
        _selectionEnd = (charIndex + 1).clamp(0, widget.text.length);
      }
    });

    // Haptic feedback
    HapticFeedback.selectionClick();
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isSelecting) return;

    final charIndex = _getCharacterIndexAt(details.localPosition);
    if (charIndex < 0) return;

    final wordRange = _getWordRangeAt(charIndex);

    setState(() {
      if (wordRange != null) {
        // Extend selection to include the word under the finger
        if (wordRange.end > _selectionStart) {
          _selectionEnd = wordRange.end;
        } else {
          _selectionStart = wordRange.start;
        }
      } else {
        // Extend selection character by character
        if (charIndex >= _selectionStart) {
          _selectionEnd = (charIndex + 1).clamp(0, widget.text.length);
        } else {
          _selectionStart = charIndex;
        }
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _isSelecting = false;

    if (_selectionStart >= 0 && _selectionEnd > _selectionStart) {
      _showContextMenu(details.globalPosition);
    }
  }

  void _handleTap() {
    _hideContextMenu();
    _clearSelection();
  }

  void _showContextMenu(Offset globalPosition) {
    _hideContextMenu();

    final overlay = Overlay.of(context);

    _contextMenuOverlay = OverlayEntry(
      builder: (context) => _SelectionContextMenu(
        position: globalPosition,
        onCopy: _copySelection,
        onDismiss: () {
          _hideContextMenu();
          _clearSelection();
        },
      ),
    );

    overlay.insert(_contextMenuOverlay!);
  }

  void _hideContextMenu() {
    _contextMenuOverlay?.remove();
    _contextMenuOverlay = null;
  }

  void _copySelection() {
    if (_selectionStart >= 0 && _selectionEnd > _selectionStart) {
      final start = math.min(_selectionStart, _selectionEnd);
      final end = math.max(_selectionStart, _selectionEnd);
      final selectedText = widget.text.substring(start, end);
      Clipboard.setData(ClipboardData(text: selectedText));

      // Show snackbar feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('コピーしました'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    _hideContextMenu();
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _ensureLayout(constraints);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: _handleLongPressEnd,
          child: CustomPaint(
            size: _computedSize ?? Size.zero,
            painter: _LongPressSelectableVerticalTextPainter(
              text: widget.text,
              style: widget.style,
              rubyList: widget.rubyList,
              kentenList: widget.kentenList,
              warichuList: widget.warichuList,
              tatechuyokoList: widget.tatechuyokoList,
              decorationList: widget.decorationList,
              gaijiList: widget.gaijiList,
              autoTatechuyoko: widget.autoTatechuyoko,
              maxHeight: widget.maxHeight,
              selectionStart: _selectionStart,
              selectionEnd: _selectionEnd,
              selectionColor: widget.selectionColor ??
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
              characterLayouts: _characterLayouts,
            ),
          ),
        );
      },
    );
  }
}

/// Simple word range holder
class _WordRange {
  final int start;
  final int end;

  const _WordRange(this.start, this.end);
}

/// Custom painter for the selectable vertical text
class _LongPressSelectableVerticalTextPainter extends CustomPainter {
  final String text;
  final VerticalTextStyle style;
  final List<RubyText> rubyList;
  final List<Kenten> kentenList;
  final List<Warichu> warichuList;
  final List<Tatechuyoko> tatechuyokoList;
  final List<TextDecorationAnnotation> decorationList;
  final List<Gaiji> gaijiList;
  final bool autoTatechuyoko;
  final double maxHeight;
  final int selectionStart;
  final int selectionEnd;
  final Color selectionColor;
  final List<CharacterLayout>? characterLayouts;

  _LongPressSelectableVerticalTextPainter({
    required this.text,
    required this.style,
    required this.rubyList,
    required this.kentenList,
    required this.warichuList,
    required this.tatechuyokoList,
    required this.decorationList,
    required this.gaijiList,
    required this.autoTatechuyoko,
    required this.maxHeight,
    required this.selectionStart,
    required this.selectionEnd,
    required this.selectionColor,
    required this.characterLayouts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw selection highlight first
    if (selectionStart >= 0 && selectionEnd > selectionStart && characterLayouts != null) {
      _paintSelection(canvas, size);
    }

    // Draw text using VerticalTextPainter
    final painter = VerticalTextPainter(
      text: text,
      style: style,
      ruby: rubyList,
      kenten: kentenList,
      warichu: warichuList,
      tatechuyoko: tatechuyokoList,
      decorations: decorationList,
      gaiji: gaijiList,
      autoTatechuyoko: autoTatechuyoko,
      maxHeight: maxHeight,
    );
    painter.paint(canvas, size);
  }

  void _paintSelection(Canvas canvas, Size size) {
    final paint = Paint()..color = selectionColor;
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    final start = math.min(selectionStart, selectionEnd);
    final end = math.max(selectionStart, selectionEnd);

    for (final layout in characterLayouts!) {
      if (layout.textIndex >= start && layout.textIndex < end) {
        final rect = Rect.fromLTWH(
          layout.position.dx - fontSize / 2,
          layout.position.dy,
          fontSize,
          fontSize,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LongPressSelectableVerticalTextPainter oldDelegate) {
    return text != oldDelegate.text ||
        style != oldDelegate.style ||
        selectionStart != oldDelegate.selectionStart ||
        selectionEnd != oldDelegate.selectionEnd ||
        selectionColor != oldDelegate.selectionColor;
  }
}

/// Context menu for copy action
class _SelectionContextMenu extends StatelessWidget {
  final Offset position;
  final VoidCallback onCopy;
  final VoidCallback onDismiss;

  const _SelectionContextMenu({
    required this.position,
    required this.onCopy,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dismiss layer
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        // Context menu
        Positioned(
          left: position.dx - 40,
          top: position.dy - 50,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 6),
                    Text('コピー'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
