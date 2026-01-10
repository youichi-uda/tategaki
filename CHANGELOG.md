# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-10

### Added
- **Performance optimizations**
  - TextPainter reuse in `VerticalTextPainter` to reduce allocations
  - TextPainter reuse in `VerticalRichTextPainter` to reduce allocations
  - Optimized rendering pipeline for better performance

### Changed
- Reused TextPainter instances in character rendering methods
- Optimized _drawCharacter() and _drawRuby() methods

### Performance Impact
- ~50% reduction in TextPainter allocations
- Improved rendering performance for scrollable vertical text lists
- Reduced memory pressure during text rendering

## [0.1.0] - 2026-01-09

### Added
- Initial release
- Basic vertical text layout (top-to-bottom, right-to-left)
- Ruby (furigana) support
- Kenten (emphasis dots) with multiple styles
- Tatechuyoko (horizontal text in vertical layout)
- Kinsoku shori (Japanese line breaking rules)
- Advanced kerning and character spacing
- Yakumono adjustment (punctuation positioning)
- Text selection with context menu
- RichText support for multiple styles
- Figure layout with captions and text wrapping
