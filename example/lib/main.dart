import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'demos/basic_demo.dart';
import 'demos/ruby_demo.dart';
import 'demos/kenten_demo.dart';
import 'demos/warichu_demo.dart';
import 'demos/tatechuyoko_demo.dart';
import 'demos/kinsoku_demo.dart';
import 'demos/yakumono_demo.dart';
import 'demos/richtext_demo.dart';
import 'demos/selection_demo.dart';
import 'demos/alignment_demo.dart';
import 'demos/decoration_demo.dart';
import 'demos/gaiji_demo.dart';
import 'demos/comprehensive_demo.dart';
import 'demos/comprehensive_vert_demo.dart';
import 'demos/fallback_font_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String _selectedFont = 'Noto Serif JP';

  void setFont(String fontName) {
    setState(() {
      _selectedFont = fontName;
    });
  }

  TextTheme _getTextTheme() {
    switch (_selectedFont) {
      case 'Noto Sans JP':
        return GoogleFonts.notoSansJpTextTheme();
      case 'Shippori Mincho':
        return GoogleFonts.shipporiMinchoTextTheme();
      case 'Klee One':
        return GoogleFonts.kleeOneTextTheme();
      case 'Zen Old Mincho':
        return GoogleFonts.zenOldMinchoTextTheme();
      case 'Noto Serif JP':
      default:
        return GoogleFonts.notoSerifJpTextTheme();
    }
  }

  String get selectedFont => _selectedFont;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tategaki Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: _getTextTheme(),
      ),
      home: const TategakiDemoHome(),
    );
  }
}

class TategakiDemoHome extends StatefulWidget {
  const TategakiDemoHome({super.key});

  @override
  State<TategakiDemoHome> createState() => _TategakiDemoHomeState();
}

class _TategakiDemoHomeState extends State<TategakiDemoHome> {
  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);
    final selectedFont = appState?.selectedFont ?? 'Noto Serif JP';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tategaki デモ'),
        actions: [
          const Text(
            'フォント: ',
            style: TextStyle(color: Colors.white),
          ),
          DropdownButton<String>(
            value: selectedFont,
            dropdownColor: Theme.of(context).colorScheme.inversePrimary,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'Noto Serif JP', child: Text('明朝')),
              DropdownMenuItem(value: 'Noto Sans JP', child: Text('ゴシック')),
              DropdownMenuItem(value: 'Shippori Mincho', child: Text('しっぽり')),
              DropdownMenuItem(value: 'Klee One', child: Text('クレー')),
              DropdownMenuItem(value: 'Zen Old Mincho', child: Text('禅明朝')),
            ],
            onChanged: (value) {
              if (value != null) {
                appState?.setFont(value);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '各機能を個別に確認できます',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          _buildDemoCard(
            context,
            title: '基本的な縦書き',
            description: 'シンプルな縦書きテキストの表示',
            icon: Icons.text_fields,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BasicDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: 'ルビ（振り仮名）',
            description: '漢字にふりがなを付ける',
            icon: Icons.font_download,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RubyDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '圏点（強調マーク）',
            description: '文字を強調するための記号',
            icon: Icons.fiber_manual_record,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KentenDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '割注（インライン注釈）',
            description: '本文中に小さな2行の注釈を表示',
            icon: Icons.notes,
            color: Colors.amber,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WarichuDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '傍線（テキスト装飾）',
            description: '文字の横に線を引いて強調',
            icon: Icons.format_underline,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DecorationDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '縦中横（横組み）',
            description: '縦書き中に横向きに配置する数字',
            icon: Icons.format_align_center,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TatechuyokoDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '禁則処理',
            description: '適切な改行ルールの適用',
            icon: Icons.wrap_text,
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KinsokuDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '約物調整',
            description: '句読点の位置と間隔の最適化',
            icon: Icons.format_quote,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const YakumonoDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: 'RichText（複数スタイル）',
            description: '色やフォントを組み合わせたテキスト',
            icon: Icons.palette,
            color: Colors.pink,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RichTextDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: 'テキスト選択',
            description: 'ドラッグで選択・長押しでコピー',
            icon: Icons.select_all,
            color: Colors.cyan,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SelectionDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: 'アライメント（地付き）',
            description: '行全体の配置：天付き・中央・地付き',
            icon: Icons.align_vertical_bottom,
            color: Colors.brown,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AlignmentDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '外字（画像文字）',
            description: 'フォントにない文字を画像で表示',
            icon: Icons.image,
            color: Colors.lime,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GaijiDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: 'フォールバックフォント',
            description: 'CJK拡張B文字のフォールバック表示',
            icon: Icons.font_download_off,
            color: Colors.grey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FallbackFontDemo()),
            ),
          ),
          _buildDemoCard(
            context,
            title: '総合デモ（標準）',
            description: '全機能 - 回転・位置調整あり',
            icon: Icons.auto_awesome,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComprehensiveDemo(initialFont: selectedFont),
              ),
            ),
          ),
          _buildDemoCard(
            context,
            title: '総合デモ（縦書きフィーチャー）',
            description: 'OpenType vert機能 - 全機能有効',
            icon: Icons.font_download,
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComprehensiveVertDemo(initialFont: selectedFont),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
