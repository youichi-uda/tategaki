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
                  '複数スタイルの組み合わせデモ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '色、サイズ、太字、ルビ、圏点を自由に組み合わせられます',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 5列目（左端）: 重要な文字（オレンジ色・ルビ+圏点）
                    VerticalText(
                      '重要な文字です',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade800,
                        ),
                        rubyStyle: GoogleFonts.notoSerifJp(
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 2, ruby: 'じゅうよう'),
                        RubyText(startIndex: 3, length: 2, ruby: 'もじ'),
                      ],
                      kenten: const [
                        Kenten(startIndex: 0, length: 2, style: KentenStyle.filledCircle),
                        Kenten(startIndex: 3, length: 2, style: KentenStyle.sesame),
                      ],
                      maxHeight: 450,
                      showGrid: _showGrid,
                    ),
                    const SizedBox(width: 32),

                    // 4列目: 無い。（紫色・太字）
                    VerticalText(
                      '無い。',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade600,
                        ),
                        characterSpacing: 8,
                      ),
                      maxHeight: 450,
                      showGrid: _showGrid,
                    ),
                    const SizedBox(width: 16),

                    // 3列目: 名前はまだ（緑色・太字・ルビ付き）
                    VerticalText(
                      '名前はまだ',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 2, ruby: 'なまえ'),
                      ],
                      maxHeight: 450,
                      showGrid: _showGrid,
                    ),
                    const SizedBox(width: 16),

                    // 2列目: 猫である。（青色・太字・圏点付き）
                    VerticalText(
                      '猫である。',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        characterSpacing: 8,
                      ),
                      kenten: const [
                        Kenten(startIndex: 0, length: 1, style: KentenStyle.filledCircle),
                      ],
                      maxHeight: 450,
                      showGrid: _showGrid,
                    ),
                    const SizedBox(width: 16),

                    // 1列目（右端）: 吾輩は（赤色・太字・ルビ付き）
                    VerticalText(
                      '吾輩は',
                      style: VerticalTextStyle(
                        baseStyle: GoogleFonts.notoSerifJp(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        characterSpacing: 8,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 2, ruby: 'わがはい'),
                      ],
                      maxHeight: 450,
                      showGrid: _showGrid,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '各列の特徴:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('1列目「吾輩は」: 赤色・太字・サイズ36・ルビ付き', style: TextStyle(fontSize: 12)),
                      Text('2列目「猫である。」: 青色・太字・サイズ36・圏点付き', style: TextStyle(fontSize: 12)),
                      Text('3列目「名前はまだ」: 緑色・太字・サイズ28・ルビ付き', style: TextStyle(fontSize: 12)),
                      Text('4列目「無い。」: 紫色・太字・サイズ32', style: TextStyle(fontSize: 12)),
                      Text('5列目「重要な文字です」: オレンジ色・サイズ28・ルビ+圏点の組み合わせ', style: TextStyle(fontSize: 12)),
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
}
