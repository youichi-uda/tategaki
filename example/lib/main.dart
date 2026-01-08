import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tategaki Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TategakiDemo(),
    );
  }
}

class TategakiDemo extends StatelessWidget {
  const TategakiDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tategaki Demo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // Scroll from right to left
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Example 1: Simple vertical text
                VerticalText(
                  'これは縦書きテキストの例です。日本語の伝統的な文書では、このように縦書きで文字を配置します。',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                    characterSpacing: 4,
                    lineSpacing: 24,
                  ),
                  maxHeight: 400,
                ),
                const SizedBox(width: 32),

                // Example 2: With ruby (furigana)
                VerticalText(
                  '日本語',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 32, color: Colors.black87),
                    rubyStyle: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                  ruby: const [
                    RubyText(startIndex: 0, length: 3, ruby: 'にほんご'),
                  ],
                ),
                const SizedBox(width: 32),

                // Example 3: With rotated Latin characters
                VerticalText(
                  '2024年1月\nHello World\nこんにちは',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                    characterSpacing: 4,
                    rotateLatinCharacters: true,
                  ),
                  maxHeight: 400,
                ),
                const SizedBox(width: 32),

                // Example 4: Without rotation
                VerticalText(
                  '2024年1月\nABC123\nテスト',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                    characterSpacing: 4,
                    rotateLatinCharacters: false,
                  ),
                  maxHeight: 400,
                ),
                const SizedBox(width: 32),

                // Example 5: With kenten (emphasis dots)
                VerticalText(
                  '重要な内容です',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
                    characterSpacing: 6,
                  ),
                  kenten: const [
                    Kenten(startIndex: 0, length: 2, style: KentenStyle.filledCircle),
                  ],
                ),
                const SizedBox(width: 32),

                // Example 6: Different kenten styles
                VerticalText(
                  '様々な圏点スタイル',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                    characterSpacing: 4,
                  ),
                  kenten: const [
                    Kenten(startIndex: 0, length: 2, style: KentenStyle.sesame),
                    Kenten(startIndex: 3, length: 2, style: KentenStyle.circle),
                    Kenten(startIndex: 5, length: 3, style: KentenStyle.filledTriangle),
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
