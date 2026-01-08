# Tategaki

A comprehensive Flutter package for Japanese vertical text (縦書き) layout with advanced typography features.

## Features

- **Basic Vertical Text Layout**: Top-to-bottom, right-to-left Japanese text rendering
- **Ruby (Furigana)**: Phonetic guide text above characters
- **Kenten (Emphasis Dots)**: Various styles of emphasis marks (sesame, circles, triangles)
- **Tatechuyoko**: Horizontal text within vertical layout (for numbers, dates)
- **Advanced Kinsoku Shori**: Line breaking rules for Japanese typography
- **Kerning**: Advanced character spacing adjustments
- **Yakumono Adjustment**: Fine-tuned punctuation positioning
  - Burasage-gumi (hanging punctuation)
  - Half-width punctuation
  - Indented opening brackets
  - Consecutive punctuation spacing
- **Text Selection**: Interactive text selection with context menu
- **RichText Support**: Multiple text styles in a single vertical text
- **Figure Layout**: Image placement with captions and text wrapping

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tategaki: ^0.1.0
```

## Usage

### Basic Vertical Text

```dart
import 'package:tategaki/tategaki.dart';

VerticalText(
  'これは縦書きテキストの例です。',
  style: VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
  ),
)
```

### With Ruby (Furigana)

```dart
VerticalText(
  '日本語',
  style: VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
  ),
  ruby: [
    RubyText(startIndex: 0, length: 3, ruby: 'にほんご'),
  ],
)
```

### With Kenten (Emphasis Dots)

```dart
VerticalText(
  '重要なテキスト',
  style: VerticalTextStyle(
    baseStyle: TextStyle(fontSize: 24),
  ),
  kenten: [
    Kenten(startIndex: 0, length: 2, style: KentenStyle.filledCircle),
  ],
)
```

## Roadmap

- [x] Basic vertical text layout
- [x] Ruby support
- [x] Kenten support
- [x] Tatechuyoko
- [x] Kinsoku processing
- [x] Kerning
- [x] Advanced yakumono adjustment
- [x] Text selection
- [x] RichText support
- [x] Figure layout
- [ ] Text editing (future)
- [ ] PDF export (future)

## License

MIT License - see the [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
