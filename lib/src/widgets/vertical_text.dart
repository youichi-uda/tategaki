import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../models/kenten.dart';
import '../models/tatechuyoko.dart';
import '../models/warichu.dart';
import '../models/text_decoration.dart';
import '../models/vertical_text_span.dart';
import '../models/gaiji.dart';
import '../rendering/vertical_text_painter.dart';
import '../rendering/text_layouter.dart';
import '../utils/tatechuyoko_detector.dart';

/// A widget that displays vertical Japanese text (tategaki)
class VerticalText extends StatefulWidget {
  /// The text to display vertically
  final String? text;

  /// Span-based text composition (alternative to plain text)
  final VerticalTextSpan? span;

  /// Style configuration for the vertical text
  final VerticalTextStyle style;

  /// Ruby (furigana) annotations (used with plain text)
  final List<RubyText>? ruby;

  /// Kenten (emphasis dots) annotations (used with plain text)
  final List<Kenten>? kenten;

  /// Warichu (inline annotations) annotations (used with plain text)
  final List<Warichu>? warichu;

  /// Tatechuyoko (horizontal text within vertical) annotations (used with plain text)
  final List<Tatechuyoko>? tatechuyoko;

  /// Text decorations (傍線など) annotations (used with plain text)
  final List<TextDecorationAnnotation>? decorations;

  /// Gaiji (外字) image-based custom characters
  final List<Gaiji>? gaiji;

  /// Auto-detect and apply tatechuyoko to 2-digit numbers
  final bool autoTatechuyoko;

  /// Maximum height for text before wrapping to next line
  ///
  /// If 0 or not specified, text will not wrap
  final double maxHeight;

  /// Show grid overlay for debugging character positions
  final bool showGrid;

  const VerticalText(
    this.text, {
    super.key,
    this.style = const VerticalTextStyle(),
    this.ruby,
    this.kenten,
    this.warichu,
    this.tatechuyoko,
    this.decorations,
    this.gaiji,
    this.autoTatechuyoko = false,
    this.maxHeight = 0,
    this.showGrid = false,
  })  : span = null,
        assert(text != null, 'text must not be null');

  /// Creates a vertical text widget with rich text composition
  const VerticalText.rich(
    this.span, {
    super.key,
    this.style = const VerticalTextStyle(),
    this.gaiji,
    this.autoTatechuyoko = false,
    this.maxHeight = 0,
    this.showGrid = false,
  })  : text = null,
        ruby = null,
        kenten = null,
        warichu = null,
        tatechuyoko = null,
        decorations = null,
        assert(span != null, 'span must not be null');

  @override
  State<VerticalText> createState() => _VerticalTextState();
}

class _VerticalTextState extends State<VerticalText> {
  /// Resolved gaiji images
  final Map<int, ui.Image> _resolvedImages = {};

  /// Image streams for gaiji
  final Map<int, ImageStream> _imageStreams = {};

  /// Image stream listeners for proper disposal
  final Map<int, ImageStreamListener> _imageStreamListeners = {};

  /// Text layouter for size calculation
  final TextLayouter _layouter = TextLayouter();

  @override
  void initState() {
    super.initState();
    _resolveGaijiImages();
  }

  @override
  void didUpdateWidget(VerticalText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gaiji != oldWidget.gaiji) {
      _disposeImageStreams();
      _resolvedImages.clear();
      _resolveGaijiImages();
    }
  }

  @override
  void dispose() {
    _disposeImageStreams();
    super.dispose();
  }

  void _disposeImageStreams() {
    for (final entry in _imageStreams.entries) {
      final listener = _imageStreamListeners[entry.key];
      if (listener != null) {
        entry.value.removeListener(listener);
      }
    }
    _imageStreams.clear();
    _imageStreamListeners.clear();
  }

  void _resolveGaijiImages() {
    if (widget.gaiji == null || widget.gaiji!.isEmpty) return;

    for (int i = 0; i < widget.gaiji!.length; i++) {
      final gaiji = widget.gaiji![i];
      final stream = gaiji.image.resolve(ImageConfiguration.empty);
      _imageStreams[i] = stream;

      final listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _resolvedImages[i] = info.image;
            });
          }
        },
        onError: (exception, stackTrace) {
          // Log gaiji image loading error for debugging
          debugPrint('Gaiji image loading failed at index $i: $exception');
        },
      );
      _imageStreamListeners[i] = listener;
      stream.addListener(listener);
    }
  }

  Map<int, ui.Image>? _getResolvedImages() {
    if (widget.gaiji == null || widget.gaiji!.isEmpty) return null;
    if (_resolvedImages.isEmpty) return null;
    return _resolvedImages;
  }

  @override
  Widget build(BuildContext context) {
    // Get default text color from theme if not specified
    final defaultColor = widget.style.baseStyle.color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        const Color(0xFF000000);

    // Merge default color with user style
    final effectiveStyle = widget.style.copyWith(
      baseStyle: widget.style.baseStyle.copyWith(color: defaultColor),
    );

    return CustomPaint(
      painter: VerticalTextPainter(
        text: widget.text,
        span: widget.span,
        style: effectiveStyle,
        ruby: widget.ruby,
        kenten: widget.kenten,
        warichu: widget.warichu,
        tatechuyoko: widget.tatechuyoko,
        decorations: widget.decorations,
        gaiji: widget.gaiji,
        resolvedGaijiImages: _getResolvedImages(),
        autoTatechuyoko: widget.autoTatechuyoko,
        maxHeight: widget.maxHeight,
        showGrid: widget.showGrid,
      ),
      size: _calculateSize(effectiveStyle),
    );
  }

  Size _calculateSize(VerticalTextStyle effectiveStyle) {
    final fontSize = effectiveStyle.baseStyle.fontSize ?? 16.0;

    // Get actual text
    final actualText = widget.span != null ? widget.span!.toPlainText() : widget.text!;

    if (actualText.isEmpty) {
      return Size(fontSize, fontSize);
    }

    // Calculate height
    double height;
    if (widget.maxHeight > 0) {
      height = widget.maxHeight;
    } else {
      // Calculate total text height without wrapping
      double totalHeight = 0.0;
      for (int i = 0; i < actualText.length; i++) {
        final char = actualText[i];
        if (char != '\n') {
          totalHeight += fontSize + effectiveStyle.characterSpacing;
        }
      }
      height = totalHeight > 0 ? totalHeight : fontSize;
    }

    // Calculate annotation width for ruby/kenten
    double annotationWidth = 0.0;

    final actualRuby = widget.ruby ?? [];
    final actualKenten = widget.kenten ?? [];

    if (actualRuby.isNotEmpty) {
      final rubyFontSize = effectiveStyle.rubyStyle?.fontSize ?? (fontSize * 0.5);
      annotationWidth = rubyFontSize + fontSize * 0.25;
    }

    if (actualKenten.isNotEmpty) {
      annotationWidth = annotationWidth > 0
          ? annotationWidth + fontSize * 0.5
          : fontSize * 0.5;
    }

    // Get tatechuyoko ranges
    List<Tatechuyoko> tatechuyokoRanges = widget.tatechuyoko ?? [];
    if (widget.autoTatechuyoko) {
      tatechuyokoRanges = TatechuyokoDetector.detectAuto(actualText);
    }

    final tatechuyokoIndices = <int>{};
    for (final tcy in tatechuyokoRanges) {
      for (int i = tcy.startIndex; i < tcy.startIndex + tcy.length; i++) {
        tatechuyokoIndices.add(i);
      }
    }

    // Calculate warichu heights
    final warichuHeights = <int, double>{};
    final actualWarichu = widget.warichu ?? [];
    for (final warichuItem in actualWarichu) {
      final warichuFontSize = fontSize * 0.5;
      final maxLineLength = warichuItem.firstLine.length > warichuItem.secondLine.length
          ? warichuItem.firstLine.length
          : warichuItem.secondLine.length;
      final warichuHeight = maxLineLength * warichuFontSize + effectiveStyle.characterSpacing * 2;

      if (warichuItem.length == 0 && warichuItem.startIndex > 0) {
        warichuHeights[warichuItem.startIndex - 1] = warichuHeight;
      } else if (warichuItem.length > 0) {
        final endIndex = warichuItem.startIndex + warichuItem.length - 1;
        warichuHeights[endIndex] = warichuHeight;
      }
    }

    // Use TextLayouter to calculate accurate width
    final width = _layouter.calculateRequiredWidth(
      actualText,
      effectiveStyle,
      widget.maxHeight > 0 ? widget.maxHeight : height,
      startX: fontSize, // Start from right edge (will be adjusted in painter)
      tatechuyokoIndices: tatechuyokoIndices,
      warichuHeights: warichuHeights,
      annotationWidth: annotationWidth,
    );

    return Size(width, height);
  }
}
