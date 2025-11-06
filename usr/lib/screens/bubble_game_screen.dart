import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/bubble.dart';
import '../widgets/bubble_widget.dart';
import '../widgets/game_header.dart';
import '../widgets/celebration_overlay.dart';

class BubbleGameScreen extends StatefulWidget {
  const BubbleGameScreen({super.key});

  @override
  State<BubbleGameScreen> createState() => _BubbleGameScreenState();
}

class _BubbleGameScreenState extends State<BubbleGameScreen>
    with TickerProviderStateMixin {
  final List<Bubble> bubbles = [];
  final Random random = Random();
  int score = 0;
  int level = 1;
  Timer? bubbleTimer;
  bool showCelebration = false;
  
  // Bubble spawn rate based on level
  int get spawnInterval => max(800 - (level * 50), 300);
  
  // Maximum bubbles on screen
  int get maxBubbles => min(15 + (level * 2), 30);

  @override
  void initState() {
    super.initState();
    _startBubbleGeneration();
  }

  @override
  void dispose() {
    bubbleTimer?.cancel();
    super.dispose();
  }

  void _startBubbleGeneration() {
    bubbleTimer?.cancel();
    bubbleTimer = Timer.periodic(
      Duration(milliseconds: spawnInterval),
      (timer) {
        if (bubbles.length < maxBubbles) {
          _addBubble();
        }
      },
    );
  }

  void _addBubble() {
    if (!mounted) return;
    
    setState(() {
      bubbles.add(Bubble(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        x: random.nextDouble() * 0.8 + 0.1,
        y: 1.2,
        size: random.nextDouble() * 40 + 40,
        color: _getRandomColor(),
        speed: random.nextDouble() * 1.5 + 0.5 + (level * 0.1),
      ));
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _popBubble(String id, Color color) {
    setState(() {
      bubbles.removeWhere((bubble) => bubble.id == id);
      score += 10;
      
      // Level up every 100 points
      if (score % 100 == 0 && score > 0) {
        level++;
        _showCelebration();
        _startBubbleGeneration(); // Restart with new spawn rate
      }
    });
  }

  void _showCelebration() {
    setState(() {
      showCelebration = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showCelebration = false;
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      bubbles.clear();
      score = 0;
      level = 1;
      showCelebration = false;
    });
    _startBubbleGeneration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade100,
              Colors.blue.shade200,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            ...List.generate(20, (index) {
              return Positioned(
                left: random.nextDouble() * MediaQuery.of(context).size.width,
                top: random.nextDouble() * MediaQuery.of(context).size.height,
                child: Icon(
                  Icons.bubble_chart,
                  size: random.nextDouble() * 30 + 10,
                  color: Colors.white.withOpacity(0.1),
                ),
              );
            }),
            
            // Game header
            GameHeader(
              score: score,
              level: level,
              onReset: _resetGame,
            ),
            
            // Bubbles
            ...bubbles.map((bubble) => BubbleWidget(
              bubble: bubble,
              onPop: _popBubble,
            )),
            
            // Celebration overlay
            if (showCelebration)
              CelebrationOverlay(level: level),
          ],
        ),
      ),
    );
  }
}