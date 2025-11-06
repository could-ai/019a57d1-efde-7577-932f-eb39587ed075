import 'package:flutter/material.dart';

class Bubble {
  final String id;
  double x; // Horizontal position (0.0 to 1.0)
  double y; // Vertical position (0.0 to 1.0+)
  final double size;
  final Color color;
  final double speed;
  
  Bubble({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });
}