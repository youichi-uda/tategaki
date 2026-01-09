import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class RubyDemo extends StatefulWidget {
  const RubyDemo({super.key});

  @override
  State<RubyDemo> createState() => _RubyDemoState();
}

class _RubyDemoState extends State<RubyDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルビ（振り仮名）'),
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
                Column(
                  children: [
                    const Text(
                      '基本的なルビ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '日本語',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 40,
                          color: Colors.black87,
                        ),
                        rubyStyle: const TextStyle(fontSize: 20, color: Colors.blue),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 3, ruby: 'にほんご'),
                      ],
                      showGrid: _showGrid,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '複数のルビ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '漢字を読む',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 36,
                          color: Colors.black87,
                        ),
                        rubyStyle: const TextStyle(fontSize: 18, color: Colors.blue),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 2, ruby: 'かんじ'),
                        RubyText(startIndex: 3, length: 1, ruby: 'よ'),
                      ],
                      showGrid: _showGrid,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '長いルビ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '薔薇',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 40,
                          color: Colors.black87,
                        ),
                        rubyStyle: const TextStyle(fontSize: 20, color: Colors.blue),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 2, ruby: 'ばら'),
                      ],
                      showGrid: _showGrid,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '改行を含むルビ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '日本国憲法第九条',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 36,
                          color: Colors.black87,
                        ),
                        rubyStyle: const TextStyle(fontSize: 18, color: Colors.blue),
                        characterSpacing: 6,
                        lineSpacing: 40,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 8, ruby: 'にほんこくけんぽうだいきゅうじょう'),
                      ],
                      maxHeight: 200,
                      showGrid: _showGrid,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
