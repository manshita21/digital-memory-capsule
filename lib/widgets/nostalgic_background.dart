import 'dart:math';
import 'package:flutter/material.dart';

class NostalgicBackground extends StatefulWidget {
  final Widget child;

  const NostalgicBackground({super.key, required this.child});

  @override
  State<NostalgicBackground> createState() => _NostalgicBackgroundState();
}

class _NostalgicBackgroundState extends State<NostalgicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Orb> _orbs = [];
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..addListener(() {
        for (var orb in _orbs) {
          orb.update(_touchPosition);
        }
        setState(() {});
      })
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_orbs.isEmpty) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 15; i++) {
        _orbs.add(Orb(size));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        _touchPosition = details.globalPosition;
      },
      onPanEnd: (_) {
        _touchPosition = null;
      },
      child: Stack(
        children: [
          // 1. Animated Gradient Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double t = _controller.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFFFDE4EC), const Color(0xFFE1BEE7), t)!, // Dreamy pink/purple
                      Color.lerp(const Color(0xFFCE93D8), const Color(0xFFF8BBD0), t)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          
          // 2. Interactive Floating Orbs
          CustomPaint(
            size: Size.infinite,
            painter: OrbPainter(_orbs),
          ),
          
          // 3. Application Content
          widget.child,
        ],
      ),
    );
  }
}

class Orb {
  Offset position;
  double radius;
  Offset velocity;
  final Size screenSize;
  double opacity;

  Orb(this.screenSize)
      : position = Offset(
          Random().nextDouble() * screenSize.width,
          Random().nextDouble() * screenSize.height,
        ),
        radius = Random().nextDouble() * 40 + 20,
        velocity = Offset(
          (Random().nextDouble() - 0.5) * 0.5,
          -Random().nextDouble() * 0.8 - 0.2, // Move up slowly
        ),
        opacity = Random().nextDouble() * 0.3 + 0.1;

  void update(Offset? touchPosition) {
    position += velocity;

    // React to touch
    if (touchPosition != null) {
      final distance = (position - touchPosition).distance;
      if (distance < 150) { // Interaction radius
        final direction = (position - touchPosition) / distance;
        position += direction * 2.0; // Repel slightly
        opacity = min(0.6, opacity + 0.05); // Glow on touch
      } else {
        opacity = max(0.1, opacity - 0.01);
      }
    } else {
        opacity = max(0.1, opacity - 0.01);
    }

    // Wrap around screen
    if (position.dy + radius < 0) {
      position = Offset(Random().nextDouble() * screenSize.width, screenSize.height + radius);
    }
    if (position.dx < -radius) position = Offset(screenSize.width + radius, position.dy);
    if (position.dx > screenSize.width + radius) position = Offset(-radius, position.dy);
  }
}

class OrbPainter extends CustomPainter {
  final List<Orb> orbs;

  OrbPainter(this.orbs);

  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(orb.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20); // Soft glowing effect
      canvas.drawCircle(orb.position, orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
