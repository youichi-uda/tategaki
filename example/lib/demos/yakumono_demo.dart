import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class YakumonoDemo extends StatelessWidget {
  const YakumonoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('約物調整'),
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
                      '約物調整なし',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '「これは、約物調整の例です。」と彼は言った。',
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                        characterSpacing: 4,
                        lineSpacing: 24,
                        adjustYakumono: false,
                      ),
                      maxHeight: 400,
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
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                        characterSpacing: 4,
                        lineSpacing: 24,
                        enableHalfWidthYakumono: true,
                        adjustYakumono: true,
                      ),
                      maxHeight: 400,
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
