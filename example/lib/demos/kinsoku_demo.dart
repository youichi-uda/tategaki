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
                      ? '追い込み処理\n句読点が行頭に来ないように前の行に戻します'
                      : 'ぶら下げ処理\n句読点を前の行の末尾にぶら下げます',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                VerticalText(
                  'これは禁則処理のデモです。行頭や行末に来てはいけない文字（句読点や括弧など）が適切に処理されます。「このように」括弧も正しく扱われます。',
                  style: VerticalTextStyle(
                    baseStyle: GoogleFonts.notoSerifJp(
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                    characterSpacing: 4,
                    lineSpacing: 24,
                    kinsokuMethod: _kinsokuMethod,
                    enableGyotoIndent: true,
                  ),
                  maxHeight: 350,
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
