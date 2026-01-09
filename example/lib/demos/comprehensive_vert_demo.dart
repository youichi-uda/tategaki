import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';
import 'comprehensive_demo.dart';

class ComprehensiveVertDemo extends StatefulWidget {
  const ComprehensiveVertDemo({super.key});

  @override
  State<ComprehensiveVertDemo> createState() => _ComprehensiveVertDemoState();
}

class _ComprehensiveVertDemoState extends State<ComprehensiveVertDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('総合デモ（縦書きフィーチャー有効）'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
                    baseStyle: GoogleFonts.notoSerifJp(
                      fontSize: 22,
                      color: Colors.black87,
                      fontFeatures: const [
                        FontFeature.enable('vert'), // Vertical writing glyph substitution
                      ],
                    ),
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
