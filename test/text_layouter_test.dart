import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tategaki/src/rendering/text_layouter.dart';
import 'package:tategaki/src/models/vertical_text_style.dart';
import 'package:tategaki/src/utils/layout_cache.dart';

void main() {
  late TextLayouter layouter;

  setUp(() {
    LayoutCache.clear();
    layouter = TextLayouter();
  });

  group('TextLayouter', () {
    group('layoutText', () {
      test('should return empty list for empty text', () {
        const style = VerticalTextStyle();
        final layouts = layouter.layoutText('', style, 0);

        expect(layouts, isEmpty);
      });

      test('should create layout for each character', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
        );
        final layouts = layouter.layoutText('あいう', style, 0);

        expect(layouts.length, 3);
        expect(layouts[0].character, 'あ');
        expect(layouts[1].character, 'い');
        expect(layouts[2].character, 'う');
      });

      test('should assign correct textIndex to each character', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
        );
        final layouts = layouter.layoutText('テスト', style, 0);

        expect(layouts[0].textIndex, 0);
        expect(layouts[1].textIndex, 1);
        expect(layouts[2].textIndex, 2);
      });

      test('should position characters vertically (top to bottom)', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          characterSpacing: 0,
        );
        final layouts = layouter.layoutText('あい', style, 0);

        // First character at top
        expect(layouts[0].position.dy, 0);

        // Second character should be below (Y increases downward)
        expect(layouts[1].position.dy, 16); // fontSize
      });

      test('should apply indent to all lines', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          indent: 2,
        );
        final layouts = layouter.layoutText('あ', style, 0);

        // With indent=2, first character should be at Y = 2 * fontSize = 32
        expect(layouts[0].position.dy, 32);
      });

      test('should apply firstLineIndent only to first line', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          firstLineIndent: 1,
        );
        final layouts = layouter.layoutText('あ\nい', style, 0);

        // First line (first column) with firstLineIndent
        // Y position should be 1 * fontSize = 16
        expect(layouts[0].position.dy, 16);

        // Second line (second column) without firstLineIndent
        // Y position should be 0
        expect(layouts[1].position.dy, 0);
      });

      test('should apply both indent and firstLineIndent to first line', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          indent: 1,
          firstLineIndent: 2,
        );
        final layouts = layouter.layoutText('あ\nい', style, 0);

        // First line: indent + firstLineIndent = 1 + 2 = 3 characters
        expect(layouts[0].position.dy, 48); // 3 * fontSize

        // Second line: only indent = 1 character
        expect(layouts[1].position.dy, 16); // 1 * fontSize
      });

      test('should skip newline characters', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
        );
        final layouts = layouter.layoutText('あ\nい', style, 0);

        // Should have 2 character layouts (newline is skipped)
        expect(layouts.length, 2);
        expect(layouts[0].character, 'あ');
        expect(layouts[1].character, 'い');
      });

      test('should move to next column on newline (right to left)', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          lineSpacing: 0,
        );
        final layouts = layouter.layoutText('あ\nい', style, 0);

        // First character in first column (rightmost)
        final firstX = layouts[0].position.dx;

        // Second character in second column (to the left)
        final secondX = layouts[1].position.dx;

        // Second column should be to the left (smaller X)
        expect(secondX, lessThan(firstX));
      });

      test('should wrap text when exceeding maxHeight', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          enableKinsoku: false, // Disable kinsoku for predictable wrapping
        );
        final layouts = layouter.layoutText('あいうえお', style, 48); // 3 characters tall

        // First 3 characters should be in first column (same X)
        final firstColumnX = layouts[0].position.dx;
        expect(layouts[1].position.dx, firstColumnX);
        expect(layouts[2].position.dx, firstColumnX);

        // Remaining characters should be in second column (different X)
        expect(layouts[3].position.dx, lessThan(firstColumnX));
        expect(layouts[4].position.dx, lessThan(firstColumnX));
      });

      test('firstLineIndent should not affect subsequent lines after line wrap', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          firstLineIndent: 2,
          enableKinsoku: false, // Disable kinsoku for predictable wrapping
        );
        // With firstLineIndent=2, first line starts at Y=32
        // maxHeight=48 means only ~1 character fits (48-32=16)
        final layouts = layouter.layoutText('あいう', style, 48);

        // First column has firstLineIndent = 2 * 16 = 32
        expect(layouts[0].position.dy, 32);

        // Find characters on second column
        final firstColumnX = layouts[0].position.dx;
        final secondColumnLayouts = layouts.where(
          (l) => l.position.dx < firstColumnX,
        ).toList();

        // Second column should start at Y = 0 (no firstLineIndent)
        if (secondColumnLayouts.isNotEmpty) {
          expect(secondColumnLayouts[0].position.dy, 0);
        }
      });

      test('should apply characterSpacing between characters', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          characterSpacing: 4,
        );
        final layouts = layouter.layoutText('あい', style, 0);

        // Second character should be at fontSize + characterSpacing
        expect(layouts[1].position.dy, 20); // 16 + 4
      });

      test('indent should apply to all columns including wrapped ones', () {
        const style = VerticalTextStyle(
          baseStyle: TextStyle(fontSize: 16),
          indent: 1,
          enableKinsoku: false,
        );
        final layouts = layouter.layoutText('あい', style, 16); // Force wrap after 1 char

        // First column: starts at indent = 16
        expect(layouts[0].position.dy, 16);

        // Second column: also starts at indent = 16
        expect(layouts[1].position.dy, 16);
      });
    });
  });
}
