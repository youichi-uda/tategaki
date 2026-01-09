import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class RichTextDemo extends StatelessWidget {
  const RichTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RichText（複数スタイル）'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    style: const VerticalTextStyle(
                      baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                      characterSpacing: 4,
                    ),
                    children: [
                      const VerticalTextSpan(text: 'これは'),
                      VerticalTextSpan(
                        text: '強調された',
                        style: const VerticalTextStyle(
                          baseStyle: TextStyle(
                            fontSize: 26,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          characterSpacing: 4,
                        ),
                      ),
                      const VerticalTextSpan(text: 'テキストと'),
                      VerticalTextSpan(
                        text: '青色の',
                        style: const VerticalTextStyle(
                          baseStyle: TextStyle(
                            fontSize: 24,
                            color: Colors.blue,
                          ),
                          characterSpacing: 4,
                        ),
                      ),
                      const VerticalTextSpan(text: 'テキストを'),
                      VerticalTextSpan(
                        text: '組み合わせた',
                        style: const VerticalTextStyle(
                          baseStyle: TextStyle(
                            fontSize: 28,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                          characterSpacing: 4,
                        ),
                      ),
                      const VerticalTextSpan(text: '例です。'),
                    ],
                  ),
                  maxHeight: 450,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
