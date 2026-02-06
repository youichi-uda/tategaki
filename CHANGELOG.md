# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.11] - 2026-02-07

### Fixed
- **Tatechuyoko auto-detection for numbers with separators**: Numbers containing commas or periods (e.g., `3,500`, `3.14`, `1,000,000`) are now correctly recognized as single numbers and excluded from tatechuyoko detection
  - Previously, `3,500` would incorrectly detect `3` as a standalone tatechuyoko
  - Supports both half-width (`,` `.`) and full-width (`，` `．`) separators

## [0.6.10] - 2026-02-06

### Fixed
- **Rotation rules for quotation marks**: Add smart quotes (`''""`) and guillemets (`«»`) to `rotatedYakumono` for proper vertical text rotation

## [0.6.9] - 2026-02-02

### Fixed
- **Warichu splitIndex bounds check**: Add `clamp()` to prevent `RangeError` when `splitIndex` is out of bounds
- **LayoutCache comparison**: Add `fontWeight`, `fontStyle`, `height`, `rubyStyle.fontFamily` to style comparison to prevent cache collisions
- **Gaiji image loading**: Add debug logging for image loading failures

## [0.6.8] - 2026-02-01

### Performance
- **Layout caching in VerticalTextPainter**: Add instance-level layout cache to avoid redundant layout calculations during scroll
  - Cache `characterLayouts`, `startX`, `tatechuyokoIndices`, and `warichuHeights`
  - Reuse cached layout when these values haven't changed between paint() calls
  - Significantly improves scroll performance for long text content

### Fixed
- Remove unused `charIndex` variable from `TextLayouter.layoutText()`
- Remove unnecessary `characters` package import (provided by flutter/material.dart)

## [0.6.7] - 2026-02-01

### Fixed
- **Surrogate pair support**: Fix incorrect handling of characters outside BMP (e.g., CJK Extension B characters like U+24103)
  - Use `characters` package for proper Unicode grapheme cluster iteration
  - Previously, surrogate pairs were split into two invalid characters
- **Fallback font propagation**: Fix `fontFamily` and `fontFamilyFallback` not being applied in `_calculateAdvance()`
  - Now uses `style.baseStyle.copyWith()` instead of creating a new `TextStyle`

### Added
- Add `characters` package dependency for Unicode support
- Add fallback font demo in example app

## [0.6.6] - 2026-01-26

### Changed
- Tatechuyoko auto-detection now includes single-digit numbers and single-letter alphabets
  - Previously only 2-character sequences were detected
  - Now 1-2 digit numbers (e.g., "1", "12") are detected as tatechuyoko
  - Now 1-2 letter alphabets (e.g., "A", "AB") are detected as tatechuyoko
  - 3+ character sequences are still excluded from auto-detection

## [0.6.4] - 2026-01-13

### Added
- Add comprehensive `TextLayouter` tests to prevent regression
  - Tests for `indent`, `firstLineIndent`, `characterSpacing`
  - Tests for line wrapping and column positioning
  - Tests ensure `firstLineIndent` only applies to first column

### Changed
- Remove unused `isFirstLine` variable from `TextLayouter`

## [0.6.3] - 2026-01-13

### Fixed
- Fix `firstLineIndent` not being applied to the first line
  - First line now correctly receives both `indent` and `firstLineIndent` offsets
  - Subsequent lines only receive `indent` offset (段落字下げ behavior restored)

## [0.6.2] - 2026-01-12

### Performance
- Reuse static `TextPainter` instances in `TextLayouter`, `WarichuRenderer`, and `SelectableVerticalTextPainter` to reduce object allocations
- Extract duplicate advance calculation logic into `_calculateAdvance()` helper method
- Reuse static `TextLayouter` instance in `SelectableVerticalTextPainter`

### Fixed
- Fix `shouldRepaint()` in `VerticalTextPainter` and `SelectableVerticalTextPainter` to use `listEquals` for proper deep comparison of annotation lists
- Add missing style properties to `LayoutCacheKey` comparison (`rotateLatinCharacters`, `alignment`, `indent`, `firstLineIndent`, `rubyStyle`)

## [0.6.1] - 2026-01-12

### Fixed
- Fixed `SelectionAreaVerticalText` constraint violation error
  - `RenderSelectionAreaVerticalText` now properly constrains its size to parent constraints
  - Prevents "does not meet its constraints" assertion when text height exceeds available space

## [0.6.0] - 2026-01-12

### Breaking Changes
- **Default alignment changed from `center` to `start` (天付き)**
  - `VerticalTextStyle.alignment` now defaults to `TextAlignment.start`
  - This matches traditional Japanese vertical text layout where text aligns to the top
  - To restore previous behavior, explicitly set `alignment: TextAlignment.center`

## [0.5.1] - 2026-01-11

### Added
- Quick Start section with simple Japanese examples
- Platform Support table for all supported platforms
- Use Cases section with practical examples (novels, haiku, newspapers, greeting cards, education apps)

## [0.5.0] - 2026-01-11

### Added
- **Gaiji (外字) support** - Image-based custom characters
  - `Gaiji` model for specifying custom character images
  - `gaijiList` parameter in `VerticalText` widget
  - Supports multiple image sources: `AssetImage`, `NetworkImage`, `FileImage`, `MemoryImage`
  - Gaiji images automatically scale to match font size
  - Placeholder characters are replaced with images

## [0.4.2] - 2026-01-11

### Changed
- Updated README with latest features documentation
- Added TextAlignment usage examples
- Added Related Packages section
- Updated installation version to ^0.4.0
- Updated Roadmap with completed features

## [0.4.1] - 2026-01-11

### Fixed
- Removed unused `dart:math` and `dart:ui` imports from decoration_renderer.dart
- Fixed `sort_child_properties_last` lint warnings in selectable_vertical_text.dart
- Updated TextSpanV to use super parameters

## [0.4.0] - 2026-01-11

### Added
- **Line alignment support** (地付き/天付き)
  - `alignment` property in `VerticalTextStyle`
  - `TextAlignment.start` (天付き): Align line to top
  - `TextAlignment.center`: Center alignment (default)
  - `TextAlignment.end` (地付き): Align line to bottom
- Alignment demo page in example app

### Fixed
- Ruby position adjustment when sideline decoration is present
- Line grouping for alignment now uses lineIndex instead of exact X coordinate

### Changed
- Uses kinsoku package's `TextAlignment` enum for alignment values

## [0.3.1] - 2026-01-10

### Fixed
- **Text selection handle dragging**
  - Fixed handles being blocked by parent ScrollView gestures
  - Replaced GestureDetector with RawGestureDetector for better gesture control
  - Added early pointer detection with Listener to prevent scroll interference
  - Increased handle size from 6px to 8px radius for better visibility
  - Expanded handle hit test area from 24px to 48px for easier dragging
  - Fixed handle positioning by adding proper left margin
  - Handles now remain fully visible and draggable even inside ScrollView

### Changed
- Selection handles are now larger and easier to tap
- Improved gesture handling with reduced touch slop (1.0px)
- Text layout shifted to accommodate selection handle positioning

## [0.3.0] - 2026-01-10

### Added
- **Text selection support**
  - SelectableVerticalText widget for user text selection
  - Tap to select single character
  - Drag to select text range
  - Long-press to show copy menu
  - Copy to clipboard functionality
  - Selection highlighting with customizable color
  - Selection demo page in example app

### New Widgets
- `SelectableVerticalText` - Vertical text with selection support
- Selection demo at `example/lib/demos/selection_demo.dart`

### Features
- Character-level hit testing for accurate selection
- Visual selection highlighting
- Context menu with copy action
- Works with ruby (furigana) and kenten annotations

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
