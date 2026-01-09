import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class KentenDemo extends StatelessWidget {
  const KentenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('圏点（強調マーク）'),
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
                _buildKentenExample('ゴマ点', 'これは重要です', KentenStyle.sesame),
                const SizedBox(width: 50),
                _buildKentenExample('黒丸', 'これは重要です', KentenStyle.filledCircle),
                const SizedBox(width: 50),
                _buildKentenExample('白丸', 'これは重要です', KentenStyle.circle),
                const SizedBox(width: 50),
                _buildKentenExample('黒三角', 'これは重要です', KentenStyle.filledTriangle),
                const SizedBox(width: 50),
                _buildKentenExample('白三角', 'これは重要です', KentenStyle.triangle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKentenExample(String title, String text, KentenStyle style) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        VerticalText(
          text,
          style: const VerticalTextStyle(
            baseStyle: TextStyle(fontSize: 32, color: Colors.black87),
            characterSpacing: 8,
          ),
          kenten: [
            Kenten(startIndex: 3, length: 2, style: style),
          ],
        ),
      ],
    );
  }
}
