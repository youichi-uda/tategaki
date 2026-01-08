import 'package:flutter_test/flutter_test.dart';
import 'package:tategaki/tategaki.dart';

void main() {
  group('CharacterClassifier', () {
    test('correctly classifies kanji', () {
      expect(CharacterClassifier.classify('漢'), CharacterType.kanji);
      expect(CharacterClassifier.classify('字'), CharacterType.kanji);
    });

    test('correctly classifies hiragana', () {
      expect(CharacterClassifier.classify('あ'), CharacterType.hiragana);
      expect(CharacterClassifier.classify('ん'), CharacterType.hiragana);
    });

    test('correctly classifies katakana', () {
      expect(CharacterClassifier.classify('ア'), CharacterType.katakana);
      expect(CharacterClassifier.classify('ン'), CharacterType.katakana);
    });

    test('correctly classifies latin characters', () {
      expect(CharacterClassifier.classify('A'), CharacterType.latin);
      expect(CharacterClassifier.classify('z'), CharacterType.latin);
    });

    test('correctly classifies numbers', () {
      expect(CharacterClassifier.classify('0'), CharacterType.number);
      expect(CharacterClassifier.classify('9'), CharacterType.number);
    });

    test('correctly classifies punctuation', () {
      expect(CharacterClassifier.classify('.'), CharacterType.punctuation);
      expect(CharacterClassifier.classify(','), CharacterType.punctuation);
    });

    test('correctly classifies yakumono', () {
      expect(CharacterClassifier.classify('。'), CharacterType.yakumono);
      expect(CharacterClassifier.classify('、'), CharacterType.yakumono);
      expect(CharacterClassifier.classify('「'), CharacterType.yakumono);
      expect(CharacterClassifier.classify('」'), CharacterType.yakumono);
    });

    test('correctly identifies small kana', () {
      expect(CharacterClassifier.isSmallKana('っ'), true);
      expect(CharacterClassifier.isSmallKana('ゃ'), true);
      expect(CharacterClassifier.isSmallKana('ゅ'), true);
      expect(CharacterClassifier.isSmallKana('ょ'), true);
      expect(CharacterClassifier.isSmallKana('あ'), false);
      expect(CharacterClassifier.isSmallKana('や'), false);
    });

    test('correctly determines rotation needs', () {
      // Yakumono that need rotation
      expect(CharacterClassifier.needsRotation('（'), true);
      expect(CharacterClassifier.needsRotation('）'), true);
      expect(CharacterClassifier.needsRotation('「'), true);

      // Characters that don't need rotation
      expect(CharacterClassifier.needsRotation('。'), false);
      expect(CharacterClassifier.needsRotation('、'), false);
      expect(CharacterClassifier.needsRotation('あ'), false);
    });
  });
}
