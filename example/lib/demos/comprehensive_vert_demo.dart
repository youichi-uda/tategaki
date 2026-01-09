import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';
import 'comprehensive_demo.dart';

class ComprehensiveVertDemo extends StatefulWidget {
  final String initialFont;

  const ComprehensiveVertDemo({super.key, this.initialFont = 'Noto Serif JP'});

  @override
  State<ComprehensiveVertDemo> createState() => _ComprehensiveVertDemoState();
}

class _ComprehensiveVertDemoState extends State<ComprehensiveVertDemo> {
  bool _showGrid = false;
  late String _selectedFont;

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.initialFont;
  }

  TextStyle _getFontStyle() {
    final baseStyle = switch (_selectedFont) {
      'Noto Sans JP' => GoogleFonts.notoSansJp(fontSize: 22, color: Colors.black87),
      'Shippori Mincho' => GoogleFonts.shipporiMincho(fontSize: 22, color: Colors.black87),
      'Klee One' => GoogleFonts.kleeOne(fontSize: 22, color: Colors.black87),
      'Zen Old Mincho' => GoogleFonts.zenOldMincho(fontSize: 22, color: Colors.black87),
      _ => GoogleFonts.notoSerifJp(fontSize: 22, color: Colors.black87),
    };

    return baseStyle.copyWith(
      fontFeatures: const [
        FontFeature.enable('vert'), // Vertical writing glyph substitution
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('総合デモ（縦書きフィーチャー有効）'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          DropdownButton<String>(
            value: _selectedFont,
            dropdownColor: Theme.of(context).colorScheme.inversePrimary,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'Noto Serif JP', child: Text('明朝 (Serif)')),
              DropdownMenuItem(value: 'Noto Sans JP', child: Text('ゴシック (Sans)')),
              DropdownMenuItem(value: 'Shippori Mincho', child: Text('しっぽり明朝')),
              DropdownMenuItem(value: 'Klee One', child: Text('クレー')),
              DropdownMenuItem(value: 'Zen Old Mincho', child: Text('禅明朝')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedFont = value;
                });
              }
            },
          ),
          const SizedBox(width: 8),
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
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              children: [
                const Text(
                  'OpenType vert機能による縦書き\n約物調整は無効、長音記号の回転のみ有効',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                VerticalText(
                  kComprehensiveDemoText,
                  style: VerticalTextStyle(
                    baseStyle: _getFontStyle(),
                    characterSpacing: 4,
                    lineSpacing: 20,
                    // OpenType vert機能に依存、約物調整は無効
                    rotateLatinCharacters: true,
                    adjustYakumono: false,
                    enableKerning: false,
                    enableHalfWidthYakumono: false,
                    enableGyotoIndent: false,
                    kinsokuMethod: KinsokuMethod.oikomi,
                    useVerticalGlyphs: true, // フォントの縦書きグリフを使用（一部長音は回転）
                  ),
                  autoTatechuyoko: true,
                  maxHeight: 400,
                  showGrid: _showGrid,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
