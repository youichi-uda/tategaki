import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/warichu.dart';
import '../models/tatechuyoko.dart';
import '../models/text_decoration.dart';
import '../models/gaiji.dart';
import '../rendering/text_layouter.dart';
import '../rendering/vertical_text_painter.dart';

/// A vertical text widget that integrates with Flutter's Selection API.
///
/// Use this widget inside a [SelectionArea] to enable text selection
/// that works with other selectable widgets.
///
/// ```dart
/// SelectionArea(
///   child: Column(
///     children: [
///       SelectionAreaVerticalText(
///         text: '縦書きテキスト',
///         style: VerticalTextStyle(baseStyle: TextStyle(fontSize: 24)),
///       ),
///       SelectableText('横書きテキスト'),
///     ],
///   ),
/// )
/// ```
class SelectionAreaVerticalText extends LeafRenderObjectWidget {
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

  const SelectionAreaVerticalText({
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
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSelectionAreaVerticalText(
      text: text,
      style: style,
      maxHeight: maxHeight,
      rubyList: rubyList,
      kentenList: kentenList,
      warichuList: warichuList,
      tatechuyokoList: tatechuyokoList,
      decorationList: decorationList,
      gaijiList: gaijiList,
      autoTatechuyoko: autoTatechuyoko,
      selectionColor: selectionColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
      registrar: SelectionContainer.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSelectionAreaVerticalText renderObject) {
    renderObject
      ..text = text
      ..style = style
      ..maxHeight = maxHeight
      ..rubyList = rubyList
      ..kentenList = kentenList
      ..warichuList = warichuList
      ..tatechuyokoList = tatechuyokoList
      ..decorationList = decorationList
      ..gaijiList = gaijiList
      ..autoTatechuyoko = autoTatechuyoko
      ..selectionColor = selectionColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
      ..registrar = SelectionContainer.maybeOf(context);
  }
}

/// RenderObject for SelectionAreaVerticalText with Selection API integration
class RenderSelectionAreaVerticalText extends RenderBox with Selectable, SelectionRegistrant {
  RenderSelectionAreaVerticalText({
    required String text,
    required VerticalTextStyle style,
    required double maxHeight,
    required List<RubyText> rubyList,
    required List<Kenten> kentenList,
    required List<Warichu> warichuList,
    required List<Tatechuyoko> tatechuyokoList,
    required List<TextDecorationAnnotation> decorationList,
    required List<Gaiji> gaijiList,
    required bool autoTatechuyoko,
    required Color selectionColor,
    SelectionRegistrar? registrar,
  })  : _text = text,
        _style = style,
        _maxHeight = maxHeight,
        _rubyList = rubyList,
        _kentenList = kentenList,
        _warichuList = warichuList,
        _tatechuyokoList = tatechuyokoList,
        _decorationList = decorationList,
        _gaijiList = gaijiList,
        _autoTatechuyoko = autoTatechuyoko,
        _selectionColor = selectionColor {
    this.registrar = registrar;
    _layouter = TextLayouter();
  }

  late TextLayouter _layouter;
  List<CharacterLayout>? _characterLayouts;
  Size? _computedSize;

  // Selection state
  int _selectionStart = -1;
  int _selectionEnd = -1;
  SelectionGeometry _selectionGeometry = const SelectionGeometry(
    status: SelectionStatus.none,
    hasContent: true,
  );

  // Listeners for ValueListenable
  final List<VoidCallback> _listeners = [];

  // Properties
  String _text;
  String get text => _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    _characterLayouts = null;
    markNeedsLayout();
    _updateSelectionGeometry();
  }

  VerticalTextStyle _style;
  VerticalTextStyle get style => _style;
  set style(VerticalTextStyle value) {
    if (_style == value) return;
    _style = value;
    _characterLayouts = null;
    markNeedsLayout();
  }

  double _maxHeight;
  double get maxHeight => _maxHeight;
  set maxHeight(double value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    _characterLayouts = null;
    markNeedsLayout();
  }

  List<RubyText> _rubyList;
  List<RubyText> get rubyList => _rubyList;
  set rubyList(List<RubyText> value) {
    if (_rubyList == value) return;
    _rubyList = value;
    markNeedsPaint();
  }

  List<Kenten> _kentenList;
  List<Kenten> get kentenList => _kentenList;
  set kentenList(List<Kenten> value) {
    if (_kentenList == value) return;
    _kentenList = value;
    markNeedsPaint();
  }

  List<Warichu> _warichuList;
  List<Warichu> get warichuList => _warichuList;
  set warichuList(List<Warichu> value) {
    if (_warichuList == value) return;
    _warichuList = value;
    markNeedsPaint();
  }

  List<Tatechuyoko> _tatechuyokoList;
  List<Tatechuyoko> get tatechuyokoList => _tatechuyokoList;
  set tatechuyokoList(List<Tatechuyoko> value) {
    if (_tatechuyokoList == value) return;
    _tatechuyokoList = value;
    _characterLayouts = null;
    markNeedsLayout();
  }

  List<TextDecorationAnnotation> _decorationList;
  List<TextDecorationAnnotation> get decorationList => _decorationList;
  set decorationList(List<TextDecorationAnnotation> value) {
    if (_decorationList == value) return;
    _decorationList = value;
    markNeedsPaint();
  }

  List<Gaiji> _gaijiList;
  List<Gaiji> get gaijiList => _gaijiList;
  set gaijiList(List<Gaiji> value) {
    if (_gaijiList == value) return;
    _gaijiList = value;
    markNeedsPaint();
  }

  bool _autoTatechuyoko;
  bool get autoTatechuyoko => _autoTatechuyoko;
  set autoTatechuyoko(bool value) {
    if (_autoTatechuyoko == value) return;
    _autoTatechuyoko = value;
    _characterLayouts = null;
    markNeedsLayout();
  }

  Color _selectionColor;
  Color get selectionColor => _selectionColor;
  set selectionColor(Color value) {
    if (_selectionColor == value) return;
    _selectionColor = value;
    markNeedsPaint();
  }

  // Handle layers for selection handles
  LayerLink? _startHandleLayerLink;
  LayerLink? _endHandleLayerLink;

  // Selectable implementation
  @override
  SelectionGeometry get value => _selectionGeometry;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Returns the length of text content
  @override
  int get contentLength => _text.length;

  /// Returns the selection range
  @override
  SelectedContentRange? getSelection() {
    if (_selectionStart < 0 || _selectionEnd < 0) return null;
    if (_selectionStart == _selectionEnd) return null;
    final start = math.min(_selectionStart, _selectionEnd);
    final end = math.max(_selectionStart, _selectionEnd);
    return SelectedContentRange(startOffset: start, endOffset: end);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void dispose() {
    _listeners.clear();
    super.dispose();
  }

  @override
  List<Rect> get boundingBoxes => <Rect>[paintBounds];

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    _ensureLayout(constraints);
    return _computedSize ?? Size.zero;
  }

  @override
  void performLayout() {
    _ensureLayout(constraints);
    size = _computedSize ?? Size.zero;
    _updateSelectionGeometry();
  }

  void _ensureLayout(BoxConstraints constraints) {
    if (_characterLayouts != null && _computedSize != null) return;

    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    final effectiveMaxHeight = _maxHeight > 0 ? _maxHeight : constraints.maxHeight;

    // Collect tatechuyoko indices
    Set<int>? tatechuyokoIndices;
    if (_tatechuyokoList.isNotEmpty || _autoTatechuyoko) {
      tatechuyokoIndices = <int>{};
      for (final t in _tatechuyokoList) {
        for (int i = t.startIndex; i < t.startIndex + t.length; i++) {
          tatechuyokoIndices.add(i);
        }
      }
    }

    // First pass: layout to calculate size
    final initialLayouts = _layouter.layoutText(
      _text,
      _style,
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
    final rubyFontSize = _style.rubyStyle?.fontSize ?? fontSize * 0.5;

    final width = (maxX - minX) + rubyFontSize + fontSize;
    final height = math.max(maxY, effectiveMaxHeight > 0 ? effectiveMaxHeight : maxY);

    _computedSize = Size(width, height);

    // Second pass: layout with correct startX (matching VerticalTextPainter)
    final startX = _computedSize!.width - fontSize;
    _characterLayouts = _layouter.layoutText(
      _text,
      _style,
      effectiveMaxHeight,
      tatechuyokoIndices: tatechuyokoIndices,
      startX: startX,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_characterLayouts == null || _characterLayouts!.isEmpty) return;

    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Draw selection highlight
    if (_selectionStart >= 0 && _selectionEnd >= 0 && _selectionStart != _selectionEnd) {
      _paintSelection(canvas);
    }

    // Draw text using VerticalTextPainter
    final painter = VerticalTextPainter(
      text: _text,
      style: _style,
      ruby: _rubyList,
      kenten: _kentenList,
      warichu: _warichuList,
      tatechuyoko: _tatechuyokoList,
      decorations: _decorationList,
      gaiji: _gaijiList,
      autoTatechuyoko: _autoTatechuyoko,
      maxHeight: _maxHeight,
    );
    painter.paint(canvas, size);

    canvas.restore();

    // Paint handle layers
    _paintHandleLayers(context, offset);
  }

  void _paintHandleLayers(PaintingContext context, Offset offset) {
    if (_selectionStart < 0 || _selectionEnd < 0 || _selectionStart == _selectionEnd) {
      return;
    }

    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    final start = math.min(_selectionStart, _selectionEnd);
    final end = math.max(_selectionStart, _selectionEnd);

    Offset? startOffset;
    Offset? endOffset;

    for (final layout in _characterLayouts!) {
      if (layout.textIndex == start) {
        startOffset = Offset(
          offset.dx + layout.position.dx,
          offset.dy + layout.position.dy,
        );
      }
      if (layout.textIndex == end - 1) {
        endOffset = Offset(
          offset.dx + layout.position.dx,
          offset.dy + layout.position.dy + fontSize,
        );
      }
    }

    // Paint start handle layer
    if (_startHandleLayerLink != null && startOffset != null) {
      context.pushLayer(
        LeaderLayer(link: _startHandleLayerLink!, offset: startOffset),
        (context, offset) {},
        Offset.zero,
      );
    }

    // Paint end handle layer
    if (_endHandleLayerLink != null && endOffset != null) {
      context.pushLayer(
        LeaderLayer(link: _endHandleLayerLink!, offset: endOffset),
        (context, offset) {},
        Offset.zero,
      );
    }
  }

  void _paintSelection(Canvas canvas) {
    final paint = Paint()..color = _selectionColor;
    final fontSize = _style.baseStyle.fontSize ?? 16.0;

    final start = math.min(_selectionStart, _selectionEnd);
    final end = math.max(_selectionStart, _selectionEnd);

    for (final layout in _characterLayouts!) {
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

  // Selection API methods
  @override
  SelectionResult dispatchSelectionEvent(SelectionEvent event) {
    switch (event) {
      case SelectAllSelectionEvent():
        _selectAll();
        return SelectionResult.none;
      case ClearSelectionEvent():
        _clearSelection();
        return SelectionResult.none;
      case SelectWordSelectionEvent():
        _selectWordAt(event.globalPosition);
        return SelectionResult.none;
      case GranularlyExtendSelectionEvent():
        return _handleGranularlyExtendSelection(event);
      case DirectionallyExtendSelectionEvent():
        return _handleDirectionallyExtendSelection(event);
      case SelectionEdgeUpdateEvent():
        return _handleSelectionEdgeUpdate(event);
      default:
        return SelectionResult.none;
    }
  }

  void _selectAll() {
    if (_text.isEmpty) return;
    _selectionStart = 0;
    _selectionEnd = _text.length;
    _updateSelectionGeometry();
    markNeedsPaint();
  }

  void _clearSelection() {
    _selectionStart = -1;
    _selectionEnd = -1;
    _updateSelectionGeometry();
    markNeedsPaint();
  }

  void _selectWordAt(Offset globalPosition) {
    // Ensure layout is performed
    if (_characterLayouts == null || _characterLayouts!.isEmpty) {
      _ensureLayout(constraints);
    }
    if (_characterLayouts == null || _characterLayouts!.isEmpty) return;

    final localPosition = globalToLocal(globalPosition);
    final index = _getCharacterIndexAt(localPosition);

    // If no character found, select first character as fallback
    final effectiveIndex = index < 0 ? 0 : index;

    // Simple word selection - select the character
    _selectionStart = effectiveIndex;
    _selectionEnd = (effectiveIndex + 1).clamp(0, _text.length);
    _updateSelectionGeometry();
    markNeedsPaint();
  }

  SelectionResult _handleGranularlyExtendSelection(GranularlyExtendSelectionEvent event) {
    if (_characterLayouts == null || _characterLayouts!.isEmpty) {
      return SelectionResult.none;
    }

    int newIndex;
    if (event.forward) {
      newIndex = event.isEnd ? _selectionEnd + 1 : _selectionStart + 1;
    } else {
      newIndex = event.isEnd ? _selectionEnd - 1 : _selectionStart - 1;
    }

    newIndex = newIndex.clamp(0, _text.length);

    if (event.isEnd) {
      _selectionEnd = newIndex;
    } else {
      _selectionStart = newIndex;
    }

    _updateSelectionGeometry();
    markNeedsPaint();
    return SelectionResult.end;
  }

  SelectionResult _handleDirectionallyExtendSelection(DirectionallyExtendSelectionEvent event) {
    if (_characterLayouts == null || _characterLayouts!.isEmpty) {
      return SelectionResult.none;
    }

    // For vertical text, up/down moves along the line, left/right moves between lines
    int delta = 0;
    switch (event.direction) {
      case SelectionExtendDirection.previousLine:
      case SelectionExtendDirection.backward:
        delta = -1;
      case SelectionExtendDirection.nextLine:
      case SelectionExtendDirection.forward:
        delta = 1;
    }

    int newIndex = (event.isEnd ? _selectionEnd : _selectionStart) + delta;
    newIndex = newIndex.clamp(0, _text.length);

    if (event.isEnd) {
      _selectionEnd = newIndex;
    } else {
      _selectionStart = newIndex;
    }

    _updateSelectionGeometry();
    markNeedsPaint();
    return SelectionResult.end;
  }

  SelectionResult _handleSelectionEdgeUpdate(SelectionEdgeUpdateEvent event) {
    final localPosition = globalToLocal(event.globalPosition);
    final index = _getCharacterIndexAt(localPosition);
    final isStart = event.type == SelectionEventType.startEdgeUpdate;

    if (index < 0) {
      // Check if position is before or after content
      if (_characterLayouts == null || _characterLayouts!.isEmpty) {
        return SelectionResult.none;
      }

      final firstLayout = _characterLayouts!.first;
      final lastLayout = _characterLayouts!.last;

      // For vertical text (right to left), check X position
      if (localPosition.dx > firstLayout.position.dx) {
        // Before content (to the right)
        if (isStart) {
          _selectionStart = 0;
        } else {
          _selectionEnd = 0;
        }
        _updateSelectionGeometry();
        markNeedsPaint();
        return SelectionResult.previous;
      } else if (localPosition.dx < lastLayout.position.dx) {
        // After content (to the left)
        if (isStart) {
          _selectionStart = _text.length;
        } else {
          _selectionEnd = _text.length;
        }
        _updateSelectionGeometry();
        markNeedsPaint();
        return SelectionResult.next;
      }
    }

    final clampedIndex = index < 0 ? 0 : index;

    if (isStart) {
      _selectionStart = clampedIndex;
      if (_selectionEnd < 0) _selectionEnd = clampedIndex;
    } else {
      _selectionEnd = clampedIndex;
      if (_selectionStart < 0) _selectionStart = clampedIndex;
    }

    _updateSelectionGeometry();
    markNeedsPaint();
    return SelectionResult.end;
  }

  int _getCharacterIndexAt(Offset localPosition) {
    if (_characterLayouts == null || _characterLayouts!.isEmpty) return -1;

    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    double closestDistance = double.infinity;
    int closestIndex = -1;

    for (final layout in _characterLayouts!) {
      final charCenter = Offset(
        layout.position.dx,
        layout.position.dy + fontSize / 2,
      );
      final distance = (charCenter - localPosition).distance;

      if (distance < closestDistance && distance < fontSize * 1.5) {
        closestDistance = distance;
        closestIndex = layout.textIndex;
      }
    }

    return closestIndex;
  }

  void _updateSelectionGeometry() {
    final oldGeometry = _selectionGeometry;

    if (_selectionStart < 0 || _selectionEnd < 0 || _characterLayouts == null) {
      _selectionGeometry = SelectionGeometry(
        status: SelectionStatus.none,
        hasContent: _text.isNotEmpty,
      );
    } else if (_selectionStart == _selectionEnd) {
      _selectionGeometry = SelectionGeometry(
        status: SelectionStatus.collapsed,
        hasContent: _text.isNotEmpty,
      );
    } else {
      final fontSize = _style.baseStyle.fontSize ?? 16.0;
      final start = math.min(_selectionStart, _selectionEnd);
      final end = math.max(_selectionStart, _selectionEnd);

      // Find start and end positions
      Offset? startOffset;
      Offset? endOffset;

      for (final layout in _characterLayouts!) {
        if (layout.textIndex == start) {
          startOffset = Offset(
            layout.position.dx,
            layout.position.dy,
          );
        }
        if (layout.textIndex == end - 1) {
          endOffset = Offset(
            layout.position.dx,
            layout.position.dy + fontSize,
          );
        }
      }

      // Use fallback positions if not found
      if (startOffset == null && _characterLayouts!.isNotEmpty) {
        final firstLayout = _characterLayouts!.first;
        startOffset = Offset(firstLayout.position.dx, firstLayout.position.dy);
      }
      if (endOffset == null && _characterLayouts!.isNotEmpty) {
        final lastLayout = _characterLayouts!.last;
        endOffset = Offset(lastLayout.position.dx, lastLayout.position.dy + fontSize);
      }

      if (startOffset == null || endOffset == null) {
        _selectionGeometry = SelectionGeometry(
          status: SelectionStatus.none,
          hasContent: _text.isNotEmpty,
        );
      } else {
        _selectionGeometry = SelectionGeometry(
          status: SelectionStatus.uncollapsed,
          hasContent: true,
          startSelectionPoint: SelectionPoint(
            localPosition: startOffset,
            lineHeight: fontSize,
            handleType: TextSelectionHandleType.left,
          ),
          endSelectionPoint: SelectionPoint(
            localPosition: endOffset,
            lineHeight: fontSize,
            handleType: TextSelectionHandleType.right,
          ),
        );
      }
    }

    if (oldGeometry != _selectionGeometry) {
      _notifyListeners();
    }
  }

  @override
  SelectedContent? getSelectedContent() {
    if (_selectionStart < 0 || _selectionEnd < 0) return null;
    if (_selectionStart == _selectionEnd) return null;

    final start = math.min(_selectionStart, _selectionEnd);
    final end = math.max(_selectionStart, _selectionEnd);
    final selectedText = _text.substring(start, end);

    return SelectedContent(plainText: selectedText);
  }

  @override
  void pushHandleLayers(LayerLink? startHandle, LayerLink? endHandle) {
    if (_startHandleLayerLink == startHandle && _endHandleLayerLink == endHandle) {
      return;
    }
    _startHandleLayerLink = startHandle;
    _endHandleLayerLink = endHandle;
    markNeedsPaint();
  }
}
