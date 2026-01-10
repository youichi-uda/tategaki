import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class DecorationDemo extends StatefulWidget {
  const DecorationDemo({super.key});

  @override
  State<DecorationDemo> createState() => _DecorationDemoState();
}

class _DecorationDemoState extends State<DecorationDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('傍線（テキスト装飾）'),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDecorationExample(
                  '傍線',
                  'これは重要です',
                  TextDecorationLineType.sideline,
                ),
                const SizedBox(width: 48),
                _buildDecorationExample(
                  '二重傍線',
                  'これは重要です',
                  TextDecorationLineType.doubleSideline,
                ),
                const SizedBox(width: 48),
                _buildDecorationExample(
                  '波線',
                  'これは重要です',
                  TextDecorationLineType.wavySideline,
                ),
                const SizedBox(width: 48),
                _buildDecorationExample(
                  '点線',
                  'これは重要です',
                  TextDecorationLineType.dottedSideline,
                ),
                const SizedBox(width: 48),
                _buildCombinedExample(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorationExample(
    String title,
    String text,
    TextDecorationLineType type,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        VerticalText(
          text,
          style: VerticalTextStyle(
            baseStyle: GoogleFonts.notoSerifJp(
              fontSize: 28,
              color: Colors.black87,
            ),
            characterSpacing: 4,
          ),
          decorations: [
            TextDecorationAnnotation(
              startIndex: 3,
              length: 2,
              type: type,
            ),
          ],
          showGrid: _showGrid,
        ),
      ],
    );
  }

  Widget _buildCombinedExample() {
    return Column(
      children: [
        const Text(
          'ルビ+傍線',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        VerticalText(
          '東京は首都です',
          style: VerticalTextStyle(
            baseStyle: GoogleFonts.notoSerifJp(
              fontSize: 28,
              color: Colors.black87,
            ),
            characterSpacing: 4,
          ),
          ruby: [
            RubyText(startIndex: 0, length: 2, ruby: 'とうきょう'),
            RubyText(startIndex: 3, length: 2, ruby: 'しゅと'),
          ],
          decorations: [
            TextDecorationAnnotation(
              startIndex: 3,
              length: 2,
              type: TextDecorationLineType.sideline,
              color: Colors.red,
            ),
          ],
          showGrid: _showGrid,
        ),
      ],
    );
  }
}
