import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/tatechuyoko.dart';
import '../rendering/selectable_vertical_text_painter.dart';
import '../rendering/text_layouter.dart';

/// A widget for displaying selectable vertical Japanese text
///
/// Supports all features of VerticalText plus:
/// - Text selection by dragging
/// - Copy to clipboard with Ctrl+C
/// - Right-click context menu
/// - Double-click to select all
/// - Standard selection behavior
class SelectableVerticalText extends StatefulWidget {
  /// The text to display
  final String text;

  /// Style configuration for the text
  final VerticalTextStyle style;

  /// Maximum height for line breaking (0 = no limit)
  final double maxHeight;

  /// Whether to show a debug grid
  final bool showGrid;

  /// Ruby text annotations
  final List<RubyText> rubyList;

  /// Kenten (emphasis marks) annotations
  final List<Kenten> kentenList;

  /// Tatechuyoko (horizontal text in vertical) annotations
  final List<Tatechuyoko> tatechuyokoList;

  /// Selection color (if null, uses theme default)
  final Color? selectionColor;

  const SelectableVerticalText({
    super.key,
    required this.text,
    this.style = const VerticalTextStyle(),
    this.maxHeight = 0,
    this.showGrid = false,
    this.rubyList = const [],
    this.kentenList = const [],
    this.tatechuyokoList = const [],
    this.selectionColor,
  });

  @override
  State<SelectableVerticalText> createState() => _SelectableVerticalTextState();
}

enum _DragTarget { none, startHandle, endHandle, selection }

class _SelectableVerticalTextState extends State<SelectableVerticalText> {
  int? _selectionStart;
  int? _selectionEnd;
  List<CharacterLayout> _layouts = [];
  final FocusNode _focusNode = FocusNode();
  int _lastTapTime = 0;
  final GlobalKey _textKey = GlobalKey();
  _DragTarget _dragTarget = _DragTarget.none;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get selection color from theme if not specified
    final effectiveSelectionColor = widget.selectionColor ??
        Theme.of(context).textSelectionTheme.selectionColor ??
        const Color(0x6633B5E5);

    // Calculate the size needed for the text
    final layouter = TextLayouter();
    final layouts = layouter.layoutText(
      widget.text,
      widget.style,
      widget.maxHeight,
    );

    double maxX = 0.0;
    double maxY = 0.0;
    final fontSize = widget.style.baseStyle.fontSize ?? 16.0;

    for (final layout in layouts) {
      maxX = (layout.position.dx + fontSize).clamp(maxX, double.infinity);
      maxY = (layout.position.dy + fontSize).clamp(maxY, double.infinity);
    }

    // Add extra space for selection handles
    const handleExtraWidth = 12.0; // handleRadius * 2
    final size = Size(maxX + handleExtraWidth, maxY);

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Ctrl+C to copy
          if (event.logicalKey == LogicalKeyboardKey.keyC &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) {
            _copySelection();
            return KeyEventResult.handled;
          }
          // Ctrl+A to select all
          if (event.logicalKey == LogicalKeyboardKey.keyA &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) {
            _selectAll();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTapDown: (details) {
          _focusNode.requestFocus();
          _handleTap(details.localPosition);
        },
        onSecondaryTapDown: (details) {
          _focusNode.requestFocus();
          _handleSecondaryTap(details.localPosition, details.globalPosition);
        },
        onLongPressStart: (details) {
          _focusNode.requestFocus();
          _handleLongPress(details.localPosition, details.globalPosition);
        },
        onPanStart: (details) {
          _focusNode.requestFocus();
          _handlePanStart(details.localPosition);
        },
        onPanUpdate: (details) {
          _handlePanUpdate(details.localPosition);
        },
        onPanEnd: (details) {
          _handlePanEnd();
        },
        child: CustomPaint(
          key: _textKey,
          size: size,
          painter: SelectableVerticalTextPainter(
            text: widget.text,
            style: widget.style,
            maxHeight: widget.maxHeight,
            showGrid: widget.showGrid,
            rubyList: widget.rubyList,
            kentenList: widget.kentenList,
            tatechuyokoList: widget.tatechuyokoList,
            selectionStart: _selectionStart,
            selectionEnd: _selectionEnd,
            selectionColor: effectiveSelectionColor,
            handleColor: Theme.of(context).colorScheme.primary,
            showHandles: true,
            onLayoutsCalculated: (layouts) {
              _layouts = layouts;
            },
          ),
        ),
      ),
    );
  }

  void _handleTap(Offset localPosition) {
    // Check if tapping on a handle - if so, ignore the tap
    if (_selectionStart != null && _selectionEnd != null) {
      final handleTarget = _findHandleAt(localPosition);
      if (handleTarget != _DragTarget.none) {
        return; // Don't clear selection when tapping handle
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final isDoubleClick = now - _lastTapTime < 500;
    _lastTapTime = now;

    if (isDoubleClick) {
      // Double-click: select all
      _selectAll();
    } else {
      // Check if tapping on selected text
      if (_selectionStart != null && _selectionEnd != null) {
        final index = _findCharacterIndexAt(localPosition);
        if (index != null) {
          final start = _selectionStart! < _selectionEnd! ? _selectionStart! : _selectionEnd!;
          final end = _selectionStart! < _selectionEnd! ? _selectionEnd! : _selectionStart!;

          if (index >= start && index < end) {
            // Tapped on selection: show context menu
            _showContextMenuAtPosition(localPosition);
            return;
          }
        }
      }

      // Single click: clear selection
      setState(() {
        _selectionStart = null;
        _selectionEnd = null;
      });
    }
  }

  void _handleSecondaryTap(Offset localPosition, Offset globalPosition) {
    // Right-click: show context menu
    final index = _findCharacterIndexAt(localPosition);
    if (index != null && (_selectionStart == null || _selectionEnd == null)) {
      // If no selection, select the clicked character
      setState(() {
        _selectionStart = index;
        _selectionEnd = index + 1;
      });
    }
    _showContextMenu(globalPosition);
  }

  void _handleLongPress(Offset localPosition, Offset globalPosition) {
    // Long press (mobile): select word/character and show context menu
    final index = _findCharacterIndexAt(localPosition);
    if (index != null) {
      setState(() {
        _selectionStart = index;
        _selectionEnd = index + 1;
      });
    }
    if (_selectionStart != null && _selectionEnd != null) {
      _showContextMenu(globalPosition);
    }
  }

  void _handlePanStart(Offset position) {
    // Check if dragging a handle
    if (_selectionStart != null && _selectionEnd != null) {
      final handleTarget = _findHandleAt(position);
      if (handleTarget != _DragTarget.none) {
        _dragTarget = handleTarget;
        return;
      }
    }

    // Otherwise, start new selection
    _dragTarget = _DragTarget.selection;
    final index = _findCharacterIndexAt(position);
    if (index != null) {
      setState(() {
        _selectionStart = index;
        _selectionEnd = index;
      });
    }
  }

  void _handlePanUpdate(Offset position) {
    final int? foundIndex;

    // When dragging handles, find nearest character even if not directly over one
    if (_dragTarget == _DragTarget.startHandle || _dragTarget == _DragTarget.endHandle) {
      foundIndex = _findNearestCharacterIndexAt(position);
    } else {
      foundIndex = _findCharacterIndexAt(position);
    }

    if (foundIndex == null) return;

    final index = foundIndex; // Create non-nullable copy for type promotion

    setState(() {
      switch (_dragTarget) {
        case _DragTarget.startHandle:
          // Dragging start handle
          _selectionStart = index;
          break;
        case _DragTarget.endHandle:
          // Dragging end handle
          _selectionEnd = index + 1;
          break;
        case _DragTarget.selection:
          // Creating new selection
          if (_selectionStart != null) {
            _selectionEnd = index + 1;
          }
          break;
        case _DragTarget.none:
          break;
      }
    });
  }

  void _handlePanEnd() {
    // Show context menu only if we were creating a new selection (not dragging handles)
    if (_dragTarget == _DragTarget.selection &&
        _selectionStart != null &&
        _selectionEnd != null) {
      final start = _selectionStart! < _selectionEnd! ? _selectionStart! : _selectionEnd!;
      final end = _selectionStart! < _selectionEnd! ? _selectionEnd! : _selectionStart!;

      // Only show if there's an actual selection (not just a tap)
      if (end - start > 0) {
        // Find the position of the last selected character
        final lastLayout = _layouts.firstWhere(
          (layout) => layout.textIndex == end - 1,
          orElse: () => _layouts.last,
        );
        _showContextMenuAtPosition(lastLayout.position);
      }
    }

    _dragTarget = _DragTarget.none;
  }

  int? _findCharacterIndexAt(Offset position) {
    final fontSize = widget.style.baseStyle.fontSize ?? 16.0;

    for (int i = 0; i < _layouts.length; i++) {
      final layout = _layouts[i];
      final charRect = Rect.fromLTWH(
        layout.position.dx - fontSize / 2,
        layout.position.dy,
        fontSize,
        fontSize,
      );

      if (charRect.contains(position)) {
        return layout.textIndex;
      }
    }

    return null;
  }

  int? _findNearestCharacterIndexAt(Offset position) {
    if (_layouts.isEmpty) return null;

    double minDistance = double.infinity;
    int? nearestIndex;

    for (final layout in _layouts) {
      final charCenter = Offset(
        layout.position.dx,
        layout.position.dy,
      );
      final distance = (position - charCenter).distance;

      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = layout.textIndex;
      }
    }

    return nearestIndex;
  }

  _DragTarget _findHandleAt(Offset position) {
    if (_selectionStart == null || _selectionEnd == null) {
      return _DragTarget.none;
    }

    final start = _selectionStart! < _selectionEnd! ? _selectionStart! : _selectionEnd!;
    final end = _selectionStart! < _selectionEnd! ? _selectionEnd! : _selectionStart!;

    final fontSize = widget.style.baseStyle.fontSize ?? 16.0;
    const handleRadius = 6.0;
    const hitTestRadius = 24.0; // Larger touch target

    // Find start and end layouts
    CharacterLayout? startLayout;
    CharacterLayout? endLayout;

    for (final layout in _layouts) {
      if (layout.textIndex == start) {
        startLayout = layout;
      }
      if (layout.textIndex == end - 1) {
        endLayout = layout;
      }
    }

    // Check start handle
    if (startLayout != null) {
      final handleCenter = Offset(
        startLayout.position.dx - fontSize / 2 - handleRadius,
        startLayout.position.dy,
      );
      if ((position - handleCenter).distance <= hitTestRadius) {
        return _DragTarget.startHandle;
      }
    }

    // Check end handle
    if (endLayout != null) {
      final handleCenter = Offset(
        endLayout.position.dx - fontSize / 2 - handleRadius,
        endLayout.position.dy + fontSize,
      );
      if ((position - handleCenter).distance <= hitTestRadius) {
        return _DragTarget.endHandle;
      }
    }

    return _DragTarget.none;
  }

  void _selectAll() {
    setState(() {
      _selectionStart = 0;
      _selectionEnd = widget.text.length;
    });
  }

  void _copySelection() {
    if (_selectionStart == null || _selectionEnd == null) return;

    final start = _selectionStart! < _selectionEnd! ? _selectionStart! : _selectionEnd!;
    final end = _selectionStart! < _selectionEnd! ? _selectionEnd! : _selectionStart!;
    final selectedText = widget.text.substring(start, end);

    Clipboard.setData(ClipboardData(text: selectedText));
  }

  void _showContextMenuAtPosition(Offset localPosition) {
    // Convert local position to global position
    final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final globalPosition = renderBox.localToGlobal(localPosition);
    _showContextMenu(globalPosition);
  }

  void _showContextMenu(Offset globalPosition) {
    if (_selectionStart == null || _selectionEnd == null) return;

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.copy, size: 20),
              const SizedBox(width: 12),
              const Text('Copy'),
              const Spacer(),
              Text(
                'Ctrl+C',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            ],
          ),
          onTap: _copySelection,
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.select_all, size: 20),
              const SizedBox(width: 12),
              const Text('Select All'),
              const Spacer(),
              Text(
                'Ctrl+A',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            ],
          ),
          onTap: _selectAll,
        ),
      ],
    );
  }
}
