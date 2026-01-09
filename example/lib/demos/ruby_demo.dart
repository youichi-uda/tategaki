import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class RubyDemo extends StatelessWidget {
  const RubyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルビ（振り仮名）'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 40, color: Colors.black87),
                        rubyStyle: TextStyle(fontSize: 20, color: Colors.blue),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 3, ruby: 'にほんご'),
                      ],
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
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 36, color: Colors.black87),
                        rubyStyle: TextStyle(fontSize: 18, color: Colors.blue),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 2, ruby: 'かんじ'),
                        RubyText(startIndex: 3, length: 1, ruby: 'よ'),
                      ],
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
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 40, color: Colors.black87),
                        rubyStyle: TextStyle(fontSize: 20, color: Colors.blue),
                        characterSpacing: 6,
                      ),
                      ruby: const [
                        RubyText(startIndex: 0, length: 2, ruby: 'ばら'),
                      ],
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
