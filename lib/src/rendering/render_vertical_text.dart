import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/warichu.dart';
import '../models/tatechuyoko.dart';
import '../models/text_decoration.dart';
import '../models/vertical_text_span.dart';
import '../models/gaiji.dart';
import '../utils/kenten_renderer.dart';
import '../utils/warichu_renderer.dart';
import '../utils/decoration_renderer.dart';
import '../utils/tatechuyoko_detector.dart';
import '../utils/gaiji_renderer.dart';
import 'text_layouter.dart';

/// A RenderBox for vertical Japanese text layout and painting.
///
/// This RenderObject handles the layout and painting of vertical text,
/// including ruby annotations, kenten, warichu, tatechuyoko, decorations,
/// and gaiji (external character images).
class RenderVerticalText extends RenderBox {
  RenderVerticalText({
    String? text,
    VerticalTextSpan? span,
    required VerticalTextStyle style,
    List<RubyText>? ruby,
    List<Kenten>? kenten,
    List<Warichu>? warichu,
    List<Tatechuyoko>? tatechuyoko,
    List<TextDecorationAnnotation>? decorations,
    List<Gaiji>? gaiji,
    Map<int, ui.Image>? resolvedGaijiImages,
    bool autoTatechuyoko = false,
    double maxHeight = 0,
    bool showGrid = false,
  })  : _text = text,
        _span = span,
        _style = style,
        _ruby = ruby,
        _kenten = kenten,
        _warichu = warichu,
        _tatechuyoko = tatechuyoko,
        _decorations = decorations,
        _gaiji = gaiji,
        _resolvedGaijiImages = resolvedGaijiImages,
        _autoTatechuyoko = autoTatechuyoko,
        _maxHeight = maxHeight,
        _showGrid = showGrid,
        assert(text != null || span != null, 'Either text or span must be provided') {
    _processSpanIfNeeded();
  }

  // Layout results cached for paint phase
  List<CharacterLayout>? _characterLayouts;
  final TextLayouter _layouter = TextLayouter();
  double _layoutStartX = 0.0;

  // Computed values from span
  String _actualText = '';
  List<RubyText> _actualRuby = [];
  List<Kenten> _actualKenten = [];
  List<Warichu> _actualWarichu = [];
  List<Tatechuyoko> _actualTatechuyoko = [];
  List<TextDecorationAnnotation> _actualDecorations = [];
  List<Gaiji> _actualGaiji = [];

  // Properties
  String? _text;
  String? get text => _text;
  set text(String? value) {
    if (_text == value) return;
    _text = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  VerticalTextSpan? _span;
  VerticalTextSpan? get span => _span;
  set span(VerticalTextSpan? value) {
    if (_span == value) return;
    _span = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  VerticalTextStyle _style;
  VerticalTextStyle get style => _style;
  set style(VerticalTextStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsLayout();
  }

  List<RubyText>? _ruby;
  List<RubyText>? get ruby => _ruby;
  set ruby(List<RubyText>? value) {
    if (_ruby == value) return;
    _ruby = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  List<Kenten>? _kenten;
  List<Kenten>? get kenten => _kenten;
  set kenten(List<Kenten>? value) {
    if (_kenten == value) return;
    _kenten = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  List<Warichu>? _warichu;
  List<Warichu>? get warichu => _warichu;
  set warichu(List<Warichu>? value) {
    if (_warichu == value) return;
    _warichu = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  List<Tatechuyoko>? _tatechuyoko;
  List<Tatechuyoko>? get tatechuyoko => _tatechuyoko;
  set tatechuyoko(List<Tatechuyoko>? value) {
    if (_tatechuyoko == value) return;
    _tatechuyoko = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  List<TextDecorationAnnotation>? _decorations;
  List<TextDecorationAnnotation>? get decorations => _decorations;
  set decorations(List<TextDecorationAnnotation>? value) {
    if (_decorations == value) return;
    _decorations = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  List<Gaiji>? _gaiji;
  List<Gaiji>? get gaiji => _gaiji;
  set gaiji(List<Gaiji>? value) {
    if (_gaiji == value) return;
    _gaiji = value;
    _processSpanIfNeeded();
    markNeedsLayout();
  }

  Map<int, ui.Image>? _resolvedGaijiImages;
  Map<int, ui.Image>? get resolvedGaijiImages => _resolvedGaijiImages;
  set resolvedGaijiImages(Map<int, ui.Image>? value) {
    if (_resolvedGaijiImages == value) return;
    _resolvedGaijiImages = value;
    markNeedsPaint();
  }

  bool _autoTatechuyoko;
  bool get autoTatechuyoko => _autoTatechuyoko;
  set autoTatechuyoko(bool value) {
    if (_autoTatechuyoko == value) return;
    _autoTatechuyoko = value;
    markNeedsLayout();
  }

  double _maxHeight;
  double get maxHeight => _maxHeight;
  set maxHeight(double value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    markNeedsLayout();
  }

  bool _showGrid;
  bool get showGrid => _showGrid;
  set showGrid(bool value) {
    if (_showGrid == value) return;
    _showGrid = value;
    markNeedsPaint();
  }

  /// Process span to extract text and annotations
  void _processSpanIfNeeded() {
    if (_span != null) {
      _processSpan();
    } else {
      _actualText = _text ?? '';
      _actualRuby = _ruby ?? [];
      _actualKenten = _kenten ?? [];
      _actualWarichu = _warichu ?? [];
      _actualTatechuyoko = _tatechuyoko ?? [];
      _actualDecorations = _decorations ?? [];
      _actualGaiji = _gaiji ?? [];
    }
  }

  void _processSpan() {
    final rubyList = <RubyText>[];
    final kentenList = <Kenten>[];
    final warichuList = <Warichu>[];
    final tatechuyokoList = <Tatechuyoko>[];

    final plainText = _span!.toPlainText();

    int plainTextIndex = 0;
    _visitSpansForAnnotations(
      _span!,
      rubyList,
      kentenList,
      warichuList,
      tatechuyokoList,
      plainTextIndex,
    );

    _actualText = plainText;
    _actualRuby = rubyList;
    _actualKenten = kentenList;
    _actualWarichu = warichuList;
    _actualTatechuyoko = tatechuyokoList;
    _actualDecorations = [];
    _actualGaiji = _gaiji ?? [];
  }

  int _visitSpansForAnnotations(
    VerticalTextSpan currentSpan,
    List<RubyText> rubyList,
    List<Kenten> kentenList,
    List<Warichu> warichuList,
    List<Tatechuyoko> tatechuyokoList,
    int currentIndex,
  ) {
    int index = currentIndex;

    if (currentSpan is RubySpan) {
      rubyList.add(RubyText(
        startIndex: index,
        length: currentSpan.text!.length,
        ruby: currentSpan.ruby,
      ));
      index += currentSpan.text!.length;
    } else if (currentSpan is KentenSpan) {
      kentenList.add(Kenten(
        startIndex: index,
        length: currentSpan.text!.length,
        style: currentSpan.kentenStyle,
      ));
      index += currentSpan.text!.length;
    } else if (currentSpan is WarichuSpan) {
      warichuList.add(Warichu(
        startIndex: index,
        length: 0,
        text: currentSpan.text!,
        splitIndex: currentSpan.splitIndex,
      ));
    } else if (currentSpan is TatechuyokoSpan) {
      tatechuyokoList.add(Tatechuyoko(
        startIndex: index,
        length: currentSpan.text!.length,
      ));
      index += currentSpan.text!.length;
    } else if (currentSpan is TextSpanV) {
      if (currentSpan.text != null) {
        index += currentSpan.text!.length;
      }
    }

    if (currentSpan.children != null) {
      for (final child in currentSpan.children!) {
        index = _visitSpansForAnnotations(
          child,
          rubyList,
          kentenList,
          warichuList,
          tatechuyokoList,
          index,
        );
      }
    }

    return index;
  }

  /// Calculate annotation width for ruby/kenten if present
  double _calculateAnnotationWidth() {
    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    double annotationWidth = 0.0;

    if (_actualRuby.isNotEmpty) {
      final rubyFontSize = _style.rubyStyle?.fontSize ?? (fontSize * 0.5);
      annotationWidth = rubyFontSize + fontSize * 0.25;
    }

    if (_actualKenten.isNotEmpty) {
      annotationWidth = annotationWidth > 0
          ? annotationWidth + fontSize * 0.5
          : fontSize * 0.5;
    }

    return annotationWidth;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    return fontSize + _calculateAnnotationWidth();
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (_actualText.isEmpty) {
      return computeMinIntrinsicWidth(height);
    }

    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    final effectiveMaxHeight = height.isFinite ? height : _maxHeight;
    final startX = fontSize;
    final annotationWidth = _calculateAnnotationWidth();

    // Get tatechuyoko ranges
    List<Tatechuyoko> tatechuyokoRanges = _actualTatechuyoko;
    if (_autoTatechuyoko) {
      tatechuyokoRanges = TatechuyokoDetector.detectAuto(_actualText);
    }

    final tatechuyokoIndices = <int>{};
    for (final tcy in tatechuyokoRanges) {
      for (int i = tcy.startIndex; i < tcy.startIndex + tcy.length; i++) {
        tatechuyokoIndices.add(i);
      }
    }

    final warichuHeights = _calculateWarichuHeights(fontSize);

    return _layouter.calculateRequiredWidth(
      _actualText,
      _style,
      effectiveMaxHeight,
      startX: startX,
      tatechuyokoIndices: tatechuyokoIndices,
      warichuHeights: warichuHeights,
      annotationWidth: annotationWidth,
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    return fontSize;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (_actualText.isEmpty) {
      return computeMinIntrinsicHeight(width);
    }

    final fontSize = _style.baseStyle.fontSize ?? 16.0;

    // Calculate total text height without wrapping
    double totalHeight = 0.0;
    for (int i = 0; i < _actualText.length; i++) {
      final char = _actualText[i];
      if (char == '\n') {
        continue;
      }
      totalHeight += fontSize + _style.characterSpacing;
    }

    return totalHeight > 0 ? totalHeight : fontSize;
  }

  Map<int, double> _calculateWarichuHeights(double fontSize) {
    final warichuHeights = <int, double>{};
    for (final warichuItem in _actualWarichu) {
      final warichuFontSize = fontSize * 0.5;
      final maxLineLength = warichuItem.firstLine.length > warichuItem.secondLine.length
          ? warichuItem.firstLine.length
          : warichuItem.secondLine.length;
      final warichuHeight = maxLineLength * warichuFontSize + _style.characterSpacing * 2;

      if (warichuItem.length == 0 && warichuItem.startIndex > 0) {
        warichuHeights[warichuItem.startIndex - 1] = warichuHeight;
      } else if (warichuItem.length > 0) {
        final endIndex = warichuItem.startIndex + warichuItem.length - 1;
        warichuHeights[endIndex] = warichuHeight;
      }
    }
    return warichuHeights;
  }

  @override
  void performLayout() {
    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    final annotationWidth = _calculateAnnotationWidth();

    // Get tatechuyoko ranges
    List<Tatechuyoko> tatechuyokoRanges = _actualTatechuyoko;
    if (_autoTatechuyoko) {
      tatechuyokoRanges = TatechuyokoDetector.detectAuto(_actualText);
    }

    final tatechuyokoIndices = <int>{};
    for (final tcy in tatechuyokoRanges) {
      for (int i = tcy.startIndex; i < tcy.startIndex + tcy.length; i++) {
        tatechuyokoIndices.add(i);
      }
    }

    final warichuHeights = _calculateWarichuHeights(fontSize);

    // Determine the effective max height
    double effectiveMaxHeight = _maxHeight;
    if (effectiveMaxHeight <= 0 && constraints.maxHeight.isFinite) {
      effectiveMaxHeight = constraints.maxHeight;
    }

    // Calculate the start X position
    final startX = constraints.maxWidth.isFinite
        ? constraints.maxWidth - fontSize
        : fontSize * 10; // Default width for unconstrained
    _layoutStartX = startX;

    // Perform layout
    _characterLayouts = _layouter.layoutText(
      _actualText,
      _style,
      effectiveMaxHeight,
      startX: startX,
      tatechuyokoIndices: tatechuyokoIndices,
      warichuHeights: warichuHeights,
    );

    // Calculate actual size from layouts
    double calculatedWidth;
    double calculatedHeight;

    if (_characterLayouts!.isEmpty) {
      calculatedWidth = fontSize + annotationWidth;
      calculatedHeight = fontSize;
    } else {
      // Find min X from all character positions
      double minX = _characterLayouts!.first.position.dx;
      double maxY = 0.0;

      for (final layout in _characterLayouts!) {
        if (layout.position.dx < minX) {
          minX = layout.position.dx;
        }
        final layoutBottomY = layout.position.dy + layout.fontSize;
        if (layoutBottomY > maxY) {
          maxY = layoutBottomY;
        }
      }

      calculatedWidth = startX - minX + fontSize + annotationWidth;
      calculatedHeight = effectiveMaxHeight > 0 ? effectiveMaxHeight : maxY;
    }

    // Apply constraints
    size = constraints.constrain(Size(calculatedWidth, calculatedHeight));
  }

  // Reusable TextPainter instance to avoid repeated allocations
  static final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (_characterLayouts == null || _characterLayouts!.isEmpty) {
      canvas.restore();
      return;
    }

    final fontSize = _style.baseStyle.fontSize ?? 16.0;

    // Get tatechuyoko ranges
    List<Tatechuyoko> tatechuyokoRanges = _actualTatechuyoko;
    if (_autoTatechuyoko) {
      tatechuyokoRanges = TatechuyokoDetector.detectAuto(_actualText);
    }

    // Create set of indices that are part of tatechuyoko
    final tatechuyokoIndices = <int>{};
    for (final tcy in tatechuyokoRanges) {
      for (int i = tcy.startIndex; i < tcy.startIndex + tcy.length; i++) {
        tatechuyokoIndices.add(i);
      }
    }

    // Create set of indices that are replaced by gaiji
    final gaijiIndices = <int>{};
    for (final g in _actualGaiji) {
      for (int i = g.startIndex; i < g.endIndex; i++) {
        gaijiIndices.add(i);
      }
    }

    // Use the startX calculated during layout
    final startX = _layoutStartX;

    // Draw each character (skip tatechuyoko and gaiji characters)
    for (final layout in _characterLayouts!) {
      if (!tatechuyokoIndices.contains(layout.textIndex) &&
          !gaijiIndices.contains(layout.textIndex)) {
        _drawCharacter(canvas, layout);
      }
    }

    // Draw gaiji images if resolved
    if (_resolvedGaijiImages != null &&
        _resolvedGaijiImages!.isNotEmpty &&
        _actualGaiji.isNotEmpty) {
      final gaijiLayouts = _buildGaijiLayouts(_characterLayouts!, fontSize);
      if (gaijiLayouts.isNotEmpty) {
        GaijiRenderer.drawGaijiList(canvas, gaijiLayouts, fontSize);
      }
    }

    // Draw tatechuyoko
    for (final tcy in tatechuyokoRanges) {
      _drawTatechuyoko(canvas, tcy, _characterLayouts!);
    }

    // Draw ruby if present
    if (_actualRuby.isNotEmpty) {
      final rubyLayouts = _layouter.layoutRuby(
        _actualText,
        _actualRuby,
        _style,
        _characterLayouts!,
        _actualKenten.isNotEmpty ? _actualKenten : null,
        _actualDecorations.isNotEmpty ? _actualDecorations : null,
      );
      for (final rubyLayout in rubyLayouts) {
        _drawRuby(canvas, rubyLayout);
      }
    }

    // Draw kenten if present
    if (_actualKenten.isNotEmpty) {
      _drawKenten(canvas, _characterLayouts!);
    }

    // Draw decorations if present
    if (_actualDecorations.isNotEmpty) {
      _drawDecorations(canvas, _characterLayouts!);
    }

    // Draw warichu if present
    if (_actualWarichu.isNotEmpty) {
      _drawWarichu(canvas, _characterLayouts!, startX);
    }

    // Draw grid if enabled
    if (_showGrid) {
      _drawGrid(canvas, _characterLayouts!, size);
    }

    canvas.restore();
  }

  void _drawCharacter(Canvas canvas, CharacterLayout layout) {
    canvas.save();

    canvas.translate(layout.position.dx, layout.position.dy);

    _textPainter.text = TextSpan(
      text: layout.character,
      style: _style.baseStyle.copyWith(fontSize: layout.fontSize),
    );

    _textPainter.layout();

    double offsetX, offsetY;
    final fontSize = _style.baseStyle.fontSize ?? 16.0;

    if (layout.rotation != 0.0) {
      canvas.rotate(layout.rotation);
      offsetX = 0;
      offsetY = -_textPainter.height / 2;
    } else {
      offsetX = -(_textPainter.width / 2);
      offsetY = (fontSize - _textPainter.height) / 2;
    }

    _textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  void _drawRuby(Canvas canvas, RubyLayout layout) {
    final rubyFontSize = layout.fontSize;
    double currentY = layout.position.dy;

    for (int i = 0; i < layout.ruby.length; i++) {
      final char = layout.ruby[i];

      _textPainter.text = TextSpan(
        text: char,
        style: (_style.rubyStyle ?? _style.baseStyle).copyWith(
          fontSize: rubyFontSize,
        ),
      );

      _textPainter.layout();

      final offsetX = -(_textPainter.width / 2);
      _textPainter.paint(canvas, Offset(layout.position.dx + offsetX, currentY));

      currentY += _textPainter.height;
    }
  }

  void _drawKenten(Canvas canvas, List<CharacterLayout> characterLayouts) {
    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    final color = _style.baseStyle.color ?? const Color(0xFF000000);

    for (final kentenItem in _actualKenten) {
      for (int textIdx = kentenItem.startIndex; textIdx < kentenItem.endIndex; textIdx++) {
        CharacterLayout? charLayout;
        for (final layout in characterLayouts) {
          if (layout.textIndex == textIdx) {
            charLayout = layout;
            break;
          }
        }
        if (charLayout == null) continue;

        final kentenPos = KentenRenderer.getKentenPosition(
          charLayout.position,
          fontSize,
          true,
        );

        KentenRenderer.drawKenten(
          canvas,
          kentenPos,
          kentenItem.style,
          fontSize,
          color,
        );
      }
    }
  }

  void _drawDecorations(Canvas canvas, List<CharacterLayout> characterLayouts) {
    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    final defaultColor = _style.baseStyle.color ?? const Color(0xFF000000);

    for (final decoration in _actualDecorations) {
      CharacterLayout? firstLayout;
      CharacterLayout? lastLayout;

      for (final layout in characterLayouts) {
        if (layout.textIndex >= decoration.startIndex &&
            layout.textIndex < decoration.endIndex) {
          if (firstLayout == null || layout.textIndex < firstLayout.textIndex) {
            firstLayout = layout;
          }
          if (lastLayout == null || layout.textIndex > lastLayout.textIndex) {
            lastLayout = layout;
          }
        }
      }

      if (firstLayout == null || lastLayout == null) continue;

      final startPosition = firstLayout.position;
      final endY = lastLayout.position.dy + fontSize;

      DecorationRenderer.drawDecoration(
        canvas,
        startPosition,
        endY,
        decoration.type,
        fontSize,
        decoration.color ?? defaultColor,
        thickness: decoration.thickness,
      );
    }
  }

  void _drawWarichu(Canvas canvas, List<CharacterLayout> characterLayouts, double lineX) {
    final fontSize = _style.baseStyle.fontSize ?? 16.0;

    for (final warichuItem in _actualWarichu) {
      CharacterLayout? insertLayout;

      if (warichuItem.length == 0) {
        if (warichuItem.startIndex > 0) {
          for (final layout in characterLayouts) {
            if (layout.textIndex == warichuItem.startIndex - 1) {
              insertLayout = layout;
              break;
            }
          }
        }
      } else {
        final endIndex = warichuItem.startIndex + warichuItem.length - 1;
        for (final layout in characterLayouts) {
          if (layout.textIndex == endIndex) {
            insertLayout = layout;
            break;
          }
        }
      }
      if (insertLayout == null) continue;

      final warichuStartY = insertLayout.position.dy + fontSize + _style.characterSpacing;
      final warichuPosition = Offset(lineX, warichuStartY);

      WarichuRenderer.drawWarichu(
        canvas,
        warichuPosition,
        warichuItem,
        _style.baseStyle,
        fontSize,
        _style.characterSpacing,
      );
    }
  }

  void _drawTatechuyoko(
    Canvas canvas,
    Tatechuyoko tcy,
    List<CharacterLayout> characterLayouts,
  ) {
    if (tcy.startIndex >= _actualText.length) return;

    final endIndex = (tcy.startIndex + tcy.length).clamp(0, _actualText.length);
    final tcyText = _actualText.substring(tcy.startIndex, endIndex);

    CharacterLayout? baseLayout;
    for (final layout in characterLayouts) {
      if (layout.textIndex == tcy.startIndex) {
        baseLayout = layout;
        break;
      }
    }
    if (baseLayout == null) return;

    final fontSize = _style.baseStyle.fontSize ?? 16.0;
    final tcyLayout = TatechuyokoDetector.layoutTatechuyoko(
      tcyText,
      baseLayout.position,
      fontSize,
    );

    canvas.save();

    canvas.translate(tcyLayout.position.dx, tcyLayout.position.dy);

    final textPainter = TextPainter(
      text: TextSpan(
        text: tcyText,
        style: _style.baseStyle.copyWith(fontSize: tcyLayout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offsetX = -(textPainter.width / 2);
    final offsetY = (fontSize - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  List<GaijiLayout> _buildGaijiLayouts(
    List<CharacterLayout> characterLayouts,
    double fontSize,
  ) {
    final layouts = <GaijiLayout>[];

    for (int i = 0; i < _actualGaiji.length; i++) {
      final gaijiDef = _actualGaiji[i];
      final image = _resolvedGaijiImages![i];
      if (image == null) continue;

      CharacterLayout? charLayout;
      for (final layout in characterLayouts) {
        if (layout.textIndex == gaijiDef.startIndex) {
          charLayout = layout;
          break;
        }
      }

      if (charLayout != null) {
        layouts.add(GaijiLayout(
          position: charLayout.position,
          width: gaijiDef.width ?? fontSize,
          height: gaijiDef.height ?? fontSize,
          image: image,
          textIndex: gaijiDef.startIndex,
        ));
      }
    }

    return layouts;
  }

  void _drawGrid(Canvas canvas, List<CharacterLayout> characterLayouts, Size size) {
    final baseFontSize = _style.baseStyle.fontSize ?? 16.0;

    final characterPaint = Paint()
      ..color = const Color(0x4D2196F3) // Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final spacingPaint = Paint()
      ..color = const Color(0x33FF9800) // Colors.orange.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerLinePaint = Paint()
      ..color = const Color(0x4DF44336) // Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < characterLayouts.length; i++) {
      final charLayout = characterLayouts[i];
      final x = charLayout.position.dx;
      final y = charLayout.position.dy;

      final cellWidth = baseFontSize;
      final cellHeight = baseFontSize;

      final characterRect = Rect.fromLTWH(
        x - cellWidth / 2,
        y,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(characterRect, characterPaint);

      final cellCenterY = y + cellHeight / 2;
      canvas.drawLine(
        Offset(x - cellWidth / 2, cellCenterY),
        Offset(x + cellWidth / 2, cellCenterY),
        centerLinePaint,
      );

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + cellHeight),
        centerLinePaint,
      );

      if (i < characterLayouts.length - 1) {
        final spacingHeight = _style.characterSpacing;

        if (spacingHeight > 0) {
          final spacingRect = Rect.fromLTWH(
            x - cellWidth / 2,
            y + cellHeight,
            cellWidth,
            spacingHeight,
          );
          canvas.drawRect(spacingRect, spacingPaint);
        }
      }
    }
  }
}
