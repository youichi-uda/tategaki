import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class TatechuyokoDemo extends StatefulWidget {
  const TatechuyokoDemo({super.key});

  @override
  State<TatechuyokoDemo> createState() => _TatechuyokoDemoState();
}

class _TatechuyokoDemoState extends State<TatechuyokoDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('縦中横（横組み）'),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Text(
                      '自動縦中横（オフ）',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '令和06年12月25日',
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
                        characterSpacing: 6,
                      ),
                      autoTatechuyoko: false,
                      showGrid: _showGrid,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '自動縦中横（オン）',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '令和06年12月25日',
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
                        characterSpacing: 6,
                      ),
                      autoTatechuyoko: true,
                      showGrid: _showGrid,
                    ),
                  ],
                ),
                const SizedBox(width: 60),
                Column(
                  children: [
                    const Text(
                      '時刻表示',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    VerticalText(
                      '午後03時45分',
                      style: const VerticalTextStyle(
                        baseStyle: TextStyle(fontSize: 28, color: Colors.black87),
                        characterSpacing: 6,
                      ),
                      autoTatechuyoko: true,
                      showGrid: _showGrid,
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
}
