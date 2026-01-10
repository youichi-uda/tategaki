import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class AlignmentDemo extends StatefulWidget {
  const AlignmentDemo({super.key});

  @override
  State<AlignmentDemo> createState() => _AlignmentDemoState();
}

class _AlignmentDemoState extends State<AlignmentDemo> {
  bool _showGrid = false;
  TextAlignment _alignment = TextAlignment.center;
  int _indent = 0;

  String get _alignmentLabel {
    switch (_alignment) {
      case TextAlignment.start:
        return '天付き（上揃え）';
      case TextAlignment.center:
        return '中央揃え';
      case TextAlignment.end:
        return '地付き（下揃え）';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('縦書きアライメント'),
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
                Text(
                  '縦書きアライメント: $_alignmentLabel',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _alignment = TextAlignment.start;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _alignment == TextAlignment.start
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      child: const Text('天付き'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _alignment = TextAlignment.center;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _alignment == TextAlignment.center
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      child: const Text('中央'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _alignment = TextAlignment.end;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _alignment == TextAlignment.end
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      child: const Text('地付き'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('字下げ: ', style: TextStyle(fontSize: 16)),
                    for (int i = 0; i <= 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _indent = i;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _indent == i
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            minimumSize: const Size(48, 36),
                          ),
                          child: Text('$i'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                  ),
                  child: VerticalText(
                    '吾輩は猫である。名前はまだ無い。\n'
                    'どこで生れたかとんと見当がつかぬ。\n'
                    '何でも薄暗いじめじめした所で\n'
                    'ニャーニャー泣いていた事だけは\n'
                    '記憶している。',
                    style: VerticalTextStyle(
                      baseStyle: GoogleFonts.notoSerifJp(
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                      characterSpacing: 4,
                      lineSpacing: 24,
                      alignment: _alignment,
                      indent: _indent,
                    ),
                    maxHeight: 400,
                    showGrid: _showGrid,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 500,
                  child: Text(
                    '説明：\n'
                    '• 天付き：行全体を上端に揃えます\n'
                    '• 中央揃え：行全体を中央に配置します\n'
                    '• 地付き：行全体を下端に揃えます\n'
                    '• 字下げ：各行の先頭をN文字分下げます',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
