import 'package:flutter/material.dart';

import 'games/math_quiz.dart';

class GamesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGameButton(context, 'Math Quiz', MathQuizScreen()),
            _buildGameButton(context, 'Puzzle Game', PuzzleGameScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        ),
        child: Text(title, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// Dummy Game Screens

class PuzzleGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Puzzle Game')),
      body: Center(child: Text('Puzzle Game Screen')),
    );
  }
}
