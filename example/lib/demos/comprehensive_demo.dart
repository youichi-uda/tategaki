import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

// 共通サンプルテキスト
const kComprehensiveDemoText = '昭和（1926年）12月25日―東京。「美しい日本語の組版」を実現する為に、様々な工夫が凝らされている。'
    'コンピュータ・システムによる自動組版技術は、活版印刷の時代から受け継がれてきた。'
    '小書き仮名（ゃゅょっ）、長音記号（ー）、各種ダッシュ記号（－―—–）の扱いは重要だ！　'
    '疑問符？　感嘆符！　句点。　読点、　中黒・　コロン：　セミコロン；　'
    '数字の処理も10個、25項目、99パーセントと多岐に渡る。2026年の技術革新。'
    'これらの文字種を適切に配置することで、読みやすく美しい縦書き文書が完成する。';

class ComprehensiveDemo extends StatefulWidget {
  const ComprehensiveDemo({super.key});

  @override
  State<ComprehensiveDemo> createState() => _ComprehensiveDemoState();
}

class _ComprehensiveDemoState extends State<ComprehensiveDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('総合デモ'),
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
                  'すべての機能を組み合わせた例（縦書きフィーチャー無効）',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                VerticalText(
                  kComprehensiveDemoText,
                  style: VerticalTextStyle(
                    baseStyle: GoogleFonts.notoSerifJp(
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                    characterSpacing: 4,
                    lineSpacing: 20,
                    enableKerning: true,
                    enableHalfWidthYakumono: true,
                    kinsokuMethod: KinsokuMethod.oikomi,
                    enableGyotoIndent: true,
                    adjustYakumono: true,
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
