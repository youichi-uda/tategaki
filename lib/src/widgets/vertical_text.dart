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
  ///
  /// This constructor uses a span-based API similar to Flutter's Text.rich()
  /// which makes it easier to compose text with different styles and annotations.
  ///
  /// Example:
  /// ```dart
  /// VerticalText.rich(
  ///   TextSpanV(
  ///     children: [
  ///       RubySpan(text: '東京', ruby: 'とうきょう'),
  ///       TextSpanV(text: 'と'),
  ///       RubySpan(text: '大阪', ruby: 'おおさか'),
  ///       TextSpanV(text: 'は日本の大都市である。'),
  ///     ],
  ///   ),
  /// )
  /// ```
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
          // Handle image loading error silently
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
    final numChars = widget.span != null ? widget.span!.textLength : widget.text!.length;

    // Calculate height (vertical extent in vertical text)
    double height = numChars * (fontSize + effectiveStyle.characterSpacing);

    // Calculate width (horizontal extent in vertical text)
    // Base width is one character width
    double width = fontSize;

    // Add space for ruby text if present
    if (widget.ruby != null && widget.ruby!.isNotEmpty) {
      final rubyFontSize = effectiveStyle.rubyStyle?.fontSize ?? (fontSize * 0.5);
      width += rubyFontSize + fontSize * 0.2; // Ruby size + margin
    }

    // Add space for kenten if present
    if (widget.kenten != null && widget.kenten!.isNotEmpty) {
      width += fontSize * 0.5; // Extra space for kenten on the right
    }

    // Add space for warichu if present
    if (widget.warichu != null && widget.warichu!.isNotEmpty) {
      // Warichu doesn't extend beyond main text width
      // No extra space needed
    }

    // Handle wrapping
    if (widget.maxHeight > 0 && height > widget.maxHeight) {
      final linesNeeded = (height / widget.maxHeight).ceil();
      height = widget.maxHeight;

      // Width for multiple lines
      double lineWidth = fontSize;
      if (widget.ruby != null && widget.ruby!.isNotEmpty) {
        final rubyFontSize = effectiveStyle.rubyStyle?.fontSize ?? (fontSize * 0.5);
        lineWidth += rubyFontSize + fontSize * 0.2;
      }
      if (widget.kenten != null && widget.kenten!.isNotEmpty) {
        lineWidth += fontSize * 0.5;
      }
      // Warichu doesn't extend beyond main text width

      width = lineWidth * linesNeeded + effectiveStyle.lineSpacing * (linesNeeded - 1);
    }

    return Size(width, height);
  }
}
