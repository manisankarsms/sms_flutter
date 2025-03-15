import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class NumberSequencingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Number Sequencing',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.orangeAccent,
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
      home: NumberSequenceScreen(),
    );
  }
}

class NumberSequenceScreen extends StatefulWidget {
  @override
  _NumberSequenceScreenState createState() => _NumberSequenceScreenState();
}

class _NumberSequenceScreenState extends State<NumberSequenceScreen>
    with SingleTickerProviderStateMixin {
  List<int> sequence = [];
  int missingNumber = 0;
  List<int> options = [];
  int score = 0, highScore = 0;
  double timeLeft = 10;
  Timer? timer;
  bool isCorrect = false, isWrong = false;
  double progress = 1.0;
  final AudioPlayer player = AudioPlayer();
  bool soundOn = true, vibrationOn = true;
  String difficulty = "Easy";
  String sequenceType = "Normal";

  late AnimationController _animationController;
  late Animation<double> _animation;

  final Map<String, Color> difficultyColors = {
    "Easy": Colors.green,
    "Medium": Colors.orange,
    "Hard": Colors.red,
  };

  final Map<String, Color> sequenceTypeColors = {
    "Linear": Colors.blue,
    "Normal": Colors.lightBlue,
    "Fibonacci": Colors.purple,
    "Square": Colors.teal,
    "Prime": Colors.deepOrange,
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
    generateSequence();
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
    timeLeft = difficulty == "Easy"
        ? 15
        : difficulty == "Medium"
            ? 10
            : 7;
    progress = 1.0;
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft -= 0.1;
          progress = timeLeft /
              (difficulty == "Easy"
                  ? 15.0
                  : difficulty == "Medium"
                      ? 10.0
                      : 7.0);
        });
      } else {
        timer.cancel();
        endGame();
      }
    });
  }

  void generateSequence() {
    final random = Random();

    // Determine sequence length based on difficulty
    int sequenceLength = difficulty == "Easy"
        ? 5
        : difficulty == "Medium"
            ? 7
            : 9;

    // Generate sequence based on type
    switch (sequenceType) {
      case "Normal":
        generateNormalSequence(sequenceLength, random);
        break;
      case "Linear":
        generateLinearSequence(sequenceLength, random);
        break;
      case "Fibonacci":
        generateFibonacciSequence(sequenceLength, random);
        break;
      case "Square":
        generateSquareSequence(sequenceLength, random);
        break;
      case "Prime":
        generatePrimeSequence(sequenceLength, random);
        break;
    }

    // Reset animation and timer
    _animationController.reset();
    startTimer();

    setState(() {
      isCorrect = false;
      isWrong = false;
    });
  }

  void generateNormalSequence(int length, Random random) {
    // Define range based on difficulty
    int min, max;

    if (difficulty == "Easy") {
      min = 1;
      max = 20;
    } else if (difficulty == "Medium") {
      min = 20;
      max = 50;
    } else { // Hard
      min = 50;
      max = 100;
    }

    // Ensure we have enough range for the sequence length
    if (max - min < length) {
      max = min + length + 5; // Add some buffer
    }

    // Select a random starting point within the range
    int start = min + random.nextInt(max - min - length + 1);

    // Generate consecutive sequence
    sequence = List.generate(length, (index) => start + index);

    // Choose random position for missing number
    int missingIndex = random.nextInt(length);
    missingNumber = sequence[missingIndex];
    sequence[missingIndex] = -1; // -1 represents the missing number

    generateOptions(random);
  }

  void generateLinearSequence(int length, Random random) {
    // Create linear sequence with random start and step values
    int start = random.nextInt(10) + 1;
    int step = difficulty == "Easy"
        ? random.nextInt(3) + 1
        : difficulty == "Medium"
            ? random.nextInt(5) + 2
            : random.nextInt(10) + 3;

    sequence = List.generate(length, (index) => start + (step * index));

    // Choose random position for missing number
    int missingIndex = random.nextInt(length);
    missingNumber = sequence[missingIndex];
    sequence[missingIndex] = -1; // -1 represents the missing number

    generateOptions(random);
  }

  void generateFibonacciSequence(int length, Random random) {
    // Create a fibonacci-style sequence
    int a = random.nextInt(5) + 1;
    int b = random.nextInt(8) + a + 1;

    sequence = [a, b];
    for (int i = 2; i < length; i++) {
      sequence.add(sequence[i - 1] + sequence[i - 2]);
    }

    // Choose random position for missing number (avoiding first two positions in harder difficulties)
    int missingIndex = difficulty == "Easy"
        ? random.nextInt(length)
        : random.nextInt(length - 2) + 2;
    missingNumber = sequence[missingIndex];
    sequence[missingIndex] = -1; // -1 represents the missing number

    generateOptions(random);
  }

  void generateSquareSequence(int length, Random random) {
    // Create a sequence of squares with some offset
    int start = random.nextInt(5) + 1;
    sequence =
        List.generate(length, (index) => (start + index) * (start + index));

    // Choose random position for missing number
    int missingIndex = random.nextInt(length);
    missingNumber = sequence[missingIndex];
    sequence[missingIndex] = -1; // -1 represents the missing number

    generateOptions(random);
  }

  void generatePrimeSequence(int length, Random random) {
    // List of first few prime numbers
    List<int> primes = [
      2,
      3,
      5,
      7,
      11,
      13,
      17,
      19,
      23,
      29,
      31,
      37,
      41,
      43,
      47,
      53,
      59,
      61,
      67,
      71,
      73,
      79,
      83,
      89,
      97
    ];

    // Select a random starting point in the primes list
    int startIndex = random.nextInt(primes.length - length);
    sequence = primes.sublist(startIndex, startIndex + length);

    // Choose random position for missing number
    int missingIndex = random.nextInt(length);
    missingNumber = sequence[missingIndex];
    sequence[missingIndex] = -1; // -1 represents the missing number

    generateOptions(random);
  }

  void generateOptions(Random random) {
    // Generate options based on difficulty
    int optionsCount = difficulty == "Easy" ? 3 : 4;
    options = [missingNumber];

    // Add plausible but incorrect options
    while (options.length < optionsCount) {
      int wrongOption;

      // Make wrong answers more plausible based on difficulty
      if (difficulty == "Hard") {
        // Create close but incorrect options
        int offset = random.nextInt(3) + 1;
        wrongOption = missingNumber + (random.nextBool() ? offset : -offset);
      } else if (difficulty == "Medium") {
        // Medium difficulty has slightly more varied options
        int offset = random.nextInt(5) + 1;
        wrongOption = missingNumber + (random.nextBool() ? offset : -offset);
      } else {
        // Easy difficulty has more distinctly wrong options
        int offset = random.nextInt(10) + 1;
        wrongOption = missingNumber + (random.nextBool() ? offset : -offset);
      }

      // Ensure the wrong option is positive
      if (wrongOption > 0 && !options.contains(wrongOption)) {
        options.add(wrongOption);
      }
    }

    options.shuffle();
  }

  void vibrateOnWrongAnswer() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true && vibrationOn) {
      Vibration.vibrate(duration: 300);
    }
  }

  void checkAnswer(int selectedNumber) {
    timer?.cancel();
    if (selectedNumber == missingNumber) {
      if (soundOn) player.play(AssetSource("audio/correct.mp3"));
      _animationController.forward();
      setState(() {
        isCorrect = true;
        score++;
      });
      Future.delayed(Duration(milliseconds: 700), generateSequence);
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
        title: Text("Game Over",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your final score is:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),
            Text("$score",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
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
    generateSequence();
  }

  void saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      prefs.setInt("highScore-number-game", highScore);
    }
  }

  void loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt("highScore-number-game") ?? 0;
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
              Text("Game Settings",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text("Difficulty",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["Easy", "Medium", "Hard"]
                      .map((level) => Padding(
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
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: 20),
              Text("Sequence Type",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["Normal", "Linear", "Fibonacci", "Square", "Prime"]
                      .map((type) => Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      avatar: Icon(
                        type == "Linear" ? Icons.trending_up :
                        type == "Normal" ? Icons.filter_1 :
                        type == "Fibonacci" ? Icons.grain :
                        type == "Square" ? Icons.crop_square :
                        Icons.star_outline,
                        size: 16,
                      ),
                      label: Text(type),
                      selected: sequenceType == type,
                      selectedColor: sequenceTypeColors[type],
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            sequenceType = type;
                          });
                          setState(() {
                            sequenceType = type;
                            resetGame();
                          });
                        }
                      },
                    ),
                  ))
                      .toList(),
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
                      Icon(
                          vibrationOn ? Icons.vibration : Icons.do_not_disturb),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.format_list_numbered, size: 24),
            SizedBox(width: 8),
            Text('Number Sequencing'),
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
                      Text('Score: $score',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                valueColor: AlwaysStoppedAnimation<Color>(progress > 0.6
                    ? Colors.green
                    : progress > 0.3
                        ? Colors.orange
                        : Colors.red),
              ),
            ),

            // Badge for sequence type
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: sequenceTypeColors[sequenceType],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sequenceType == "Linear"
                        ? Icons.trending_up
                        : sequenceType == "Fibonacci"
                            ? Icons.grain
                            : sequenceType == "Square"
                                ? Icons.crop_square
                                : Icons.star_outline,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    sequenceType,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),

            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    color: isCorrect
                        ? Color.lerp(Colors.transparent,
                            Colors.green.withOpacity(0.2), _animation.value)
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
                      // Sequence card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double screenWidth = constraints.maxWidth;
                            double itemSize = screenWidth < 400 ? 50 : 60; // Adjust size for small screens
                            double fontSize = screenWidth < 400 ? 24 : 28;

                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenWidth < 400 ? 16 : 24),
                              child: Column(
                                children: [
                                  Text(
                                    'Find the missing number',
                                    style: TextStyle(
                                      fontSize: screenWidth < 400 ? 14 : 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth < 400 ? 16 : 24),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: sequence.map((number) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4),
                                          width: itemSize,
                                          height: itemSize,
                                          decoration: BoxDecoration(
                                            color: number == -1
                                                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                                : Theme.of(context).colorScheme.surface.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(12),
                                            border: number == -1
                                                ? Border.all(
                                              color: Theme.of(context).colorScheme.secondary,
                                              width: 2,
                                            )
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              number == -1 ? "?" : number.toString(),
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.bold,
                                                color: number == -1
                                                    ? Theme.of(context).colorScheme.secondary
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 40),
                      Text('Select the missing number:',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 16),

                      // Options grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          children: options
                              .map((option) => ElevatedButton(
                                    onPressed: () => checkAnswer(option),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.all(8),
                                    ),
                                    child: Text(
                                      option.toString(),
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))
                              .toList(),
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
