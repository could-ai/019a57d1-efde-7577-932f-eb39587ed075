import 'package:flutter/material.dart';
import 'dart:async';
import '../models/bubble.dart';

class BubbleWidget extends StatefulWidget {
  final Bubble bubble;
  final Function(String id, Color color) onPop;

  const BubbleWidget({
    super.key,
    required this.bubble,
    required this.onPop,
  });

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _movementTimer;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    
    // Pop animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onPop(widget.bubble.id, widget.bubble.color);
      }
    });

    // Movement animation
    _startMovement();
  }

  void _startMovement() {
    _movementTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 FPS
      (timer) {
        if (!mounted || _isPopping) {
          timer.cancel();
          return;
        }

        setState(() {
          widget.bubble.y -= widget.bubble.speed * 0.01;
          
          // Add slight horizontal wobble
          widget.bubble.x += (0.001 * (widget.bubble.x > 0.5 ? -1 : 1));
          
          // Remove bubble if it goes off screen
          if (widget.bubble.y < -0.2) {
            widget.onPop(widget.bubble.id, widget.bubble.color);
          }
        });
      },
    );
  }

  void _handleTap() {
    if (_isPopping) return;
    
    setState(() {
      _isPopping = true;
    });
    
    _movementTimer?.cancel();
    _controller.forward();
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.bubble.x * size.width - widget.bubble.size / 2,
          top: widget.bubble.y * size.height - widget.bubble.size / 2,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: _handleTap,
                child: Container(
                  width: widget.bubble.size,
                  height: widget.bubble.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.bubble.color.withOpacity(0.7),
                        widget.bubble.color,
                        widget.bubble.color.withOpacity(0.5),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      center: const Alignment(-0.3, -0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.bubble.color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shine effect
                      Positioned(
                        top: widget.bubble.size * 0.15,
                        left: widget.bubble.size * 0.15,
                        child: Container(
                          width: widget.bubble.size * 0.3,
                          height: widget.bubble.size * 0.3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                      // Secondary shine
                      Positioned(
                        bottom: widget.bubble.size * 0.2,
                        right: widget.bubble.size * 0.2,
                        child: Container(
                          width: widget.bubble.size * 0.15,
                          height: widget.bubble.size * 0.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}