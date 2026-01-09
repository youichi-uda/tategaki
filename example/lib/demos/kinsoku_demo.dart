import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class KinsokuDemo extends StatelessWidget {
  const KinsokuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('禁則処理（改行規則）'),
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
                  '適切な改行処理\n句読点が行頭に来ないように自動調整されます',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                VerticalText(
                  'これは禁則処理のデモです。行頭や行末に来てはいけない文字（句読点や括弧など）が適切に処理されます。「このように」括弧も正しく扱われます。',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                    characterSpacing: 4,
                    lineSpacing: 24,
                  ),
                  maxHeight: 350,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
