# Tategaki（縦書き）

[![pub package](https://img.shields.io/pub/v/tategaki.svg)](https://pub.dev/packages/tategaki)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package for Japanese vertical text (縦書き) layout with advanced typography features.

## Features

- **Basic Vertical Text Layout**: Top-to-bottom, right-to-left Japanese text rendering
- **Ruby (Furigana)**: Phonetic guide text beside characters
- **Kenten (圏点)**: Various styles of emphasis marks (sesame, circles, triangles, etc.)
- **Tatechuyoko (縦中横)**: Horizontal text within vertical layout (for numbers, dates)
- **Warichu (割注)**: Two-line inline annotations
- **Text Decoration (傍線)**: Sideline decorations (single, double, wavy, dotted)
- **Text Alignment (地付き/天付き)**: Line-level vertical alignment
  - `TextAlignment.start` (天付き): Align to top
  - `TextAlignment.center`: Center alignment (default)
  - `TextAlignment.end` (地付き): Align to bottom
- **Text Selection**: Interactive text selection with copy support
- **Advanced Kinsoku Shori (禁則処理)**: Proper line breaking rules for Japanese typography
- **Kerning**: Advanced character spacing adjustments for professional typography
- **Yakumono Adjustment (約物調整)**: Fine-tuned punctuation positioning
  - Burasage-gumi (ぶら下げ組): Hanging punctuation at line ends
  - Half-width punctuation (半角処理): Treats certain punctuation as 0.5 character width
  - Gyoto indent (行頭括弧の字下げ): Indented opening brackets at line start
  - Consecutive punctuation spacing: Tightened spacing between adjacent punctuation
- **RichText Support**: Multiple text styles, colors, and sizes in a single vertical text
- **Figure Layout**: Image placement with captions and text wrapping support

## Related Packages

This package is part of the Japanese text layout suite:

| Package | Description |
|---------|-------------|
| [kinsoku](https://pub.dev/packages/kinsoku) | Core text processing (line breaking, character classification) |
| **tategaki** | Vertical text layout (this package) |
| [yokogaki](https://pub.dev/packages/yokogaki) | Horizontal text layout (横書き) |

## Quick Start

3ステップで縦書きテキストを表示:

```dart
// 1. Import
import 'package:tategaki/tategaki.dart';

// 2. Widget内で使用
VerticalText(
  'こんにちは、世界！',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
  ),
)
```

ルビ付きの例:

```dart
VerticalText(
  '日本語',
  ruby: const [RubyText(startIndex: 0, length: 3, ruby: 'にほんご')],
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 32),
    rubyStyle: TextStyle(fontSize: 14),
  ),
)
```

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | All features |
| iOS | ✅ Supported | All features |
| Web | ✅ Supported | All features |
| Windows | ✅ Supported | All features |
| macOS | ✅ Supported | All features |
| Linux | ✅ Supported | All features |

**Requirements:**
- Flutter: ≥1.17.0
- Dart SDK: ≥3.10.3

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tategaki: ^0.6.5
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
- `KentenStyle.doubleCircle` - 二重丸 (◎)

### With Text Alignment (地付き/天付き)

Control line-level vertical alignment:

```dart
VerticalText(
  '地付きの例です。',
  style: VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
    alignment: TextAlignment.end, // 地付き - align to bottom
  ),
  maxHeight: 400,
)
```

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

### Selectable Text

Enable text selection with copy support:

```dart
SelectableVerticalText(
  'これは選択可能な縦書きテキストです。',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
  ),
  maxHeight: 400,
)
```

### SelectionArea Integration (Selection API)

Use `SelectionAreaVerticalText` inside `SelectionArea` to enable unified text selection across multiple widgets:

```dart
SelectionArea(
  child: Row(
    children: [
      SelectableText('横書きテキスト'),
      SelectionAreaVerticalText(
        text: '縦書きテキスト',
        style: VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 24),
        ),
        rubyList: [
          RubyText(startIndex: 0, length: 2, ruby: 'たて'),
        ],
        maxHeight: 300,
      ),
    ],
  ),
)
```

This allows seamless text selection that spans across vertical and horizontal text widgets.

### Long Press Selectable Text

For reading apps where drag gestures should scroll content rather than select text, use `LongPressSelectableVerticalText`. Selection only starts after a long press (similar to Android Chrome):

```dart
LongPressSelectableVerticalText(
  text: 'これは長押しで選択可能な縦書きテキストです。',
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
  ),
  maxHeight: 400,
  // Optional: customize long press duration (default: 500ms)
  longPressDuration: Duration(milliseconds: 500),
)
```

Features:
- Long press to start selection (word-by-word using TinySegmenter)
- Drag to extend selection
- Copy menu with haptic feedback
- Tap to dismiss selection

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
| `alignment` | `TextAlignment` | `center` | Line-level alignment (start/center/end) |
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

### Figure Layout

Place images within vertical text with captions:

```dart
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

## Use Cases / ユースケース

### 小説・文芸作品

縦書きの小説ビューアに最適:

```dart
VerticalText(
  '吾輩は猫である。名前はまだ無い。'
  'どこで生まれたかとんと見当がつかぬ。',
  style: VerticalTextStyle(
    baseStyle: TextStyle(
      fontSize: 18,
      fontFamily: 'NotoSerifJP',  // 明朝体推奨
      height: 1.8,
    ),
    lineSpacing: 24,
    characterSpacing: 2,
  ),
  maxHeight: 500,
)
```

### 俳句・短歌

一行で表示する短詩形式:

```dart
VerticalText(
  '古池や蛙飛び込む水の音',
  ruby: const [
    RubyText(startIndex: 0, length: 2, ruby: 'ふるいけ'),
    RubyText(startIndex: 3, length: 1, ruby: 'かわず'),
  ],
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 28),
    rubyStyle: TextStyle(fontSize: 12),
    characterSpacing: 8,
  ),
)
```

### 新聞・雑誌レイアウト

見出しと本文の組み合わせ:

```dart
Column(
  children: [
    VerticalText(
      '本日の主要ニュース',
      style: const VerticalTextStyle(
        baseStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    VerticalText(
      '詳細な本文がここに続きます...',
      kenten: const [
        Kenten(startIndex: 0, length: 2, style: KentenStyle.sesame),
      ],
      style: const VerticalTextStyle(
        baseStyle: TextStyle(fontSize: 16),
        lineSpacing: 16,
      ),
      maxHeight: 300,
    ),
  ],
)
```

### 年賀状・挨拶状

日付に縦中横を使用:

```dart
VerticalText(
  '令和07年01月01日　謹賀新年',
  autoTatechuyoko: true,  // 07, 01 が横組みに
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
    characterSpacing: 4,
  ),
)
```

### 教育アプリ

選択可能なテキストで読解練習:

```dart
SelectableVerticalText(
  '漢字の読み方を学びましょう。',
  ruby: const [
    RubyText(startIndex: 0, length: 2, ruby: 'かんじ'),
    RubyText(startIndex: 3, length: 2, ruby: 'よみかた'),
  ],
  style: const VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 28),
    rubyStyle: TextStyle(fontSize: 14, color: Colors.blue),
  ),
  maxHeight: 400,
)
```

## Performance

tategaki v0.2.0+ includes significant performance optimizations:

- **TextPainter Reuse**: Reduced memory allocations by reusing TextPainter instances across renders
- **Efficient Layout**: Character layout caching for optimal performance
- **Lazy Rendering**: CustomPainter-based rendering with minimal overhead
- **Memory Efficient**: Low memory footprint even for long vertical texts

Performance improvements in v0.2.0:
- ~50% reduction in TextPainter allocations
- Improved rendering performance for scrollable vertical text lists
- Reduced memory pressure during text rendering

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
- [x] Performance optimizations (v0.2.0)
- [x] Text selection with context menu (v0.3.0)
- [x] Text alignment (地付き/天付き) (v0.4.0)
- [x] Text decoration (sideline) support
- [x] Selection API integration (SelectionArea support)
- [x] Long press selectable text (v0.6.5)
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
- [JIS X 4051:2004](https://kikakurui.com/x4/X4051-2004-02.html) - Japanese document composition method
- [Flutter CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
