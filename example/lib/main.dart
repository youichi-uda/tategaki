import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'demos/basic_demo.dart';
import 'demos/ruby_demo.dart';
import 'demos/kenten_demo.dart';
import 'demos/tatechuyoko_demo.dart';
import 'demos/kinsoku_demo.dart';
import 'demos/yakumono_demo.dart';
import 'demos/richtext_demo.dart';
import 'demos/comprehensive_demo.dart';
import 'demos/comprehensive_vert_demo.dart';

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
        textTheme: GoogleFonts.notoSerifJpTextTheme(),
      ),
      home: const TategakiDemoHome(),
    );
  }
}

class TategakiDemoHome extends StatelessWidget {
  const TategakiDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tategaki デモ'),
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
            title: '総合デモ（標準）',
            description: '全機能 - 回転・位置調整あり',
            icon: Icons.auto_awesome,
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComprehensiveDemo()),
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
              MaterialPageRoute(builder: (context) => const ComprehensiveVertDemo()),
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
          backgroundColor: color.withOpacity(0.2),
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
