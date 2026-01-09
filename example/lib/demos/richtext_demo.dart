import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class RichTextDemo extends StatefulWidget {
  const RichTextDemo({super.key});

  @override
  State<RichTextDemo> createState() => _RichTextDemoState();
}

class _RichTextDemoState extends State<RichTextDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RichText（複数スタイル）'),
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
                  '複数のスタイルを組み合わせたテキスト',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                VerticalRichText(
                  textSpan: VerticalTextSpan(
                    style: VerticalTextStyle(
                      baseStyle: GoogleFonts.notoSerifJp(
                        fontSize: 24,
                        color: Colors.black87,
                        fontFeatures: const [
                          FontFeature.enable('vert'),
                        ],
                      ),
                      characterSpacing: 4,
                    ),
                    children: [
                      VerticalTextSpan(text: 'これは'),
                      VerticalTextSpan(
                        text: '強調された',
                        style: VerticalTextStyle(
                          baseStyle: GoogleFonts.notoSerifJp(
                            fontSize: 26,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [
                              FontFeature.enable('vert'),
                            ],
                          ),
                          characterSpacing: 4,
                        ),
                      ),
                      VerticalTextSpan(text: 'テキストと'),
                      VerticalTextSpan(
                        text: '青色の',
                        style: VerticalTextStyle(
                          baseStyle: GoogleFonts.notoSerifJp(
                            fontSize: 24,
                            color: Colors.blue,
                            fontFeatures: const [
                              FontFeature.enable('vert'),
                            ],
                          ),
                          characterSpacing: 4,
                        ),
                      ),
                      VerticalTextSpan(text: 'テキストを'),
                      VerticalTextSpan(
                        text: '組み合わせた',
                        style: VerticalTextStyle(
                          baseStyle: GoogleFonts.notoSerifJp(
                            fontSize: 28,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontFeatures: const [
                              FontFeature.enable('vert'),
                            ],
                          ),
                          characterSpacing: 4,
                        ),
                      ),
                      VerticalTextSpan(text: '例です。'),
                    ],
                  ),
                  maxHeight: 450,
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
