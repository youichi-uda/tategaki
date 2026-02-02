import 'dart:collection';
import 'package:flutter/material.dart';
import '../rendering/text_layouter.dart';
import '../models/vertical_text_style.dart';

/// Cache key for layout results
class LayoutCacheKey {
  final String text;
  final VerticalTextStyle style;
  final double maxHeight;

  const LayoutCacheKey({
    required this.text,
    required this.style,
    required this.maxHeight,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayoutCacheKey &&
        other.text == text &&
        _stylesEqual(other.style, style) &&
        other.maxHeight == maxHeight;
  }

  @override
  int get hashCode => Object.hash(
        text,
        _styleHashCode(style),
        maxHeight,
      );

  /// Compare two VerticalTextStyle instances for equality
  bool _stylesEqual(VerticalTextStyle a, VerticalTextStyle b) {
    return a.baseStyle.fontSize == b.baseStyle.fontSize &&
        a.baseStyle.color == b.baseStyle.color &&
        a.baseStyle.fontFamily == b.baseStyle.fontFamily &&
        a.baseStyle.fontWeight == b.baseStyle.fontWeight &&
        a.baseStyle.fontStyle == b.baseStyle.fontStyle &&
        a.baseStyle.height == b.baseStyle.height &&
        a.lineSpacing == b.lineSpacing &&
        a.characterSpacing == b.characterSpacing &&
        a.adjustYakumono == b.adjustYakumono &&
        a.useVerticalGlyphs == b.useVerticalGlyphs &&
        a.enableKinsoku == b.enableKinsoku &&
        a.enableHalfWidthYakumono == b.enableHalfWidthYakumono &&
        a.enableGyotoIndent == b.enableGyotoIndent &&
        a.enableKerning == b.enableKerning &&
        a.rotateLatinCharacters == b.rotateLatinCharacters &&
        a.alignment == b.alignment &&
        a.indent == b.indent &&
        a.firstLineIndent == b.firstLineIndent &&
        a.rubyStyle?.fontSize == b.rubyStyle?.fontSize &&
        a.rubyStyle?.color == b.rubyStyle?.color &&
        a.rubyStyle?.fontFamily == b.rubyStyle?.fontFamily;
  }

  /// Calculate hash code for VerticalTextStyle
  int _styleHashCode(VerticalTextStyle style) {
    return Object.hash(
      style.baseStyle.fontSize,
      style.baseStyle.color,
      style.baseStyle.fontFamily,
      style.baseStyle.fontWeight,
      style.baseStyle.fontStyle,
      style.baseStyle.height,
      style.lineSpacing,
      style.characterSpacing,
      style.adjustYakumono,
      style.useVerticalGlyphs,
      style.enableKinsoku,
      style.enableHalfWidthYakumono,
      style.enableGyotoIndent,
      style.enableKerning,
      style.rotateLatinCharacters,
      style.alignment,
      style.indent,
      style.firstLineIndent,
      Object.hash(style.rubyStyle?.fontSize, style.rubyStyle?.color, style.rubyStyle?.fontFamily),
    );
  }
}

/// Cached layout result
class LayoutCacheValue {
  final List<CharacterLayout> layouts;
  final Size size;

  const LayoutCacheValue({
    required this.layouts,
    required this.size,
  });
}

/// LRU cache for layout results
class LayoutCache {
  static const int maxCacheSize = 100;
  static final LinkedHashMap<LayoutCacheKey, LayoutCacheValue> _cache =
      LinkedHashMap<LayoutCacheKey, LayoutCacheValue>();

  /// Get cached layout result
  static LayoutCacheValue? get(LayoutCacheKey key) {
    final value = _cache.remove(key);
    if (value != null) {
      // Move to end (most recently used)
      _cache[key] = value;
    }
    return value;
  }

  /// Store layout result in cache
  static void put(LayoutCacheKey key, LayoutCacheValue value) {
    _cache.remove(key);
    _cache[key] = value;

    // Remove oldest entries if cache is full
    while (_cache.length > maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Clear the cache
  static void clear() {
    _cache.clear();
  }

  /// Get cache statistics
  static Map<String, int> getStats() {
    return {
      'size': _cache.length,
      'maxSize': maxCacheSize,
    };
  }
}
