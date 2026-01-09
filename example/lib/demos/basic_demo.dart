import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class BasicDemo extends StatefulWidget {
  const BasicDemo({super.key});

  @override
  State<BasicDemo> createState() => _BasicDemoState();
}

class _BasicDemoState extends State<BasicDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基本的な縦書き'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
                  'シンプルな縦書きテキスト',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                VerticalText(
                  'これは縦書きテキストの例です。日本語の伝統的な文書では、このように縦書きで文字を配置します。',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 24, color: Colors.black87),
                    characterSpacing: 4,
                    lineSpacing: 24,
                  ),
                  maxHeight: 400,
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
