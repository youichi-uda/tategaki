import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
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

/// Custom painter for vertical text
class VerticalTextPainter extends CustomPainter {
  final String? text;
  final VerticalTextSpan? span;
  final VerticalTextStyle style;
  final List<RubyText>? ruby;
  final List<Kenten>? kenten;
  final List<Warichu>? warichu;
  final List<Tatechuyoko>? tatechuyoko;
  final List<TextDecorationAnnotation>? decorations;
  final List<Gaiji>? gaiji;
  final Map<int, ui.Image>? resolvedGaijiImages;
  final bool autoTatechuyoko;
  final TextLayouter layouter;
  final double maxHeight;
  final bool showGrid;

  // Computed values from span
  late final String _actualText;
  late final List<RubyText> _actualRuby;
  late final List<Kenten> _actualKenten;
  late final List<Warichu> _actualWarichu;
  late final List<Tatechuyoko> _actualTatechuyoko;
  late final List<TextDecorationAnnotation> _actualDecorations;
  late final List<Gaiji> _actualGaiji;

  VerticalTextPainter({
    this.text,
    this.span,
    required this.style,
    this.ruby,
    this.kenten,
    this.warichu,
    this.tatechuyoko,
    this.decorations,
    this.gaiji,
    this.resolvedGaijiImages,
    this.autoTatechuyoko = false,
    TextLayouter? layouter,
    this.maxHeight = 0,
    this.showGrid = false,
  })  : layouter = layouter ?? TextLayouter(),
        assert(text != null || span != null, 'Either text or span must be provided') {
    // Process span if provided
    if (span != null) {
      _processSpan();
    } else {
      _actualText = text!;
      _actualRuby = ruby ?? [];
      _actualKenten = kenten ?? [];
      _actualWarichu = warichu ?? [];
      _actualTatechuyoko = tatechuyoko ?? [];
      _actualDecorations = decorations ?? [];
      _actualGaiji = gaiji ?? [];
    }
  }

  void _processSpan() {
    // Convert span structure to flat text with annotations
    final rubyList = <RubyText>[];
    final kentenList = <Kenten>[];
    final warichuList = <Warichu>[];
    final tatechuyokoList = <Tatechuyoko>[];

    // Build plain text first to get proper indices
    final plainText = span!.toPlainText();

    // Now visit spans to collect annotations
    // For WarichuSpan, we need to track where it appears in the span tree
    // and map that to the position in plain text
    int plainTextIndex = 0;
    _visitSpansForAnnotations(
      span!,
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
    _actualDecorations = []; // TODO: Add DecorationSpan support in the future
    _actualGaiji = gaiji ?? []; // TODO: Add GaijiSpan support in the future
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
      // Warichu is inserted at current position in plain text
      warichuList.add(Warichu(
        startIndex: index,
        length: 0, // Warichu doesn't replace text in new design
        text: currentSpan.text!,
        splitIndex: currentSpan.splitIndex,
      ));
      // Don't advance index - warichu text is not in plain text
    } else if (currentSpan is TatechuyokoSpan) {
      tatechuyokoList.add(Tatechuyoko(
        startIndex: index,
        length: currentSpan.text!.length,
      ));
      index += currentSpan.text!.length;
    } else if (currentSpan is TextSpanV) {
      // Plain text span
      if (currentSpan.text != null) {
        index += currentSpan.text!.length;
      }
    }

    // Process children
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

  @override
  void paint(Canvas canvas, Size size) {
    // Get tatechuyoko ranges
    List<Tatechuyoko> tatechuyokoRanges = _actualTatechuyoko;
    if (autoTatechuyoko) {
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

    // Calculate starting X position (right edge minus one character width)
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final startX = size.width - fontSize;

    // Calculate warichu heights
    final warichuHeights = <int, double>{};
    for (final warichuItem in _actualWarichu) {
      final warichuFontSize = fontSize * 0.5;
      final maxLineLength = warichuItem.firstLine.length > warichuItem.secondLine.length
          ? warichuItem.firstLine.length
          : warichuItem.secondLine.length;
      // Add extra spacing after warichu to separate it from next character
      final warichuHeight = maxLineLength * warichuFontSize + style.characterSpacing * 2;

      // For WarichuSpan (length=0), the warichu is inserted AFTER the character at startIndex-1
      // So we need to add the height after that character
      if (warichuItem.length == 0 && warichuItem.startIndex > 0) {
        warichuHeights[warichuItem.startIndex - 1] = warichuHeight;
      } else if (warichuItem.length > 0) {
        // Old API: warichu replaces characters
        final endIndex = warichuItem.startIndex + warichuItem.length - 1;
        warichuHeights[endIndex] = warichuHeight;
      }
    }

    // Layout the text (pass tatechuyoko indices and warichu heights)
    final characterLayouts = layouter.layoutText(
      _actualText,
      style,
      maxHeight,
      startX: startX,
      tatechuyokoIndices: tatechuyokoIndices,
      warichuHeights: warichuHeights,
    );

    // Draw each character (skip tatechuyoko and gaiji characters)
    for (final layout in characterLayouts) {
      if (!tatechuyokoIndices.contains(layout.textIndex) &&
          !gaijiIndices.contains(layout.textIndex)) {
        _drawCharacter(canvas, layout);
      }
    }

    // Draw gaiji images if resolved
    if (resolvedGaijiImages != null && resolvedGaijiImages!.isNotEmpty && _actualGaiji.isNotEmpty) {
      final gaijiLayouts = _buildGaijiLayouts(characterLayouts, fontSize);
      if (gaijiLayouts.isNotEmpty) {
        GaijiRenderer.drawGaijiList(canvas, gaijiLayouts, fontSize);
      }
    }

    // Draw tatechuyoko
    for (final tcy in tatechuyokoRanges) {
      _drawTatechuyoko(canvas, tcy, characterLayouts);
    }

    // Draw ruby if present
    if (_actualRuby.isNotEmpty) {
      final rubyLayouts = layouter.layoutRuby(
        _actualText,
        _actualRuby,
        style,
        characterLayouts,
        _actualKenten.isNotEmpty ? _actualKenten : null,
        _actualDecorations.isNotEmpty ? _actualDecorations : null,
      );
      for (final rubyLayout in rubyLayouts) {
        _drawRuby(canvas, rubyLayout);
      }
    }

    // Draw kenten if present
    if (_actualKenten.isNotEmpty) {
      _drawKenten(canvas, characterLayouts);
    }

    // Draw decorations (傍線など) if present
    if (_actualDecorations.isNotEmpty) {
      _drawDecorations(canvas, characterLayouts);
    }

    // Draw warichu if present
    if (_actualWarichu.isNotEmpty) {
      _drawWarichu(canvas, characterLayouts, startX);
    }

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, characterLayouts, size);
    }
  }

  void _drawGrid(Canvas canvas, List<CharacterLayout> characterLayouts, Size size) {
    final baseFontSize = style.baseStyle.fontSize ?? 16.0;

    final characterPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final spacingPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerLinePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < characterLayouts.length; i++) {
      final charLayout = characterLayouts[i];
      final x = charLayout.position.dx;
      final y = charLayout.position.dy;

      // Use fontSize as the cell size (virtual body)
      // This is consistent for all characters regardless of actual glyph size
      final cellWidth = baseFontSize;
      final cellHeight = baseFontSize;

      // Draw character cell (fontSize × fontSize square)
      final characterRect = Rect.fromLTWH(
        x - cellWidth / 2,
        y,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(characterRect, characterPaint);

      // Draw horizontal center line (at cell center)
      final cellCenterY = y + cellHeight / 2;
      canvas.drawLine(
        Offset(x - cellWidth / 2, cellCenterY),
        Offset(x + cellWidth / 2, cellCenterY),
        centerLinePaint,
      );

      // Draw vertical center line for character cell
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + cellHeight),
        centerLinePaint,
      );

      // Draw spacing area (characterSpacing) if not the last character
      if (i < characterLayouts.length - 1) {
        final spacingHeight = style.characterSpacing;

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

  // Reusable TextPainter instance to avoid repeated allocations
  static final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  void _drawCharacter(Canvas canvas, CharacterLayout layout) {
    canvas.save();

    // Move to character position
    canvas.translate(layout.position.dx, layout.position.dy);

    // Reuse text painter
    _textPainter.text = TextSpan(
      text: layout.character,
      style: style.baseStyle.copyWith(fontSize: layout.fontSize),
    );

    _textPainter.layout();

    // Calculate offset based on rotation
    double offsetX, offsetY;

    // Get the virtual cell size (fontSize)
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    if (layout.rotation != 0.0) {
      // For rotated characters (90 degrees clockwise)
      // Rotate first
      canvas.rotate(layout.rotation);

      // In the rotated coordinate system, apply positioning within virtual cell:
      offsetX = 0;
      // Vertical positioning - use text height / 2 to center at position.dx
      offsetY = -_textPainter.height / 2;
    } else {
      // For non-rotated characters
      // Center horizontally (X axis) within the virtual cell
      offsetX = -(_textPainter.width / 2);
      // Center vertically (Y axis) within the virtual cell (fontSize)
      offsetY = (fontSize - _textPainter.height) / 2;
    }

    // Draw the character
    _textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  void _drawRuby(Canvas canvas, RubyLayout layout) {
    // Draw ruby characters vertically one by one
    final rubyFontSize = layout.fontSize;
    double currentY = layout.position.dy;

    for (int i = 0; i < layout.ruby.length; i++) {
      final char = layout.ruby[i];

      _textPainter.text = TextSpan(
        text: char,
        style: (style.rubyStyle ?? style.baseStyle).copyWith(
          fontSize: rubyFontSize,
        ),
      );

      _textPainter.layout();

      // Center the character horizontally
      final offsetX = -(_textPainter.width / 2);
      _textPainter.paint(canvas, Offset(layout.position.dx + offsetX, currentY));

      // Move to next character position (vertically)
      // Use actual text height instead of fontSize
      currentY += _textPainter.height;
    }
  }

  void _drawKenten(Canvas canvas, List<CharacterLayout> characterLayouts) {
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final color = style.baseStyle.color ?? Colors.black;

    for (final kentenItem in _actualKenten) {
      for (int textIdx = kentenItem.startIndex; textIdx < kentenItem.endIndex; textIdx++) {
        // Find the layout for this text index
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
          true, // isVertical
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
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final defaultColor = style.baseStyle.color ?? Colors.black;

    for (final decoration in _actualDecorations) {
      // Find the first and last character layouts in the decoration range
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

      // Calculate the start and end positions
      final startPosition = firstLayout.position;
      final endY = lastLayout.position.dy + fontSize;

      // Draw the decoration
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
    final fontSize = style.baseStyle.fontSize ?? 16.0;

    for (final warichuItem in _actualWarichu) {
      // For WarichuSpan (length=0), find the character at startIndex
      // The warichu is inserted AFTER this character
      CharacterLayout? insertLayout;

      if (warichuItem.length == 0) {
        // New span-based API: warichu is inserted at this position
        // Find the character just before the insertion point
        if (warichuItem.startIndex > 0) {
          for (final layout in characterLayouts) {
            if (layout.textIndex == warichuItem.startIndex - 1) {
              insertLayout = layout;
              break;
            }
          }
        }
      } else {
        // Old API: warichu replaces characters
        final endIndex = warichuItem.startIndex + warichuItem.length - 1;
        for (final layout in characterLayouts) {
          if (layout.textIndex == endIndex) {
            insertLayout = layout;
            break;
          }
        }
      }
      if (insertLayout == null) continue;

      // Calculate position for warichu (after the character)
      // Use lineX instead of insertLayout.position.dx to ignore yakumono adjustment
      final warichuStartY = insertLayout.position.dy + fontSize + style.characterSpacing;
      final warichuPosition = Offset(lineX, warichuStartY);

      // Draw the warichu annotation
      WarichuRenderer.drawWarichu(
        canvas,
        warichuPosition,
        warichuItem,
        style.baseStyle,
        fontSize,
        style.characterSpacing,
      );
    }
  }

  void _drawTatechuyoko(
    Canvas canvas,
    Tatechuyoko tcy,
    List<CharacterLayout> characterLayouts,
  ) {
    if (tcy.startIndex >= _actualText.length) return;

    // Extract tatechuyoko text
    final endIndex = (tcy.startIndex + tcy.length).clamp(0, _actualText.length);
    final tcyText = _actualText.substring(tcy.startIndex, endIndex);

    // Find the layout for the first character of this tatechuyoko range
    CharacterLayout? baseLayout;
    for (final layout in characterLayouts) {
      if (layout.textIndex == tcy.startIndex) {
        baseLayout = layout;
        break;
      }
    }
    if (baseLayout == null) return;

    // Calculate tatechuyoko layout
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    final tcyLayout = TatechuyokoDetector.layoutTatechuyoko(
      tcyText,
      baseLayout.position,
      fontSize,
    );

    canvas.save();

    // Move to the character position
    canvas.translate(tcyLayout.position.dx, tcyLayout.position.dy);

    // Draw tatechuyoko text horizontally (no rotation)
    final textPainter = TextPainter(
      text: TextSpan(
        text: tcyText,
        style: style.baseStyle.copyWith(fontSize: tcyLayout.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Center the tatechuyoko text both horizontally and vertically in the character cell
    // (Same pattern as non-rotated characters)
    // Horizontal: center at the character position
    final offsetX = -(textPainter.width / 2);
    // Vertical: center within the fontSize-based virtual cell
    final offsetY = (fontSize - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(offsetX, offsetY));

    canvas.restore();
  }

  /// Build gaiji layouts from character layouts and resolved images
  List<GaijiLayout> _buildGaijiLayouts(
    List<CharacterLayout> characterLayouts,
    double fontSize,
  ) {
    final layouts = <GaijiLayout>[];

    for (int i = 0; i < _actualGaiji.length; i++) {
      final gaijiDef = _actualGaiji[i];
      final image = resolvedGaijiImages![i];
      if (image == null) continue;

      // Find the character layout at the gaiji position
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

  @override
  bool shouldRepaint(covariant VerticalTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.span != span ||
        oldDelegate.style != style ||
        !listEquals(oldDelegate.ruby, ruby) ||
        !listEquals(oldDelegate.kenten, kenten) ||
        !listEquals(oldDelegate.warichu, warichu) ||
        !listEquals(oldDelegate.tatechuyoko, tatechuyoko) ||
        !listEquals(oldDelegate.decorations, decorations) ||
        !listEquals(oldDelegate.gaiji, gaiji) ||
        oldDelegate.resolvedGaijiImages != resolvedGaijiImages ||
        oldDelegate.autoTatechuyoko != autoTatechuyoko ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.showGrid != showGrid;
  }
}
