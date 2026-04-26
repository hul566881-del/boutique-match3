import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'src/game/boutique_match3_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BoutiqueMatch3App());
}

class BoutiqueMatch3App extends StatelessWidget {
  const BoutiqueMatch3App({super.key});

  @override
  Widget build(BuildContext context) {
    final game = BoutiqueMatch3Game();

    return MaterialApp(
      title: 'Boutique Match 3',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF111015),
        body: SafeArea(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) => game.onSwipeStart(details.localPosition),
                onPanUpdate: (details) => game.onSwipeUpdate(details.localPosition),
                onPanEnd: (_) => game.onSwipeEnd(),
                child: GameWidget(
                  game: game,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
