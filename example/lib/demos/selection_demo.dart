import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class SelectionDemo extends StatelessWidget {
  const SelectionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テキスト選択デモ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Text Selection Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'タップまたはドラッグでテキストを選択できます。長押しでコピーメニューが表示されます。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Basic selectable text
            const Text(
              '基本的な選択可能テキスト',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableVerticalText(
                text: '吾輩は猫である。名前はまだ無い。どこで生まれたか頓と見当がつかぬ。',
                style: VerticalTextStyle(
                  baseStyle: const TextStyle(fontSize: 20),
                ),
                maxHeight: 300,
              ),
            ),

            const SizedBox(height: 32),

            // Selectable text with ruby
            const Text(
              '選択可能テキスト + ルビ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableVerticalText(
                text: '日本語の縦書きテキストです。',
                rubyList: const [
                  RubyText(startIndex: 0, length: 3, ruby: 'にほんご'),
                  RubyText(startIndex: 4, length: 3, ruby: 'たてが'),
                ],
                style: VerticalTextStyle(
                  baseStyle: const TextStyle(fontSize: 24),
                  rubyStyle: const TextStyle(fontSize: 12, color: Colors.red),
                ),
                maxHeight: 200,
              ),
            ),

            const SizedBox(height: 32),

            // Selectable text with kenten
            const Text(
              '選択可能テキスト + 圏点',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableVerticalText(
                text: '重要な部分に圏点を付けることができます。',
                kentenList: const [
                  Kenten(startIndex: 0, length: 2, style: KentenStyle.sesame),
                  Kenten(startIndex: 6, length: 2, style: KentenStyle.filledCircle),
                ],
                style: VerticalTextStyle(
                  baseStyle: const TextStyle(fontSize: 22),
                ),
                maxHeight: 250,
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使い方:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• タップ: 1文字を選択'),
                    Text('• ドラッグ: テキスト範囲を選択'),
                    Text('• 長押し: コピーメニューを表示'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
