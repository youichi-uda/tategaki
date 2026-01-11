import 'package:flutter/gestures.dart';
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
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
          },
        ),
        child: SingleChildScrollView(
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
              'ドラッグで範囲選択、ハンドルで調整、右クリック・長押しでメニュー表示。Ctrl+C/Ctrl+A対応。',
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
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: SelectableVerticalText(
                  text: '吾輩は猫である。名前はまだ無い。どこで生まれたか頓と見当がつかぬ。',
                  style: VerticalTextStyle(
                    baseStyle: const TextStyle(fontSize: 20),
                  ),
                  maxHeight: 300,
                ),
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
              child: Align(
                alignment: Alignment.topRight,
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
              child: Align(
                alignment: Alignment.topRight,
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
            ),

            const SizedBox(height: 32),

            // Selectable text with ruby AND kenten
            const Text(
              '選択可能テキスト + ルビ + 圏点',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: SelectableVerticalText(
                  text: '漢字は難しいが重要な文字である。',
                  rubyList: const [
                    RubyText(startIndex: 0, length: 2, ruby: 'かんじ'),
                    RubyText(startIndex: 3, length: 2, ruby: 'むずか'),
                    RubyText(startIndex: 7, length: 2, ruby: 'じゅうよう'),
                    RubyText(startIndex: 10, length: 2, ruby: 'もじ'),
                  ],
                  kentenList: const [
                    Kenten(startIndex: 0, length: 2, style: KentenStyle.sesame),
                    Kenten(startIndex: 7, length: 2, style: KentenStyle.filledCircle),
                  ],
                  style: VerticalTextStyle(
                    baseStyle: const TextStyle(fontSize: 22),
                    rubyStyle: const TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                  maxHeight: 300,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Long text with selection
            const Text(
              '長文での選択テスト',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: SelectableVerticalText(
                  text: '祇園精舎の鐘の声、諸行無常の響きあり。沙羅双樹の花の色、盛者必衰の理をあらわす。',
                  rubyList: const [
                    RubyText(startIndex: 0, length: 4, ruby: 'ぎおんしょうじゃ'),
                    RubyText(startIndex: 5, length: 1, ruby: 'かね'),
                    RubyText(startIndex: 7, length: 1, ruby: 'こえ'),
                    RubyText(startIndex: 9, length: 4, ruby: 'しょぎょうむじょう'),
                    RubyText(startIndex: 14, length: 1, ruby: 'ひび'),
                    RubyText(startIndex: 18, length: 4, ruby: 'しゃらそうじゅ'),
                    RubyText(startIndex: 23, length: 1, ruby: 'はな'),
                    RubyText(startIndex: 25, length: 1, ruby: 'いろ'),
                    RubyText(startIndex: 27, length: 4, ruby: 'じょうしゃひっすい'),
                    RubyText(startIndex: 32, length: 1, ruby: 'ことわり'),
                  ],
                  kentenList: const [
                    Kenten(startIndex: 9, length: 4, style: KentenStyle.sesame),
                    Kenten(startIndex: 27, length: 4, style: KentenStyle.filledCircle),
                  ],
                  style: VerticalTextStyle(
                    baseStyle: const TextStyle(fontSize: 20),
                    rubyStyle: const TextStyle(fontSize: 10, color: Colors.red),
                    lineSpacing: 8,
                  ),
                  maxHeight: 400,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Custom context menu
            const Text(
              'カスタムメニュー項目',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyan.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: SelectableVerticalText(
                  text: 'カスタムメニューのテスト。選択して右クリックしてみてください。',
                  style: VerticalTextStyle(
                    baseStyle: const TextStyle(fontSize: 20),
                  ),
                  maxHeight: 300,
                  additionalMenuItems: (context, selectedText) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 12),
                          Text('「$selectedText」を検索'),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('「$selectedText」を検索します')),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.translate, size: 20),
                          SizedBox(width: 12),
                          Text('翻訳'),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('「$selectedText」を翻訳します')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Rich text (not selectable yet)
            const Text(
              'リッチテキスト（複数スタイル）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ リッチテキストの選択機能は今後実装予定',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal.shade200),
                borderRadius: BorderRadius.circular(8),
                color: Colors.teal.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VerticalRichText(
                    textSpan: TextSpanV(
                      children: [
                        RubySpan(
                          text: '吾輩',
                          ruby: 'わがはい',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        TextSpanV(
                          text: 'は',
                          style: const TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    ),
                    maxHeight: 300,
                  ),
                  const SizedBox(width: 8),
                  VerticalRichText(
                    textSpan: TextSpanV(
                      children: [
                        KentenSpan(
                          text: '猫',
                          kentenStyle: KentenStyle.filledCircle,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        TextSpanV(
                          text: 'である。',
                          style: const TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    ),
                    maxHeight: 300,
                  ),
                  const SizedBox(width: 8),
                  VerticalRichText(
                    textSpan: TextSpanV(
                      children: [
                        RubySpan(
                          text: '名前',
                          ruby: 'なまえ',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.green),
                        ),
                        TextSpanV(
                          text: 'はまだ',
                          style: const TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      ],
                    ),
                    maxHeight: 300,
                  ),
                  const SizedBox(width: 8),
                  VerticalRichText(
                    textSpan: TextSpanV(
                      children: [
                        TextSpanV(
                          text: '無い',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                        TextSpanV(
                          text: '。',
                          style: const TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    ),
                    maxHeight: 300,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // SelectionArea integration
            const Text(
              'SelectionArea 統合（Selection API）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '他の SelectableText と一緒に SelectionArea 内で使用可能。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '横書きの説明文',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const SelectableText(
                      'これは通常のSelectableTextです。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '↓ 縦書きテキスト（SelectionAreaVerticalText）',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: SelectionAreaVerticalText(
                          text: '縦書きテキスト選択可能',
                          style: VerticalTextStyle(
                            baseStyle: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          maxHeight: 200,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SelectableText(
                      '上下のテキストをドラッグで一括選択できます。',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '使い方:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• ドラッグ: テキスト範囲を選択'),
                    const Text('• ハンドル: 選択範囲の両端をドラッグして調整'),
                    const Text('• 選択領域タップ: コンテキストメニューを表示'),
                    const Text('• 右クリック: コンテキストメニューを表示'),
                    const Text('• 長押し: コンテキストメニューを表示（モバイル）'),
                    const Text('• ダブルクリック: 全選択'),
                    const Text('• Ctrl+C: 選択テキストをコピー'),
                    const Text('• Ctrl+A: 全選択'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ヒント: ハンドルをドラッグすると、近くの文字に自動的にスナップします。',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
