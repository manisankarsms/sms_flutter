import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class MathQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Math Quiz',
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
      home: MathQuizScreen(),
    );
  }
}

class MathQuizScreen extends StatefulWidget {
  @override
  _MathQuizScreenState createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> with SingleTickerProviderStateMixin {
  int num1 = 0, num2 = 0, correctAnswer = 0;
  List<int> options = [];
  int score = 0, highScore = 0;
  double timeLeft = 10;
  Timer? timer;
  bool isCorrect = false, isWrong = false;
  double progress = 1.0;
  final AudioPlayer player = AudioPlayer();
  bool soundOn = true, vibrationOn = true;
  String difficulty = "Easy";
  String operation = "Addition";

  late AnimationController _animationController;
  late Animation<double> _animation;

  final Map<String, Color> difficultyColors = {
    "Easy": Colors.green,
    "Medium": Colors.orange,
    "Hard": Colors.red,
  };

  final Map<String, IconData> operationIcons = {
    "Addition": Icons.add,
    "Subtraction": Icons.remove,
    "Multiplication": Icons.close,
    "Division": Icons.difference,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    loadHighScore();
    generateQuestion();
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    player.dispose();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = difficulty == "Easy" ? 15 : difficulty == "Medium" ? 10 : 7;
    progress = 1.0;
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft -= 0.1;
          progress = timeLeft / (difficulty == "Easy" ? 15.0 : difficulty == "Medium" ? 10.0 : 7.0);
        });
      } else {
        timer.cancel();
        endGame();
      }
    });
  }

  void generateQuestion() {
    final random = Random();
    int maxNum = difficulty == "Easy" ? 10 : difficulty == "Medium" ? 50 : 100;

    // Create more balanced questions based on difficulty
    if (operation == "Division") {
      // For division, ensure we get whole number results
      num2 = random.nextInt(maxNum ~/ 2) + 1;
      num1 = num2 * (random.nextInt(maxNum ~/ num2) + 1);
    } else {
      num1 = random.nextInt(maxNum) + 1;
      num2 = random.nextInt(maxNum) + 1;

      // For subtraction, ensure the result is positive
      if (operation == "Subtraction" && num2 > num1) {
        int temp = num1;
        num1 = num2;
        num2 = temp;
      }
    }

    switch (operation) {
      case "Addition":
        correctAnswer = num1 + num2;
        break;
      case "Subtraction":
        correctAnswer = num1 - num2;
        break;
      case "Multiplication":
        correctAnswer = num1 * num2;
        break;
      case "Division":
        correctAnswer = num1 ~/ num2;
        break;
    }

    // Generate plausible wrong answers based on operation
    Set<int> uniqueOptions = {correctAnswer};
    while (uniqueOptions.length < 4) {
      int incorrect;
      switch (operation) {
        case "Addition":
          incorrect = correctAnswer + random.nextInt(10) - 5;
          break;
        case "Subtraction":
          incorrect = correctAnswer + random.nextInt(8) - 4;
          break;
        case "Multiplication":
          incorrect = correctAnswer + (random.nextInt(5) + 1) * (random.nextBool() ? 1 : -1);
          break;
        case "Division":
          incorrect = correctAnswer + (random.nextBool() ? 1 : -1);
          break;
        default:
          incorrect = correctAnswer + random.nextInt(10) - 5;
      }

      if (incorrect != correctAnswer && incorrect > 0) {
        uniqueOptions.add(incorrect);
      }
    }

    options = uniqueOptions.toList()..shuffle();
    startTimer();
    setState(() {
      isCorrect = false;
      isWrong = false;
    });

    // Reset animation
    _animationController.reset();
  }

  void vibrateOnWrongAnswer() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true && vibrationOn) {
      Vibration.vibrate(duration: 300);
    }
  }

  void checkAnswer(int selected) {
    timer?.cancel();
    if (selected == correctAnswer) {
      if (soundOn) player.play(AssetSource("audio/correct.mp3"));
      _animationController.forward();
      setState(() {
        isCorrect = true;
        score++;
      });
      Future.delayed(Duration(milliseconds: 700), generateQuestion);
    } else {
      if (soundOn) player.play(AssetSource("audio/wrong.mp3"));
      vibrateOnWrongAnswer();
      setState(() {
        isWrong = true;
      });
      Future.delayed(Duration(milliseconds: 700), endGame);
    }
  }

  void endGame() {
    timer?.cancel();
    saveHighScore();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
            "Game Over",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your final score is:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),
            Text("$score", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text("High Score: $highScore", style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: Text("Play Again", style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
    });
    generateQuestion();
  }

  void saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      prefs.setInt("highScore-math-quiz-01", highScore);
    }
  }

  void loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt("highScore-math-quiz-01") ?? 0;
    });
  }

  void showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Game Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              Text("Difficulty", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["Easy", "Medium", "Hard"].map((level) => Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      label: Text(level),
                      selected: difficulty == level,
                      selectedColor: difficultyColors[level],
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            difficulty = level;
                          });
                          setState(() {
                            difficulty = level;
                            resetGame();
                          });
                        }
                      },
                    ),
                  )).toList(),
                ),
              ),

              SizedBox(height: 20),
              Text("Operation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["Addition", "Subtraction", "Multiplication", "Division"].map((op) => Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      avatar: Icon(operationIcons[op], size: 18),
                      label: Text(op),
                      selected: operation == op,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            operation = op;
                          });
                          setState(() {
                            operation = op;
                            resetGame();
                          });
                        }
                      },
                    ),
                  )).toList(),
                ),
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(soundOn ? Icons.volume_up : Icons.volume_off),
                      SizedBox(width: 8),
                      Text("Sound"),
                    ],
                  ),
                  Switch(
                    value: soundOn,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (value) {
                      setModalState(() {
                        soundOn = value;
                      });
                      setState(() {
                        soundOn = value;
                      });
                    },
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(vibrationOn ? Icons.vibration : Icons.do_not_disturb),
                      SizedBox(width: 8),
                      Text("Vibration"),
                    ],
                  ),
                  Switch(
                    value: vibrationOn,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (value) {
                      setModalState(() {
                        vibrationOn = value;
                      });
                      setState(() {
                        vibrationOn = value;
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String getOperationSymbol() {
    switch (operation) {
      case "Addition": return "+";
      case "Subtraction": return "-";
      case "Multiplication": return "×";
      case "Division": return "÷";
      default: return "+";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.functions, size: 24),
            SizedBox(width: 8),
            Text('Math Quiz'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: showSettingsModal,
          ),
        ],
        elevation: 0,
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
            // Top status bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Score: $score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Best: $highScore', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: difficultyColors[difficulty],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Timer bar
            Container(
              height: 8,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade800,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.6 ? Colors.green :
                    progress > 0.3 ? Colors.orange : Colors.red
                ),
              ),
            ),

            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    color: isCorrect
                        ? Color.lerp(Colors.transparent, Colors.green.withOpacity(0.2), _animation.value)
                        : isWrong
                        ? Colors.red.withOpacity(0.2)
                        : Colors.transparent,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Question card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Solve',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$num1',
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      getOperationSymbol(),
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$num2',
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40),
                      Text('Select the correct answer:', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 16),

                      // Options grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          children: options.map((option) => ElevatedButton(
                            onPressed: () => checkAnswer(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.all(8),
                            ),
                            child: Text(
                              option.toString(),
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}