# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
