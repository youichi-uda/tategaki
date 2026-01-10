import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

// 共通サンプルテキスト（全機能を含む）
const kComprehensiveDemoText = '昭和（1926年）12月25日―東京。「美しい日本語の組版」を実現する為に、様々な工夫が凝らされている。'
    'コンピュータ・システムによる自動組版技術は、活版印刷の時代から受け継がれてきた。'
    '小書き仮名（ゃゅょっ）、長音記号（ー）、各種ダッシュ記号（－―—–）の扱いは重要だ！　'
    '疑問符？　感嘆符！　句点。　読点、　中黒・　コロン：　セミコロン；　'
    '数字の処理も10個、25項目、99パーセントと多岐に渡る。2026年の技術革新。'
    'アルファベットはAB、CD、XYなども縦中横で横組みに。ABCのような3文字以上は縦並び。'
    '三点リーダー……と二点リーダー‥‥は必ずペアで使用される。'
    '驚きや強調には！！や？？を使うこともある。本当に!?　信じられない!?'
    '我々は踊り字も正しく表示できる。人々、時々、様々など。';

class ComprehensiveDemo extends StatefulWidget {
  final String initialFont;

  const ComprehensiveDemo({super.key, this.initialFont = 'Noto Serif JP'});

  @override
  State<ComprehensiveDemo> createState() => _ComprehensiveDemoState();
}

class _ComprehensiveDemoState extends State<ComprehensiveDemo> {
  bool _showGrid = false;
  late String _selectedFont;
  double _maxHeight = 400.0; // Default height

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.initialFont;
  }

  TextStyle _getFontStyle() {
    switch (_selectedFont) {
      case 'Noto Sans JP':
        return GoogleFonts.notoSansJp(fontSize: 22, color: Colors.black87);
      case 'Shippori Mincho':
        return GoogleFonts.shipporiMincho(fontSize: 22, color: Colors.black87);
      case 'Klee One':
        return GoogleFonts.kleeOne(fontSize: 22, color: Colors.black87);
      case 'Zen Old Mincho':
        return GoogleFonts.zenOldMincho(fontSize: 22, color: Colors.black87);
      case 'Noto Serif JP':
      default:
        return GoogleFonts.notoSerifJp(fontSize: 22, color: Colors.black87);
    }
  }

  VerticalTextSpan _buildComprehensiveSpan() {
    return TextSpanV(
      children: [
        RubySpan(text: '日本語', ruby: 'にほんご'),
        TextSpanV(text: 'の'),
        KentenSpan(text: '縦書き', kentenStyle: KentenStyle.sesame),
        TextSpanV(text: '組版（'),
        WarichuSpan(text: 'たてがきくみはん', splitIndex: 4),
        TextSpanV(text: '）は、'),
        RubySpan(text: '美', ruby: 'うつく'),
        TextSpanV(text: 'しい'),
        RubySpan(text: '表現', ruby: 'ひょうげん'),
        TextSpanV(text: 'を'),
        RubySpan(text: '可能', ruby: 'かのう'),
        TextSpanV(text: 'にする。'),
        KentenSpan(text: '重要', kentenStyle: KentenStyle.sesame),
        TextSpanV(text: 'な'),
        RubySpan(text: '技術', ruby: 'ぎじゅつ'),
        TextSpanV(text: 'だ！　'),
        TextSpanV(text: kComprehensiveDemoText),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('総合デモ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          DropdownButton<String>(
            value: _selectedFont,
            dropdownColor: Theme.of(context).colorScheme.inversePrimary,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'Noto Serif JP', child: Text('明朝 (Serif)')),
              DropdownMenuItem(value: 'Noto Sans JP', child: Text('ゴシック (Sans)')),
              DropdownMenuItem(value: 'Shippori Mincho', child: Text('しっぽり明朝')),
              DropdownMenuItem(value: 'Klee One', child: Text('クレー')),
              DropdownMenuItem(value: 'Zen Old Mincho', child: Text('禅明朝')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedFont = value;
                });
              }
            },
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
            icon: Icon(
              _showGrid ? Icons.grid_off : Icons.grid_on,
              color: Colors.white,
            ),
            label: Text(
              _showGrid ? 'グリッドOFF' : 'グリッドON',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
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
                  '総合デモ（ルビ・圏点・割注・縦中横・禁則処理）',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Height adjustment
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('描画領域の高さ：'),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _maxHeight > 100
                          ? () {
                              setState(() {
                                _maxHeight = (_maxHeight - 10).clamp(100, 800);
                              });
                            }
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_maxHeight.round()}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _maxHeight < 800
                          ? () {
                              setState(() {
                                _maxHeight = (_maxHeight + 10).clamp(100, 800);
                              });
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                VerticalText.rich(
                  _buildComprehensiveSpan(),
                  style: VerticalTextStyle(
                    baseStyle: _getFontStyle(),
                    characterSpacing: 4,
                    lineSpacing: 20,
                  ),
                  autoTatechuyoko: true,
                  maxHeight: _maxHeight,
                  showGrid: _showGrid,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
