import 'dart:async';
import 'package:flutter/material.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  bool _isActive = false;
  double _size = 160.0;
  String _statusText = "Breathe";
  String _subText = "Tap to begin your journey";
  Timer? _timer;

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
        _size = 160.0;
        _statusText = "Breathe";
        _subText = "Session complete";
      });
    }
  }

  void _start() {
    setState(() {
      _isActive = true;
      _statusText = "Get Ready";
    });
    _runCycle();
  }

  void _runCycle() {
    if (!_isActive) return;

    // inhale
    setState(() {
      _size = 280.0;
      _statusText = "Inhale";
      _subText = "Fill your lungs with light";
    });

    _timer = Timer(_inhaleDuration, () {
      if (!_isActive) return;

      // hold
      setState(() {
        _statusText = "Hold";
        _subText = "Find your inner stillness";
      });

      _timer = Timer(_holdDuration, () {
        if (!_isActive) return;

        // exhale
        setState(() {
          _size = 160.0;
          _statusText = "Exhale";
          _subText = "Release all tension";
        });

        _timer = Timer(_exhaleDuration, () {
          if (_isActive) _runCycle();
        });
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 55,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DeepBreath",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "Inner Peace",
                  style: TextStyle(
                    color: const Color(0xFFB2FEFA).withOpacity(0.8),
                    fontSize: 20,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 2,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB2FEFA), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: _statusText == "Hold"
                      ? const Duration(milliseconds: 0)
                      : const Duration(seconds: 4),
                  curve: Curves.easeInOutSine,
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFB2FEFA),
                        Color(0xFF0ED2F7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0ED2F7).withOpacity(0.3),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: _size * 0.8,
                      height: _size * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  _statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleBreathing,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  decoration: BoxDecoration(
                    color: _isActive
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: _isActive ? Colors.redAccent.withOpacity(0.5) : Colors.white10,
                    ),
                  ),
                  child: Text(
                    _isActive ? "STOP" : "START",
                    style: TextStyle(
                      color: _isActive ? Colors.redAccent : const Color(0xFFB2FEFA),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}