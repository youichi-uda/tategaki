import 'package:flutter_test/flutter_test.dart';
import 'package:tategaki/tategaki.dart';

void main() {
  group('RubyText', () {
    test('should calculate endIndex correctly', () {
      const ruby = RubyText(startIndex: 0, length: 3, ruby: 'かんじ');
      expect(ruby.endIndex, 3);
    });

    test('should implement equality correctly', () {
      const ruby1 = RubyText(startIndex: 0, length: 3, ruby: 'かんじ');
      const ruby2 = RubyText(startIndex: 0, length: 3, ruby: 'かんじ');
      const ruby3 = RubyText(startIndex: 1, length: 3, ruby: 'かんじ');

      expect(ruby1, equals(ruby2));
      expect(ruby1, isNot(equals(ruby3)));
    });

    test('should have correct hashCode', () {
      const ruby1 = RubyText(startIndex: 0, length: 3, ruby: 'かんじ');
      const ruby2 = RubyText(startIndex: 0, length: 3, ruby: 'かんじ');

      expect(ruby1.hashCode, equals(ruby2.hashCode));
    });

    test('should handle different ruby texts', () {
      const ruby1 = RubyText(startIndex: 0, length: 2, ruby: 'ふりがな');
      const ruby2 = RubyText(startIndex: 0, length: 2, ruby: '別のルビ');

      expect(ruby1, isNot(equals(ruby2)));
    });
  });

  group('Kenten', () {
    test('should calculate endIndex correctly', () {
      const kenten = Kenten(startIndex: 0, length: 5, style: KentenStyle.sesame);
      expect(kenten.endIndex, 5);
    });

    test('should implement equality correctly', () {
      const kenten1 = Kenten(startIndex: 0, length: 3, style: KentenStyle.filledCircle);
      const kenten2 = Kenten(startIndex: 0, length: 3, style: KentenStyle.filledCircle);
      const kenten3 = Kenten(startIndex: 0, length: 3, style: KentenStyle.circle);

      expect(kenten1, equals(kenten2));
      expect(kenten1, isNot(equals(kenten3)));
    });

    test('should have correct hashCode', () {
      const kenten1 = Kenten(startIndex: 0, length: 3, style: KentenStyle.sesame);
      const kenten2 = Kenten(startIndex: 0, length: 3, style: KentenStyle.sesame);

      expect(kenten1.hashCode, equals(kenten2.hashCode));
    });

    test('should support all kenten styles', () {
      const styles = KentenStyle.values;
      expect(styles, contains(KentenStyle.sesame));
      expect(styles, contains(KentenStyle.filledCircle));
      expect(styles, contains(KentenStyle.circle));
      expect(styles, contains(KentenStyle.doubleCircle));
      expect(styles, contains(KentenStyle.filledTriangle));
      expect(styles, contains(KentenStyle.triangle));
      expect(styles, contains(KentenStyle.x));
      expect(styles, contains(KentenStyle.filledDiamond));
      expect(styles, contains(KentenStyle.diamond));
      expect(styles, contains(KentenStyle.filledSquare));
      expect(styles, contains(KentenStyle.square));
      expect(styles, contains(KentenStyle.filledStar));
      expect(styles, contains(KentenStyle.star));
    });
  });

  group('Warichu', () {
    test('should calculate endIndex correctly', () {
      const warichu = Warichu(startIndex: 0, length: 1, text: '注釈テスト');
      expect(warichu.endIndex, 1);
    });

    test('should split text at middle when splitIndex is null', () {
      const warichu = Warichu(startIndex: 0, length: 1, text: '注釈テスト');
      expect(warichu.firstLine, '注釈テ');
      expect(warichu.secondLine, 'スト');
    });

    test('should split text at specified index', () {
      const warichu = Warichu(startIndex: 0, length: 1, text: '注釈テスト', splitIndex: 2);
      expect(warichu.firstLine, '注釈');
      expect(warichu.secondLine, 'テスト');
    });

    test('should handle odd length text correctly', () {
      const warichu = Warichu(startIndex: 0, length: 1, text: 'あいう');
      expect(warichu.firstLine, 'あい');
      expect(warichu.secondLine, 'う');
    });

    test('should implement equality correctly', () {
      const warichu1 = Warichu(startIndex: 0, length: 1, text: 'テスト');
      const warichu2 = Warichu(startIndex: 0, length: 1, text: 'テスト');
      const warichu3 = Warichu(startIndex: 0, length: 1, text: '異なる');

      expect(warichu1, equals(warichu2));
      expect(warichu1, isNot(equals(warichu3)));
    });

    test('should have correct hashCode', () {
      const warichu1 = Warichu(startIndex: 0, length: 1, text: 'テスト');
      const warichu2 = Warichu(startIndex: 0, length: 1, text: 'テスト');

      expect(warichu1.hashCode, equals(warichu2.hashCode));
    });

    test('should distinguish by splitIndex', () {
      const warichu1 = Warichu(startIndex: 0, length: 1, text: 'テスト', splitIndex: 1);
      const warichu2 = Warichu(startIndex: 0, length: 1, text: 'テスト', splitIndex: 2);

      expect(warichu1, isNot(equals(warichu2)));
    });
  });

  group('TextDecorationAnnotation', () {
    test('should calculate endIndex correctly', () {
      const decoration = TextDecorationAnnotation(startIndex: 0, length: 5);
      expect(decoration.endIndex, 5);
    });

    test('should use sideline type by default', () {
      const decoration = TextDecorationAnnotation(startIndex: 0, length: 1);
      expect(decoration.type, TextDecorationLineType.sideline);
    });

    test('should implement equality correctly', () {
      const decoration1 = TextDecorationAnnotation(
        startIndex: 0,
        length: 3,
        type: TextDecorationLineType.wavySideline,
      );
      const decoration2 = TextDecorationAnnotation(
        startIndex: 0,
        length: 3,
        type: TextDecorationLineType.wavySideline,
      );
      const decoration3 = TextDecorationAnnotation(
        startIndex: 0,
        length: 3,
        type: TextDecorationLineType.sideline,
      );

      expect(decoration1, equals(decoration2));
      expect(decoration1, isNot(equals(decoration3)));
    });

    test('should have correct hashCode', () {
      const decoration1 = TextDecorationAnnotation(startIndex: 0, length: 3);
      const decoration2 = TextDecorationAnnotation(startIndex: 0, length: 3);

      expect(decoration1.hashCode, equals(decoration2.hashCode));
    });

    test('should support all decoration types', () {
      const types = TextDecorationLineType.values;
      expect(types, contains(TextDecorationLineType.sideline));
      expect(types, contains(TextDecorationLineType.doubleSideline));
      expect(types, contains(TextDecorationLineType.wavySideline));
      expect(types, contains(TextDecorationLineType.dottedSideline));
    });
  });

  group('VerticalTextStyle', () {
    test('should have correct default values', () {
      const style = VerticalTextStyle();

      expect(style.lineSpacing, 0.0);
      expect(style.characterSpacing, 0.0);
      expect(style.rotateLatinCharacters, true);
      expect(style.adjustYakumono, true);
      expect(style.enableKinsoku, true);
      expect(style.enableHalfWidthYakumono, true);
      expect(style.enableGyotoIndent, true);
      expect(style.enableKerning, true);
      expect(style.useVerticalGlyphs, false);
      expect(style.alignment, TextAlignment.start);
      expect(style.indent, 0);
      expect(style.firstLineIndent, 0);
    });

    test('copyWith should create new instance with updated values', () {
      const style = VerticalTextStyle(indent: 1);
      final copied = style.copyWith(indent: 2, firstLineIndent: 1);

      expect(copied.indent, 2);
      expect(copied.firstLineIndent, 1);
      expect(style.indent, 1); // Original should be unchanged
    });

    test('copyWith should preserve unmodified values', () {
      const style = VerticalTextStyle(
        lineSpacing: 5.0,
        characterSpacing: 2.0,
        indent: 1,
        firstLineIndent: 2,
      );
      final copied = style.copyWith(indent: 3);

      expect(copied.lineSpacing, 5.0);
      expect(copied.characterSpacing, 2.0);
      expect(copied.indent, 3);
      expect(copied.firstLineIndent, 2);
    });

    test('copyWith should handle all properties', () {
      const style = VerticalTextStyle();
      final copied = style.copyWith(
        lineSpacing: 10.0,
        characterSpacing: 5.0,
        rotateLatinCharacters: false,
        adjustYakumono: false,
        enableKinsoku: false,
        enableHalfWidthYakumono: false,
        enableGyotoIndent: false,
        enableKerning: false,
        useVerticalGlyphs: true,
        alignment: TextAlignment.end,
        indent: 2,
        firstLineIndent: 1,
      );

      expect(copied.lineSpacing, 10.0);
      expect(copied.characterSpacing, 5.0);
      expect(copied.rotateLatinCharacters, false);
      expect(copied.adjustYakumono, false);
      expect(copied.enableKinsoku, false);
      expect(copied.enableHalfWidthYakumono, false);
      expect(copied.enableGyotoIndent, false);
      expect(copied.enableKerning, false);
      expect(copied.useVerticalGlyphs, true);
      expect(copied.alignment, TextAlignment.end);
      expect(copied.indent, 2);
      expect(copied.firstLineIndent, 1);
    });

    test('withVerticalGlyphs factory should disable manual adjustments', () {
      final style = VerticalTextStyle.withVerticalGlyphs();

      expect(style.useVerticalGlyphs, true);
      expect(style.adjustYakumono, false);
      expect(style.enableHalfWidthYakumono, false);
      expect(style.enableGyotoIndent, false);
      expect(style.enableKerning, false);
    });

    test('indent and firstLineIndent should be independent', () {
      const style1 = VerticalTextStyle(indent: 2, firstLineIndent: 0);
      const style2 = VerticalTextStyle(indent: 0, firstLineIndent: 2);
      const style3 = VerticalTextStyle(indent: 2, firstLineIndent: 2);

      expect(style1.indent, 2);
      expect(style1.firstLineIndent, 0);
      expect(style2.indent, 0);
      expect(style2.firstLineIndent, 2);
      expect(style3.indent, 2);
      expect(style3.firstLineIndent, 2);
    });
  });
}
