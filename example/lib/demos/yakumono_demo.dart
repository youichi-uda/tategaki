import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class YakumonoDemo extends StatefulWidget {
  const YakumonoDemo({super.key});

  @override
  State<YakumonoDemo> createState() => _YakumonoDemoState();
}

class _YakumonoDemoState extends State<YakumonoDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('約物調整'),
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
                      '約物調整なし',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '「これは、約物調整の例です。」と彼は言った。',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                        characterSpacing: 4,
                        lineSpacing: 24,
                        adjustYakumono: false,
                      ),
                      maxHeight: 400,
                      showGrid: _showGrid,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '約物調整あり',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '「これは、約物調整の例です。」と彼は言った。',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                        characterSpacing: 4,
                        lineSpacing: 24,
                        enableHalfWidthYakumono: true,
                        adjustYakumono: true,
                      ),
                      maxHeight: 400,
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
