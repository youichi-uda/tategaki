import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinsoku/kinsoku.dart';
import 'package:tategaki/src/utils/layout_cache.dart';
import 'package:tategaki/src/models/vertical_text_style.dart';
import 'package:tategaki/src/rendering/text_layouter.dart';
import 'dart:math' as math;

void main() {
  setUp(() {
    LayoutCache.clear();
  });

  group('LayoutCacheKey', () {
    test('should be equal when all properties match', () {
      const style = VerticalTextStyle();
      const key1 = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 100);

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
    });

    test('should not be equal when text differs', () {
      const style = VerticalTextStyle();
      const key1 = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 100);
      const key2 = LayoutCacheKey(text: '違う', style: style, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when maxHeight differs', () {
      const style = VerticalTextStyle();
      const key1 = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 200);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when indent differs', () {
      const style1 = VerticalTextStyle(indent: 1);
      const style2 = VerticalTextStyle(indent: 2);
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when firstLineIndent differs', () {
      const style1 = VerticalTextStyle(firstLineIndent: 1);
      const style2 = VerticalTextStyle(firstLineIndent: 2);
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when rubyStyle differs', () {
      const style1 = VerticalTextStyle(
        rubyStyle: TextStyle(fontSize: 8),
      );
      const style2 = VerticalTextStyle(
        rubyStyle: TextStyle(fontSize: 10),
      );
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when alignment differs', () {
      const style1 = VerticalTextStyle(alignment: TextAlignment.start);
      const style2 = VerticalTextStyle(alignment: TextAlignment.end);
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when rotateLatinCharacters differs', () {
      const style1 = VerticalTextStyle(rotateLatinCharacters: true);
      const style2 = VerticalTextStyle(rotateLatinCharacters: false);
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when characterSpacing differs', () {
      const style1 = VerticalTextStyle(characterSpacing: 0.0);
      const style2 = VerticalTextStyle(characterSpacing: 5.0);
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when lineSpacing differs', () {
      const style1 = VerticalTextStyle(lineSpacing: 0.0);
      const style2 = VerticalTextStyle(lineSpacing: 10.0);
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should not be equal when enableKinsoku differs', () {
      const style1 = VerticalTextStyle(enableKinsoku: true);
      const style2 = VerticalTextStyle(enableKinsoku: false);
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, isNot(equals(key2)));
    });

    test('should be equal when optional styles are both null', () {
      const style1 = VerticalTextStyle();
      const style2 = VerticalTextStyle();
      const key1 = LayoutCacheKey(text: 'テスト', style: style1, maxHeight: 100);
      const key2 = LayoutCacheKey(text: 'テスト', style: style2, maxHeight: 100);

      expect(key1, equals(key2));
    });
  });

  group('LayoutCache', () {
    test('should return null for missing key', () {
      const style = VerticalTextStyle();
      const key = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 100);

      expect(LayoutCache.get(key), isNull);
    });

    test('should store and retrieve value', () {
      const style = VerticalTextStyle();
      const key = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 100);
      final value = LayoutCacheValue(
        layouts: [
          CharacterLayout(
            character: 'テ',
            position: const Offset(0, 0),
            rotation: 0,
            fontSize: 16,
            type: CharacterType.katakana,
            textIndex: 0,
          ),
        ],
        size: const Size(16, 16),
      );

      LayoutCache.put(key, value);
      final retrieved = LayoutCache.get(key);

      expect(retrieved, isNotNull);
      expect(retrieved!.layouts.length, 1);
      expect(retrieved.size, const Size(16, 16));
    });

    test('should clear cache', () {
      const style = VerticalTextStyle();
      const key = LayoutCacheKey(text: 'テスト', style: style, maxHeight: 100);
      final value = LayoutCacheValue(
        layouts: [],
        size: Size.zero,
      );

      LayoutCache.put(key, value);
      expect(LayoutCache.get(key), isNotNull);

      LayoutCache.clear();
      expect(LayoutCache.get(key), isNull);
    });

    test('should report correct stats', () {
      const style = VerticalTextStyle();
      final value = LayoutCacheValue(layouts: [], size: Size.zero);

      for (int i = 0; i < 5; i++) {
        final key = LayoutCacheKey(text: 'テスト$i', style: style, maxHeight: 100);
        LayoutCache.put(key, value);
      }

      final stats = LayoutCache.getStats();
      expect(stats['size'], 5);
      expect(stats['maxSize'], 100);
    });

    test('should evict oldest entries when cache is full', () {
      const style = VerticalTextStyle();
      final value = LayoutCacheValue(layouts: [], size: Size.zero);

      // Fill cache beyond max size
      for (int i = 0; i < 105; i++) {
        final key = LayoutCacheKey(text: 'テスト$i', style: style, maxHeight: 100);
        LayoutCache.put(key, value);
      }

      final stats = LayoutCache.getStats();
      expect(stats['size'], 100); // Should be capped at maxSize

      // Oldest entries should be evicted
      const oldKey = LayoutCacheKey(text: 'テスト0', style: style, maxHeight: 100);
      expect(LayoutCache.get(oldKey), isNull);

      // Newest entries should still exist
      const newKey = LayoutCacheKey(text: 'テスト104', style: style, maxHeight: 100);
      expect(LayoutCache.get(newKey), isNotNull);
    });

    test('should update LRU order on get', () {
      const style = VerticalTextStyle();
      final value = LayoutCacheValue(layouts: [], size: Size.zero);

      // Add entries
      for (int i = 0; i < 100; i++) {
        final key = LayoutCacheKey(text: 'テスト$i', style: style, maxHeight: 100);
        LayoutCache.put(key, value);
      }

      // Access first entry to move it to end
      const firstKey = LayoutCacheKey(text: 'テスト0', style: style, maxHeight: 100);
      LayoutCache.get(firstKey);

      // Add new entries to trigger eviction
      for (int i = 100; i < 105; i++) {
        final key = LayoutCacheKey(text: 'テスト$i', style: style, maxHeight: 100);
        LayoutCache.put(key, value);
      }

      // First entry should still exist (was recently accessed)
      expect(LayoutCache.get(firstKey), isNotNull);

      // Entry 1 should be evicted (wasn't accessed)
      const secondKey = LayoutCacheKey(text: 'テスト1', style: style, maxHeight: 100);
      expect(LayoutCache.get(secondKey), isNull);
    });
  });
}
