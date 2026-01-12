import 'package:flutter/material.dart';

class PulseParticle extends StatefulWidget {
  const PulseParticle({super.key});

  @override
  State<PulseParticle> createState() => _PulseParticleState();
}

class _PulseParticleState extends State<PulseParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  
  @override
  void initState() {
    super.initState();
    // Creates a breathing/pulsing animation effect
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 4)
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.tealAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.6), 
                    blurRadius: 15, 
                    spreadRadius: 2
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}