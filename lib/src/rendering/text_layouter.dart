import 'dart:ui';
import '../models/vertical_text_style.dart';
import '../models/ruby_text.dart';
import '../utils/character_classifier.dart';
import '../utils/rotation_rules.dart';

/// Layout information for a single character
class CharacterLayout {
  /// The character string
  final String character;

  /// Position to draw the character
  final Offset position;

  /// Rotation angle in radians
  final double rotation;

  /// Font size for this character
  final double fontSize;

  /// Character type
  final CharacterType type;

  const CharacterLayout({
    required this.character,
    required this.position,
    required this.rotation,
    required this.fontSize,
    required this.type,
  });
}

/// Layout information for ruby text
class RubyLayout {
  /// Position to draw the ruby text
  final Offset position;

  /// The ruby text string
  final String ruby;

  /// Font size for ruby
  final double fontSize;

  const RubyLayout({
    required this.position,
    required this.ruby,
    required this.fontSize,
  });
}

/// Text layouter for vertical text
class TextLayouter {
  /// Layout text characters for vertical display
  /// 
  /// Returns a list of character layouts with positions and rotations
  List<CharacterLayout> layoutText(
    String text,
    VerticalTextStyle style,
    double maxHeight,
  ) {
    final layouts = <CharacterLayout>[];
    final fontSize = style.baseStyle.fontSize ?? 16.0;
    
    double currentY = 0.0;
    double currentX = 0.0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final type = CharacterClassifier.classify(char);
      
      // Calculate character size
      double charFontSize = fontSize;
      if (CharacterClassifier.isSmallKana(char)) {
        charFontSize = fontSize * 0.7;
      }

      // Calculate rotation
      final rotation = RotationRules.getRotationAngle(
        char,
        type,
        style.rotateLatinCharacters,
      );

      // Create layout
      layouts.add(CharacterLayout(
        character: char,
        position: Offset(currentX, currentY),
        rotation: rotation,
        fontSize: charFontSize,
        type: type,
      ));

      // Advance position
      currentY += fontSize + style.characterSpacing;

      // Handle line wrapping
      if (maxHeight > 0 && currentY > maxHeight) {
        currentY = 0.0;
        currentX -= fontSize + style.lineSpacing;
      }
    }

    return layouts;
  }

  /// Layout ruby text for given base text
  List<RubyLayout> layoutRuby(
    String baseText,
    List<RubyText> rubyList,
    VerticalTextStyle style,
  ) {
    final layouts = <RubyLayout>[];
    final baseFontSize = style.baseStyle.fontSize ?? 16.0;
    final rubyFontSize = (style.rubyStyle?.fontSize ?? baseFontSize) * 0.5;

    for (final ruby in rubyList) {
      // Calculate ruby position (to the right of base text in vertical layout)
      final baseStartY = ruby.startIndex * baseFontSize;
      final baseLength = ruby.length * baseFontSize;
      final rubyY = baseStartY + (baseLength - ruby.ruby.length * rubyFontSize) / 2;

      layouts.add(RubyLayout(
        position: Offset(baseFontSize, rubyY),
        ruby: ruby.ruby,
        fontSize: rubyFontSize,
      ));
    }

    return layouts;
  }
}
