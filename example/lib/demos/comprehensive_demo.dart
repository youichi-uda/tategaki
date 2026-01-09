import 'package:flutter/material.dart';
import 'package:tategaki/tategaki.dart';

class ComprehensiveDemo extends StatefulWidget {
  const ComprehensiveDemo({super.key});

  @override
  State<ComprehensiveDemo> createState() => _ComprehensiveDemoState();
}

class _ComprehensiveDemoState extends State<ComprehensiveDemo> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('総合デモ'),
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
                  'すべての機能を組み合わせた例',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                VerticalText(
                  '昭和（1926年）12月25日。「美しい日本語の組版」を実現する為に、様々な工夫が凝らされている。',
                  style: const VerticalTextStyle(
                    baseStyle: TextStyle(fontSize: 22, color: Colors.black87),
                    characterSpacing: 4,
                    lineSpacing: 20,
                    enableKerning: true,
                    enableHalfWidthYakumono: true,
                    enableBurasageGumi: true,
                    enableGyotoIndent: true,
                    adjustYakumono: true,
                  ),
                  autoTatechuyoko: true,
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
