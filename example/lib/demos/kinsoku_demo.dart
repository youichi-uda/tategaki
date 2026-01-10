import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tategaki/tategaki.dart';

class KinsokuDemo extends StatefulWidget {
  const KinsokuDemo({super.key});

  @override
  State<KinsokuDemo> createState() => _KinsokuDemoState();
}

class _KinsokuDemoState extends State<KinsokuDemo> {
  bool _showGrid = false;
  KinsokuMethod _kinsokuMethod = KinsokuMethod.oikomi;
  double _maxHeight = 250.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('禁則処理（改行規則）'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _kinsokuMethod = _kinsokuMethod == KinsokuMethod.oikomi
                    ? KinsokuMethod.burasage
                    : KinsokuMethod.oikomi;
              });
            },
            icon: const Icon(
              Icons.swap_horiz,
              color: Colors.white,
            ),
            label: Text(
              _kinsokuMethod == KinsokuMethod.oikomi ? '追い込み' : 'ぶら下げ',
              style: const TextStyle(color: Colors.white),
            ),
          ),
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
                Text(
                  _kinsokuMethod == KinsokuMethod.oikomi
                      ? '追い込み処理：行頭禁則文字を前の行に戻す'
                      : 'ぶら下げ処理：小さい文字（。、）のみ行末にぶら下げ可能',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('描画領域の高さ：'),
                    SizedBox(
                      width: 300,
                      child: Slider(
                        value: _maxHeight,
                        min: 100,
                        max: 500,
                        divisions: 40,
                        label: _maxHeight.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _maxHeight = value;
                          });
                        },
                      ),
                    ),
                    Text('${_maxHeight.round()}px'),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本的な禁則処理
                    _buildExample(
                      '基本的な禁則処理',
                      'これは禁則処理のデモです。行頭や行末に来てはいけない文字（句読点や括弧など）が適切に処理されます。',
                    ),
                    const SizedBox(width: 60),
                    // 三点リーダー
                    _buildExample(
                      '三点リーダーは分離しない',
                      '三点リーダー……は必ずペアで使用されます。途中で改行されることはありません……大丈夫です。',
                    ),
                    const SizedBox(width: 60),
                    // 二点リーダー
                    _buildExample(
                      '二点リーダーも同様',
                      '二点リーダー‥‥も同じくペアで使います。これも分離されません‥‥安心です。',
                    ),
                    const SizedBox(width: 60),
                    // 連続する感嘆符・疑問符
                    _buildExample(
                      '連続する感嘆符・疑問符',
                      '驚いた！！本当に！？信じられない？？そんなことが!?実際に起こるなんて？！',
                    ),
                    const SizedBox(width: 60),
                    // 小さい文字 vs フルサイズ文字
                    _buildExample(
                      '句読点（小）vs 感嘆符（大）',
                      '小さい句読点。は、ぶら下げ可能です。しかし大きな感嘆符！や疑問符？は押し込みのみです！',
                    ),
                    const SizedBox(width: 60),
                    // 括弧の処理
                    _buildExample(
                      '括弧の行頭・行末禁則',
                      '「このように」括弧も正しく扱われます。（開き括弧は行末禁則）（閉じ括弧は行頭禁則）と処理されます。',
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

  Widget _buildExample(String title, String text) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        VerticalText(
          text,
          style: VerticalTextStyle(
            baseStyle: GoogleFonts.notoSerifJp(
              fontSize: 22,
              color: Colors.black87,
            ),
            characterSpacing: 4,
            lineSpacing: 20,
            kinsokuMethod: _kinsokuMethod,
            enableGyotoIndent: true,
            adjustYakumono: true,
          ),
          autoTatechuyoko: true,
          maxHeight: _maxHeight,
          showGrid: _showGrid,
        ),
      ],
    );
  }
}
