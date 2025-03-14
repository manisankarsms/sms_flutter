import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlphabetMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letter Match',
      home: AlphabetMatchScreen(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.dark(
          primary: Colors.indigo,
          secondary: Colors.pinkAccent,
          surface: Color(0xFF1E1E2C),
          background: Color(0xFF121212),
        ),
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AlphabetMatchScreen extends StatefulWidget {
  @override
  _AlphabetMatchScreenState createState() => _AlphabetMatchScreenState();
}

class GameLevel {
  final int lettersCount;
  final String name;

  GameLevel(this.lettersCount, this.name);
}

class _AlphabetMatchScreenState extends State<AlphabetMatchScreen> {
  // Game state
  final List<String> allUppercaseLetters = List.generate(26, (i) => String.fromCharCode(65 + i));
  final List<String> allLowercaseLetters = List.generate(26, (i) => String.fromCharCode(97 + i));
  List<String> uppercaseLetters = [];
  List<String> lowercaseLetters = [];
  Map<String, String> matchedPairs = {};
  String selectedUpperCase = '';

  // Score tracking
  int score = 0;
  int highScore = 0;
  int stars = 0;

  // Game settings
  bool soundEnabled = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String message = "Match the uppercase and lowercase letters!";

  // Game levels
  List<GameLevel> levels = [
    GameLevel(4, 'Easy'),
    GameLevel(6, 'Medium'),
    GameLevel(8, 'Hard')
  ];
  int currentLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    startNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore-alphabet-01') ?? 0;
      stars = prefs.getInt('stars-alphabet-01') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore-alphabet-01', highScore);
    await prefs.setInt('stars-alphabet-01', stars);
  }

  void startNewRound() {
    final random = Random();
    int letterCount = levels[currentLevel].lettersCount;

    // Ensure we're using unique letters
    List<String> uniqueUppercase = List<String>.from(allUppercaseLetters)..shuffle(random);
    uppercaseLetters = uniqueUppercase.take(letterCount).toList();

    lowercaseLetters = uppercaseLetters.map((e) => e.toLowerCase()).toList()..shuffle(random);
    matchedPairs.clear();
    selectedUpperCase = '';

    setState(() {
      message = "Match the uppercase and lowercase letters!";
    });
  }

  Future<void> playSound(bool isCorrect) async {
    if (!soundEnabled) return;

    String soundPath = isCorrect ? 'audio/correct.mp3' : 'audio/wrong.mp3';
    await _audioPlayer.play(AssetSource(soundPath));
  }

  void checkMatch(String upper, String lower) {
    if (upper.toLowerCase() == lower) {
      setState(() {
        matchedPairs[upper] = lower;
        score += 1;
        if (score > highScore) {
          highScore = score;
        }
        message = "Correct! Good job!";
        _saveHighScore();
      });
      playSound(true);

      if (matchedPairs.length == uppercaseLetters.length) {
        setState(() {
          message = "Round Complete! +1 star";
          stars += 1;
          _saveHighScore();
        });
        Future.delayed(Duration(seconds: 2), () {
          startNewRound();
        });
      }
    } else {
      playSound(false);
      setState(() {
        message = "Try again!";
      });

      // Reset message after delay
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          message = "Match the letters!";
        });
      });
    }
  }

  void selectUppercaseLetter(String letter) {
    setState(() {
      selectedUpperCase = letter;
    });
  }

  void checkSelectedMatch(String lowercase) {
    if (selectedUpperCase.isNotEmpty) {
      checkMatch(selectedUpperCase, lowercase);
      setState(() {
        selectedUpperCase = '';
      });
    }
  }

  void changeLevel(int level) {
    if (level >= 0 && level < levels.length) {
      setState(() {
        currentLevel = level;
      });
      startNewRound();
    }
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How to Play'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Tap on an uppercase letter to select it'),
            Text('2. Then tap on the matching lowercase letter'),
            Text('3. Complete all matches to finish the round'),
            Text('4. Earn stars for each completed round'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Sound Effects'),
              value: soundEnabled,
              onChanged: (value) {
                setState(() {
                  soundEnabled = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < levels.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ElevatedButton(
              onPressed: () => changeLevel(i),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentLevel == i ? Colors.green : null,
              ),
              child: Text(levels[i].name),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Letter Match'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHowToPlay,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Color(0xFF1A1A2E),
            ],
          ),
        ),
      child: Column(
        children: [
          // Score panel
          Container(
            padding: const EdgeInsets.all(10.0),
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Score', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$score', style: TextStyle(fontSize: 20)),
                  ],
                ),
                Column(
                  children: [
                    Text('Best', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$highScore', style: TextStyle(fontSize: 20)),
                  ],
                ),
                Column(
                  children: [
                    Text('Stars', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        Text('$stars', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Level selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _buildLevelSelector(),
          ),

          // Game message
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Game board
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Uppercase letters row
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Uppercase Letters",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: uppercaseLetters.map((letter) {
                    bool isMatched = matchedPairs.containsKey(letter);
                    return GestureDetector(
                      onTap: isMatched ? null : () => selectUppercaseLetter(letter),
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isMatched
                              ? Colors.green
                              : selectedUpperCase == letter
                              ? Colors.blue
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedUpperCase == letter ? Colors.yellow : Colors.black,
                            width: selectedUpperCase == letter ? 3 : 1,
                          ),
                        ),
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isMatched ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 30),

                // Lowercase letters row
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Lowercase Letters",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: lowercaseLetters.map((letter) {
                    bool isMatched = matchedPairs.containsValue(letter);
                    return GestureDetector(
                      onTap: isMatched || selectedUpperCase.isEmpty
                          ? null
                          : () => checkSelectedMatch(letter),
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isMatched
                              ? Colors.green
                              : selectedUpperCase.isNotEmpty
                              ? Colors.orange.withOpacity(0.8)
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isMatched ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Game controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: startNewRound,
                  icon: Icon(Icons.refresh),
                  label: Text('New Letters'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show a hint
                    if (selectedUpperCase.isNotEmpty) {
                      final correctMatch = lowercaseLetters.firstWhere(
                            (letter) => letter == selectedUpperCase.toLowerCase(),
                        orElse: () => '',
                      );
                      if (correctMatch.isNotEmpty) {
                        setState(() {
                          message = 'Hint: Match "$selectedUpperCase" with "$correctMatch"';
                        });
                        // Reset message after delay
                        Future.delayed(Duration(seconds: 2), () {
                          setState(() {
                            message = 'Match the letters!';
                          });
                        });
                      }
                    } else {
                      setState(() {
                        message = 'Select an uppercase letter first!';
                      });
                      Future.delayed(Duration(seconds: 2), () {
                        setState(() {
                          message = 'Match the letters!';
                        });
                      });
                    }
                  },
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text('Hint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}