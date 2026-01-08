# Tategaki（縦書き）

[![pub package](https://img.shields.io/pub/v/tategaki.svg)](https://pub.dev/packages/tategaki)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package for Japanese vertical text (縦書き) layout with advanced typography features.

## Features

- ✨ **Basic Vertical Text Layout**: Top-to-bottom, right-to-left Japanese text rendering
- 📝 **Ruby (Furigana)**: Phonetic guide text above characters
- • **Kenten (圏点)**: Various styles of emphasis marks (sesame, circles, triangles)
- ↔️ **Tatechuyoko (縦中横)**: Horizontal text within vertical layout (for numbers, dates)
- 📏 **Advanced Kinsoku Shori (禁則処理)**: Proper line breaking rules for Japanese typography
- 🎯 **Kerning**: Advanced character spacing adjustments for professional typography
- 📌 **Yakumono Adjustment (約物調整)**: Fine-tuned punctuation positioning
  - Burasage-gumi (ぶら下げ組): Hanging punctuation at line ends
  - Half-width punctuation (半角処理): Treats certain punctuation as 0.5 character width
  - Gyoto indent (行頭括弧の字下げ): Indented opening brackets at line start
  - Consecutive punctuation spacing: Tightened spacing between adjacent punctuation
- 🎨 **RichText Support**: Multiple text styles, colors, and sizes in a single vertical text
- 🖼️ **Figure Layout**: Image placement with captions and text wrapping support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tategaki: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Vertical Text

The simplest way to display vertical Japanese text:

```dart
import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

VerticalText(
  'これは縦書きテキストの例です。日本語の伝統的な文書では、このように縦書きで文字を配置します。',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
    characterSpacing: 4,
    lineSpacing: 24,
  ),
  maxHeight: 400, // Wrap to next line after 400px height
)
```

### With Ruby (Furigana)

Add phonetic guides to your vertical text:

```dart
VerticalText(
  '日本語',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 32, color: Colors.black87),
    rubyStyle: TextStyle(fontSize: 14, color: Colors.blue),
  ),
  ruby: const [
    RubyText(startIndex: 0, length: 3, ruby: 'にほんご'),
  ],
)
```

### With Kenten (Emphasis Dots)

Add emphasis marks to important text:

```dart
VerticalText(
  '重要な内容です',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
    characterSpacing: 6,
  ),
  kenten: const [
    Kenten(startIndex: 0, length: 2, style: KentenStyle.filledCircle),
  ],
)
```

Available kenten styles:
- `KentenStyle.sesame` - ゴマ点 (•)
- `KentenStyle.filledCircle` - 黒丸 (●)
- `KentenStyle.circle` - 白丸 (○)
- `KentenStyle.filledTriangle` - 黒三角 (▲)
- `KentenStyle.triangle` - 白三角 (△)

### Auto Tatechuyoko (Horizontal Numbers)

Automatically convert 2-digit numbers to horizontal layout within vertical text:

```dart
VerticalText(
  '令和06年12月25日',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
    characterSpacing: 4,
  ),
  autoTatechuyoko: true, // Automatically detects 06, 12, 25
)
```

### Advanced Typography with Kerning and Yakumono

Enable professional Japanese typography features:

```dart
VerticalText(
  '「これは、約物調整の例です。」と彼は言った。',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
    characterSpacing: 4,
    enableKerning: true,              // Adjust spacing between characters
    enableHalfWidthYakumono: true,    // Treat 。、as half-width
    enableBurasageGumi: true,         // Allow punctuation to hang
    enableGyotoIndent: true,          // Indent opening brackets
    adjustYakumono: true,             // Fine-tune punctuation positions
  ),
  maxHeight: 400,
)
```

### Kinsoku Processing (Line Breaking Rules)

Proper Japanese line breaking that respects forbidden positions:

```dart
VerticalText(
  'これは禁則処理のデモです。行頭や行末に来てはいけない文字（句読点や括弧など）が適切に処理されます。',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 22, color: Colors.black87),
    characterSpacing: 3,
    lineSpacing: 20,
  ),
  maxHeight: 300, // Kinsoku rules apply at line breaks
)
```

The package automatically:
- Prevents punctuation (。、！？) from appearing at line start
- Prevents opening brackets (（「【) from appearing at line end
- Keeps inseparable character pairs (…… ) together

### RichText with Multiple Styles

Create vertical text with multiple fonts, colors, and sizes:

```dart
VerticalRichText(
  textSpan: VerticalTextSpan(
    style: const VerticalTextStyle(
      baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
      characterSpacing: 4,
    ),
    children: [
      const VerticalTextSpan(text: 'これは'),
      VerticalTextSpan(
        text: '強調された',
        style: const VerticalTextStyle(
          baseStyle: TextStyle(
            fontSize: 24,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          characterSpacing: 4,
        ),
      ),
      const VerticalTextSpan(text: 'テキスト'),
      VerticalTextSpan(
        text: 'です',
        style: const VerticalTextStyle(
          baseStyle: TextStyle(
            fontSize: 28,
            color: Colors.blue,
          ),
          characterSpacing: 4,
        ),
      ),
    ],
  ),
  maxHeight: 400,
)
```

### Comprehensive Typography Example

Combine all features for professional Japanese text layout:

```dart
VerticalText(
  '昭和（1926年）12月25日。「美しい日本語の組版」を実現する為に、様々な工夫が凝らされている。',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 20, color: Colors.black87),
    characterSpacing: 3,
    lineSpacing: 18,
    enableKerning: true,
    enableHalfWidthYakumono: true,
    enableBurasageGumi: true,
    enableGyotoIndent: true,
    adjustYakumono: true,
  ),
  autoTatechuyoko: true,
  maxHeight: 350,
)
```

## Configuration Options

### VerticalTextStyle

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `baseStyle` | `TextStyle` | - | Base text style (font, size, color, etc.) |
| `characterSpacing` | `double` | `0` | Vertical spacing between characters |
| `lineSpacing` | `double` | `0` | Horizontal spacing between lines |
| `rotateLatinCharacters` | `bool` | `false` | Rotate Latin characters 90° |
| `adjustYakumono` | `bool` | `true` | Enable yakumono position adjustments |
| `enableKerning` | `bool` | `false` | Enable advanced kerning |
| `enableHalfWidthYakumono` | `bool` | `false` | Treat certain punctuation as half-width |
| `enableBurasageGumi` | `bool` | `false` | Allow hanging punctuation at line ends |
| `enableGyotoIndent` | `bool` | `false` | Indent opening brackets at line start |
| `rubyStyle` | `TextStyle?` | `null` | Style for ruby (furigana) text |

## Advanced Features

### Custom Tatechuyoko

Manually specify tatechuyoko ranges:

```dart
VerticalText(
  'AB月CD日',
  tatechuyoko: const [
    Tatechuyoko(startIndex: 0, length: 2), // AB
    Tatechuyoko(startIndex: 3, length: 2), // CD
  ],
)
```

### Figure Layout (Future Feature)

Place images within vertical text with captions:

```dart
// Coming in future versions
VerticalText(
  '本文テキスト',
  figures: [
    Figure(
      child: Image.asset('image.png'),
      position: 10,
      alignment: FigureAlignment.center,
      caption: '図1：説明文',
    ),
  ],
)
```

## Examples

Check out the `/example` directory for a comprehensive demo app showcasing all features.

To run the example:

```bash
cd example
flutter run
```

## Implementation Details

### Architecture

- **CustomPainter-based**: Uses Flutter's CustomPainter for precise character positioning and rotation
- **Character-level layout**: Each character is individually positioned and rotated according to Japanese typography rules
- **Advanced line breaking**: Implements proper kinsoku shori (禁則処理) with look-ahead and backtracking
- **Modular design**: Separate utilities for character classification, rotation rules, kerning, and punctuation adjustment

### Typography Rules

The package implements proper Japanese typography rules following the [W3C Japanese Text Layout Requirements](https://www.w3.org/TR/jlreq/):

- Character rotation for brackets, quotes, and dashes
- Small kana (っゃゅょ) size and position adjustment
- Punctuation width and position fine-tuning
- Proper line breaking with forbidden positions
- Character pair kerning for professional spacing

## Performance

- Efficient character layout caching
- Lazy rendering with CustomPainter
- Minimal memory footprint for long texts
- Suitable for dynamic content

## Limitations

- **Static text only**: Text editing/input is not currently supported (planned for future)
- **Basic figure support**: Figure layout implementation is in progress
- **No text selection**: Interactive text selection is planned for future versions

## Roadmap

- [x] Basic vertical text layout
- [x] Ruby (furigana) support
- [x] Kenten (emphasis dots) support
- [x] Tatechuyoko (horizontal in vertical)
- [x] Advanced kinsoku processing
- [x] Professional kerning
- [x] Advanced yakumono adjustment
- [x] RichText support with multiple styles
- [x] Comprehensive unit tests
- [ ] Text selection with context menu (planned)
- [ ] Figure layout integration (in progress)
- [ ] Text editing support (planned)
- [ ] PDF export (planned)
- [ ] Web optimization (planned)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development Setup

```bash
git clone https://github.com/youichi-uda/tategaki.git
cd tategaki
flutter pub get
flutter test
```

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Created by Youichi Uda

Special thanks to the Flutter community and the W3C Japanese Layout Task Force for their comprehensive documentation on Japanese typography.

## References

- [W3C Japanese Text Layout Requirements](https://www.w3.org/TR/jlreq/)
- [Flutter CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
- [Japanese Typography (Wikipedia)](https://en.wikipedia.org/wiki/Japanese_writing_system#Vertical_and_horizontal_writing)
