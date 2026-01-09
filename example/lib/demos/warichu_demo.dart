import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class WarichuDemo extends StatefulWidget {
  const WarichuDemo({super.key});

  @override
  State<WarichuDemo> createState() => _WarichuDemoState();
}

class _WarichuDemoState extends State<WarichuDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('割注（インライン注釈）'),
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
                _buildWarichuExample(
                  '基本的な割注',
                  TextSpanV(
                    children: [
                      TextSpanV(text: '割注（'),
                      WarichuSpan(
                        text: '本文中に組み込む注のこと',
                        splitIndex: 7,
                      ),
                      TextSpanV(text: '）とは何か'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                _buildWarichuExample(
                  '複数の割注',
                  TextSpanV(
                    children: [
                      RubySpan(text: '東京', ruby: 'とうきょう'),
                      TextSpanV(text: 'と'),
                      RubySpan(text: '大阪', ruby: 'おおさか'),
                      TextSpanV(text: 'は日本の大都市である。'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                _buildWarichuExample(
                  '読み仮名',
                  TextSpanV(
                    children: [
                      RubySpan(text: '夏目漱石', ruby: 'なつめそうせき'),
                      TextSpanV(text: 'は明治時代の文豪である。'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                _buildWarichuExample(
                  '長い注釈',
                  TextSpanV(
                    children: [
                      RubySpan(text: '芥川龍之介', ruby: 'あくたがわりゅうのすけ'),
                      TextSpanV(text: 'の代表作。'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarichuExample(
    String title,
    VerticalTextSpan span,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        VerticalText.rich(
          span,
          style: VerticalTextStyle(
            baseStyle: GoogleFonts.notoSerifJp(
              fontSize: 32,
              color: Colors.black87,
            ),
            characterSpacing: 8,
          ),
          showGrid: _showGrid,
        ),
      ],
    );
  }
}
