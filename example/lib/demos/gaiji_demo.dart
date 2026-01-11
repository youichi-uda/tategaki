import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class GaijiDemo extends StatefulWidget {
  const GaijiDemo({super.key});

  @override
  State<GaijiDemo> createState() => _GaijiDemoState();
}

class _GaijiDemoState extends State<GaijiDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('外字（画像文字）'),
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
                _buildGaijiExample(),
                const SizedBox(width: 60),
                _buildExplanation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGaijiExample() {
    return Column(
      children: [
        const Text(
          '外字の例',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        VerticalText(
          // 「挿」の旧字体「插」を画像で表示
          // プレースホルダーとして「〓」を使用
          '「〓入」の旧字体',
          style: VerticalTextStyle(
            baseStyle: GoogleFonts.notoSerifJp(
              fontSize: 32,
              color: Colors.black87,
            ),
            characterSpacing: 8,
          ),
          gaiji: [
            Gaiji(
              startIndex: 1, // 「〓」の位置
              image: const AssetImage('assets/image.png'),
            ),
          ],
          showGrid: _showGrid,
        ),
      ],
    );
  }

  Widget _buildExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '説明',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 300,
          child: Text(
            '外字（がいじ）とは、標準的な文字セットに含まれていない文字のことです。\n\n'
            '例えば、古い漢字の異体字、人名用の特殊な漢字、企業名の特殊文字などがあります。\n\n'
            'このデモでは、「挿」の旧字体「插」を画像として表示しています。\n\n'
            '使用方法:\n'
            '1. テキスト内にプレースホルダー文字（〓など）を配置\n'
            '2. Gaiji クラスでその位置と画像を指定\n'
            '3. 画像がフォントサイズに合わせて表示される',
            style: GoogleFonts.notoSansJp(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
