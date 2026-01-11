import 'package:flutter/widgets.dart';

/// Represents an image-based custom character (外字)
///
/// Gaiji (外字) are characters not found in standard character sets,
/// often used for rare kanji variants, historical characters, or
/// personal/corporate name characters.
///
/// The image replaces the placeholder character at the specified index.
class Gaiji {
  /// Starting index of the placeholder character to replace
  final int startIndex;

  /// Number of characters to replace (typically 1)
  final int length;

  /// Image provider for the gaiji image
  ///
  /// Supports any ImageProvider:
  /// - AssetImage('assets/gaiji/rare_kanji.png')
  /// - NetworkImage('https://example.com/gaiji.png')
  /// - FileImage(File('path/to/gaiji.png'))
  /// - MemoryImage(bytes)
  final ImageProvider image;

  /// Optional width override (defaults to fontSize)
  final double? width;

  /// Optional height override (defaults to fontSize)
  final double? height;

  const Gaiji({
    required this.startIndex,
    this.length = 1,
    required this.image,
    this.width,
    this.height,
  });

  /// End index of the replaced text (exclusive)
  int get endIndex => startIndex + length;

  @override
  String toString() {
    return 'Gaiji(startIndex: $startIndex, length: $length, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gaiji &&
        other.startIndex == startIndex &&
        other.length == length &&
        other.image == image &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(startIndex, length, image, width, height);
}
