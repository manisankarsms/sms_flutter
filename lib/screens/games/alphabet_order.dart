import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlphabetOrderGame extends StatelessWidget {
  const AlphabetOrderGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alphabet Order Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<String> alphabet;
  late List<String> scrambledLetters;
  late List<String> selectedLetters;
  late List<bool> letterSelected;
  int score = 0;
  bool gameCompleted = false;
  late AnimationController _animationController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int bestTime = 0;
  int elapsedTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeGame();
    loadBestTime();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    alphabet = List.generate(
      26,
      (index) => String.fromCharCode('A'.codeUnitAt(0) + index),
    );
    scrambledLetters = List.from(alphabet)..shuffle();
    selectedLetters = [];
    letterSelected = List.generate(alphabet.length, (index) => false);
    gameCompleted = false;
    elapsedTime = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void saveBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (bestTime == 0 || elapsedTime < bestTime) {
      setState(() {
        bestTime = elapsedTime;
      });
      prefs.setInt("bestTime-alphabet-order", bestTime);
    }
  }

  void loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestTime = prefs.getInt("bestTime-alphabet-order") ?? 0;
    });
  }

  void vibrateOnWrongAnswer() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 300);
    }
  }

  void _selectLetter(String letter, int index) {
    if (letterSelected[index]) return;
    setState(() {
      selectedLetters.add(letter);
      letterSelected[index] = true;
      String expectedLetter = alphabet[selectedLetters.length - 1];
      if (letter == expectedLetter) {
        score += 10;
        _animationController.forward(from: 0.0);
        if (selectedLetters.length == alphabet.length) {
          gameCompleted = true;
          _stopTimer();
          saveBestTime();
        }
      } else {
        score = max(0, score - 5);
        selectedLetters.removeLast();
        letterSelected[index] = false;
        vibrateOnWrongAnswer();
      }
    });
  }

  Widget _buildScrambledLetters(bool isSmallScreen) {
    return Wrap(
      spacing: isSmallScreen ? 8 : 12,
      runSpacing: isSmallScreen ? 8 : 12,
      alignment: WrapAlignment.center,
      children: List.generate(scrambledLetters.length,
          (index) => _buildLetterButton(index, isSmallScreen)),
    );
  }

  Widget _buildLetterButton(int index, bool isSmallScreen) {
    return GestureDetector(
      onTap: () => _selectLetter(scrambledLetters[index], index),
      child: Container(
        width: isSmallScreen ? 45 : 60,
        height: isSmallScreen ? 45 : 60,
        decoration: BoxDecoration(
          color: letterSelected[index] ? Colors.grey.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Center(
          child: Text(scrambledLetters[index],
              style: _textStyle(
                  size: isSmallScreen ? 20 : 24, color: Colors.black)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet Order Game'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time: $elapsedTime sec',
                        style: _textStyle(color: Colors.white)),
                    Text('Best: $bestTime sec',
                        style: _textStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSelectedLettersDisplay(isSmallScreen),
                const Spacer(),
                _buildScrambledLetters(isSmallScreen),
                if (gameCompleted) _buildCompletionMessage(),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionMessage() {
    return Column(
      children: [
        Text('Level Complete!',
            style: _textStyle(size: 24, color: Colors.green)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () {}, child: const Text('Next Level')),
        TextButton(onPressed: () {}, child: const Text('Restart')),
      ],
    );
  }

  Widget _buildSelectedLettersDisplay(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: isSmallScreen ? 5 : 10,
        runSpacing: 5,
        alignment: WrapAlignment.center,
        children: List.generate(alphabet.length, (index) => _buildLetterBox(index)),
      ),
    );
  }

    Widget _buildLetterBox(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: index < selectedLetters.length ? Colors.green.shade400 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          index < selectedLetters.length ? selectedLetters[index] : '',
          style: _textStyle(size: 18, color: Colors.black),
        ),
      ),
    );
  }


  TextStyle _textStyle({double size = 20, Color color = Colors.white}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: color);
}
