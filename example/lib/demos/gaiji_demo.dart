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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 例1: 短いテキスト
        Column(
          children: [
            const Text(
              '短文',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            VerticalText(
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
                  startIndex: 1,
                  image: const AssetImage('assets/image.png'),
                ),
              ],
              showGrid: _showGrid,
            ),
          ],
        ),
        const SizedBox(width: 40),
        // 例2: 長いテキストの途中に外字
        Column(
          children: [
            const Text(
              '長文（途中に外字）',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            VerticalText(
              '日本語の文章の中に〓入という旧字体を使った例文です。',
              style: VerticalTextStyle(
                baseStyle: GoogleFonts.notoSerifJp(
                  fontSize: 28,
                  color: Colors.black87,
                ),
                characterSpacing: 4,
              ),
              gaiji: [
                Gaiji(
                  startIndex: 9, // 「〓」の位置（0から数えて9番目）
                  image: const AssetImage('assets/image.png'),
                ),
              ],
              showGrid: _showGrid,
              maxHeight: 400,
            ),
          ],
        ),
        const SizedBox(width: 40),
        // 例3: さらに長いテキスト
        Column(
          children: [
            const Text(
              '長文（複数行）',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            VerticalText(
              '昔々あるところに、〓入という技術を持つ職人がいました。その職人は毎日丁寧に仕事をしていました。',
              style: VerticalTextStyle(
                baseStyle: GoogleFonts.notoSerifJp(
                  fontSize: 24,
                  color: Colors.black87,
                ),
                characterSpacing: 2,
              ),
              gaiji: [
                Gaiji(
                  startIndex: 9, // 「〓」の位置（0から数えて9番目: 昔々あるところに、〓）
                  image: const AssetImage('assets/image.png'),
                ),
              ],
              showGrid: _showGrid,
              maxHeight: 350,
            ),
          ],
        ),
        const SizedBox(width: 40),
        // 例4: 小さいフォントサイズ
        Column(
          children: [
            const Text(
              '小フォント',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            VerticalText(
              'この文章には〓入という外字が含まれています。',
              style: VerticalTextStyle(
                baseStyle: GoogleFonts.notoSerifJp(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                characterSpacing: 2,
              ),
              gaiji: [
                Gaiji(
                  startIndex: 6,
                  image: const AssetImage('assets/image.png'),
                ),
              ],
              showGrid: _showGrid,
              maxHeight: 300,
            ),
          ],
        ),
        const SizedBox(width: 40),
        // 例5: 改行後に外字（2行目の先頭付近）
        Column(
          children: [
            const Text(
              '改行後に外字',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            VerticalText(
              'あいうえおかきくけこ〓入さしすせそ', // 〓は10番目、maxHeight=200で2行目に来る
              style: VerticalTextStyle(
                baseStyle: GoogleFonts.notoSerifJp(
                  fontSize: 28,
                  color: Colors.black87,
                ),
                characterSpacing: 4,
              ),
              gaiji: [
                Gaiji(
                  startIndex: 10, // 「〓」の位置（0から数えて10番目）
                  image: const AssetImage('assets/image.png'),
                ),
              ],
              showGrid: _showGrid,
              maxHeight: 200, // 短いmaxHeightで強制的に改行
            ),
          ],
        ),
        const SizedBox(width: 40),
        // 例6: 改行後に外字（3行目）
        Column(
          children: [
            const Text(
              '3行目に外字',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            VerticalText(
              'あいうえおかきくけこさしすせそたちつてと〓入なにぬねの', // 〓は20番目
              style: VerticalTextStyle(
                baseStyle: GoogleFonts.notoSerifJp(
                  fontSize: 24,
                  color: Colors.black87,
                ),
                characterSpacing: 2,
              ),
              gaiji: [
                Gaiji(
                  startIndex: 20, // 「〓」の位置（0から数えて20番目）
                  image: const AssetImage('assets/image.png'),
                ),
              ],
              showGrid: _showGrid,
              maxHeight: 200, // 短いmaxHeightで複数行に
            ),
          ],
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
