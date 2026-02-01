import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class FallbackFontDemo extends StatefulWidget {
  const FallbackFontDemo({super.key});

  @override
  State<FallbackFontDemo> createState() => _FallbackFontDemoState();
}

class _FallbackFontDemoState extends State<FallbackFontDemo> {
  bool _showGrid = false;
  bool _useFallback = true;

  // U+24103（𤄃）はCJK統合漢字拡張Bに含まれる文字（サロゲートペア）
  // 通常のフォントでは表示できない
  static const String _sampleText = '𤄃歩する。\n街を𤄃歩。';

  @override
  Widget build(BuildContext context) {
    // Kosugi Maru (Google Fonts) - CJK拡張B文字を含まないフォント
    final baseStyle = GoogleFonts.kosugiMaru(
      fontSize: 32,
      color: const Color(0xFF1A1A1A),
      height: 1.0,
    ).copyWith(
      fontFamilyFallback: _useFallback
          ? ['Noto Serif JP', 'Noto Sans JP']
          : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('フォールバックフォント'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _useFallback = !_useFallback;
              });
            },
            icon: Icon(
              _useFallback ? Icons.check_box : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            label: Text(
              'Fallback: ${_useFallback ? "ON" : "OFF"}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
            icon: Icon(
              _showGrid ? Icons.grid_off : Icons.grid_on,
              color: Colors.white,
            ),
            label: Text(
              _showGrid ? 'グリッドOFF' : 'グリッドON',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFAF8F5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '𤄃 (U+24103) はCJK拡張B文字（サロゲートペア）\n'
                'fontFamily: Kosugi Maru\n'
                'fontFamilyFallback: ${_useFallback ? "['Noto Serif JP']" : "なし（システムフォールバック）"}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                  child: VerticalText(
                    key: ValueKey('fallback_$_useFallback'),
                    _sampleText,
                    style: VerticalTextStyle(
                      baseStyle: baseStyle,
                      characterSpacing: 4,
                      lineSpacing: 40,
                    ),
                    maxHeight: 400,
                    showGrid: _showGrid,
                  ),
                ),
              ),
            ),
            // 比較用：Flutter標準のText
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                children: [
                  const Text('比較：Flutter標準Text（横書き）'),
                  const SizedBox(height: 8),
                  Text(
                    _sampleText.replaceAll('\n', ' '),
                    style: baseStyle.copyWith(fontSize: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
