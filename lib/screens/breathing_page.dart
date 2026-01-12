import 'dart:async';
import 'package:flutter/material.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  bool _isActive = false;
  double _size = 100.0;
  String _text = "Tap to Start";
  Timer? _timer;

  // Breathing Cycle Config [cite: 243]
  final Duration _inhaleDuration = const Duration(seconds: 4);
  final Duration _holdDuration = const Duration(seconds: 2);
  final Duration _exhaleDuration = const Duration(seconds: 4);

  void _toggleBreathing() {
    if (_isActive) {
      _stop();
    } else {
      _start();
    }
  }

  void _stop() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isActive = false;
        _size = 100.0;
        _text = "Stopped";
      });
    }
  }

  void _start() {
    setState(() => _isActive = true);
    _runCycle();
  }

  void _runCycle() {
    if (!_isActive) return;

    // 1. Inhale
    if (mounted) {
      setState(() {
        _size = 300.0;
        _text = "Breathe In...";
      });
    }

    _timer = Timer(_inhaleDuration, () {
      if (!_isActive) return;
      
      // 2. Hold
      if (mounted) setState(() => _text = "Hold...");
      
      _timer = Timer(_holdDuration, () {
        if (!_isActive) return;

        // 3. Exhale
        if (mounted) {
          setState(() {
            _size = 100.0;
            _text = "Breathe Out...";
          });
        }
        
        // Loop
        _timer = Timer(_exhaleDuration, _runCycle);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _text, 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300)
            ),
            const SizedBox(height: 60),
            // The "Lungs" Circle
            AnimatedContainer(
              duration: _text.contains("Hold") 
                  ? const Duration(milliseconds: 0) // No animation during hold
                  : (_size > 150 ? _inhaleDuration : _exhaleDuration),
              curve: Curves.easeInOut,
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                gradient: RadialGradient(
                  colors: [
                    Colors.tealAccent.withOpacity(0.5), 
                    Colors.transparent
                  ],
                ),
                boxShadow: [
                   BoxShadow(
                     color: Colors.tealAccent, 
                     blurRadius: _size / 3, 
                     spreadRadius: 5
                   )
                ]
              ),
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: _toggleBreathing,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isActive ? Colors.red.withOpacity(0.2) : Colors.teal.withOpacity(0.2),
              ),
              child: Text(_isActive ? "Stop Session" : "Start Breathing"),
            )
          ],
        ),
      ),
    );
  }
}