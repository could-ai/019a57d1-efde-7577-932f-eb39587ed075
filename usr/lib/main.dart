import 'package:flutter/material.dart';
import 'screens/bubble_game_screen.dart';

void main() {
  runApp(const BubbleGameApp());
}

class BubbleGameApp extends StatelessWidget {
  const BubbleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Bubble Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const BubbleGameScreen(),
      routes: {
        '/': (context) => const BubbleGameScreen(),
      },
    );
  }
}