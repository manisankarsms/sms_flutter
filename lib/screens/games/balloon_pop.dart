import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const BalloonPopGame());
}

class BalloonPopGame extends StatelessWidget {
  const BalloonPopGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alphabet Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Quicksand',
      ),
      home: const GameStartScreen(),
    );
  }
}

class GameStartScreen extends StatelessWidget {
  const GameStartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.purple.shade300],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Alphabet Adventure',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black38,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Image.network('/api/placeholder/200/200', width: 180),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DifficultySelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.purple.shade300],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Difficulty',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black38,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              _buildDifficultyButton(context, 'Easy', Colors.green, 3, 2.0),
              const SizedBox(height: 20),
              _buildDifficultyButton(context, 'Medium', Colors.orange, 5, 3.0),
              const SizedBox(height: 20),
              _buildDifficultyButton(context, 'Hard', Colors.red, 8, 4.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, Color color,
      int balloonCount, double speed) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BalloonGameScreen(
              difficulty: label,
              balloonCount: balloonCount,
              speed: speed,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }
}

class Balloon {
  String letter;
  Color color;
  double x;
  double y;
  double size;
  bool isPopped;
  double speed;

  Balloon({
    required this.letter,
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    this.isPopped = false,
  });
}

class BalloonGameScreen extends StatefulWidget {
  final String difficulty;
  final int balloonCount;
  final double speed;

  const BalloonGameScreen({
    Key? key,
    required this.difficulty,
    required this.balloonCount,
    required this.speed,
  }) : super(key: key);

  @override
  _BalloonGameScreenState createState() => _BalloonGameScreenState();
}

class _BalloonGameScreenState extends State<BalloonGameScreen>
    with TickerProviderStateMixin {
  List<Balloon> balloons = [];
  int score = 0;
  int lives = 3;
  int timeLeft = 60;
  String targetLetter = "A";
  Timer? gameTimer;
  Timer? countdownTimer;
  bool isGameOver = false;
  bool isGameInitialized = false;
  Random random = Random();
  late AnimationController _confettiController;

  // Different balloon colors for variety
  final List<Color> balloonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pink,
    Colors.purple,
  ];

  final List<String> letters =
      List.generate(26, (i) => String.fromCharCode(65 + i));

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    setRandomTargetLetter();

    // Start the countdown timer
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        endGame();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize game after we have access to MediaQuery
    if (!isGameInitialized) {
      spawnBalloons();

      // Start balloon animation
      gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        animateBalloons();
      });

      isGameInitialized = true;
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    countdownTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void spawnBalloons() {
    balloons.clear();
    double maxWidth = MediaQuery.of(context).size.width - 60;

    for (int i = 0; i < widget.balloonCount; i++) {
      String letter = letters[random.nextInt(letters.length)];
      // Ensure at least one balloon has the target letter
      if (i == 0) {
        letter = targetLetter;
      }

      balloons.add(Balloon(
        letter: letter,
        color: balloonColors[random.nextInt(balloonColors.length)],
        x: random.nextDouble() * maxWidth,
        y: MediaQuery.of(context).size.height + random.nextInt(200).toDouble(),
        size: random.nextDouble() * 20 + 50,
        // Random size between 50-70
        speed: widget.speed + random.nextDouble() * 2,
      ));
    }
  }

  void animateBalloons() {
    if (isGameOver) return;

    setState(() {
      List<Balloon> balloonsToRemove = [];

      for (var balloon in balloons) {
        if (!balloon.isPopped) {
          balloon.y -= balloon.speed;

          // If balloon reaches the top without being popped
          if (balloon.y < -100) {
            balloonsToRemove.add(balloon);

            // Penalize for missing target balloon
            if (balloon.letter == targetLetter) {
              lives--;
              if (lives <= 0) {
                endGame();
              }
            }
          }
        }
      }

      // Remove balloons that went off screen
      balloons.removeWhere((b) => balloonsToRemove.contains(b));

      // Spawn new balloons if needed
      if (balloons.length < widget.balloonCount && !isGameOver) {
        double maxWidth = MediaQuery.of(context).size.width - 60;
        String letter = letters[random.nextInt(letters.length)];

        // Sometimes spawn the target letter
        if (random.nextInt(3) == 0) {
          letter = targetLetter;
        }

        balloons.add(Balloon(
          letter: letter,
          color: balloonColors[random.nextInt(balloonColors.length)],
          x: random.nextDouble() * maxWidth,
          y: MediaQuery.of(context).size.height + 50,
          size: random.nextDouble() * 20 + 50,
          speed: widget.speed + random.nextDouble() * 2,
        ));
      }
    });
  }

  void popBalloon(int index) {
    if (isGameOver) return;

    setState(() {
      if (balloons[index].letter == targetLetter) {
        balloons[index].isPopped = true;
        score += 10;

        // Every 50 points, add an extra life up to 5
        if (score % 50 == 0 && lives < 5) {
          lives++;
          _showMessage("Extra Life!");
        }

        // Change target letter after successful pop
        setRandomTargetLetter();
      } else {
        // Penalty for wrong letter
        lives--;
        _showMessage("Wrong Letter!");

        if (lives <= 0) {
          endGame();
        }
      }
    });
  }

  void setRandomTargetLetter() {
    setState(() {
      targetLetter = letters[random.nextInt(letters.length)];
    });
  }

  void endGame() {
    setState(() {
      isGameOver = true;
    });

    gameTimer?.cancel();
    countdownTimer?.cancel();

    if (score > 0) {
      _confettiController.forward();
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GameOverScreen(
              score: score,
              difficulty: widget.difficulty,
            ),
          ),
        );
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: message.contains("Extra") ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalloon(Balloon balloon) {
    return Column(
      children: [
        Container(
          width: balloon.size,
          height: balloon.size * 1.2,
          decoration: BoxDecoration(
            color: balloon.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 5,
                offset: const Offset(2, 2),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                balloon.color.withOpacity(0.8),
                balloon.color,
                balloon.color.withOpacity(0.6),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            balloon.letter,
            style: TextStyle(
              fontSize: balloon.size * 0.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black54,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 2,
          height: 20,
          color: Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoBox("Score", "$score", Colors.green),
                    _buildInfoBox("Lives", "$lives", Colors.red),
                    _buildInfoBox("Time", "$timeLeft", Colors.orange),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Text(
                'Find: $targetLetter',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background cloud images
                  Positioned(
                    left: 50,
                    top: 100,
                    child: Opacity(
                      opacity: 0.5,
                      child:
                          Image.network('/api/placeholder/100/50', width: 100),
                    ),
                  ),
                  Positioned(
                    right: 70,
                    top: 200,
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.network('/api/placeholder/80/40', width: 80),
                    ),
                  ),

                  // Balloons
                  for (int i = 0; i < balloons.length; i++)
                    if (!balloons[i].isPopped)
                      Positioned(
                        left: balloons[i].x,
                        top: balloons[i].y,
                        child: GestureDetector(
                          onTap: () => popBalloon(i),
                          child: _buildBalloon(balloons[i]),
                        ),
                      ),

                  // Game over overlay
                  if (isGameOver)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          'Game Over!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

class GameOverScreen extends StatelessWidget {
  final int score;
  final String difficulty;

  const GameOverScreen({
    Key? key,
    required this.score,
    required this.difficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.purple.shade300],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black38,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Difficulty: $difficulty',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const DifficultySelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const GameStartScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Main Menu',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
