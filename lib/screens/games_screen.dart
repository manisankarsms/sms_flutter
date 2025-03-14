import 'package:flutter/material.dart';
import 'package:sms/screens/games/alphabet_matching.dart';
import 'games/alphabet_sequence.dart';
import 'games/math_quiz.dart';

class GamesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWideScreen ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: isWideScreen ? 1.6 : 1.2,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return _buildGameCard(context, game['title'], game['icon'], game['screen']);
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// List of games
final List<Map<String, dynamic>> games = [
  {'title': 'Math Quiz', 'icon': Icons.calculate, 'screen': MathQuizScreen()},
  {'title': 'Puzzle Game', 'icon': Icons.extension, 'screen': PuzzleGameScreen()},
  {'title': 'Letters Match', 'icon': Icons.abc, 'screen': AlphabetMatchScreen()},
  {'title': 'Alphabets Sequence', 'icon': Icons.sort_by_alpha, 'screen': AlphabetSequenceScreen()},
];

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