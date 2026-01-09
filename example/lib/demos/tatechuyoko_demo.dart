import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class TatechuyokoDemo extends StatelessWidget {
  const TatechuyokoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('縦中横（横組み）'),
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
                      '自動縦中横（オフ）',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '令和06年12月25日',
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
                        characterSpacing: 6,
                      ),
                      autoTatechuyoko: false,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '自動縦中横（オン）',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '令和06年12月25日',
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
                        characterSpacing: 6,
                      ),
                      autoTatechuyoko: true,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '時刻表示',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '午後03時45分',
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
                        characterSpacing: 6,
                      ),
                      autoTatechuyoko: true,
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
