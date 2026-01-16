import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:belfort/screens/theme_provider.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  bool _isActive = false;
  double _size = 160.0;
  String _statusText = "Breathe";
  String _subText = "Take a moment for yourself";
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

    setState(() {
      _size = 280.0;
      _statusText = "Inhale";
      _subText = "Fill your lungs with light";
    });

    _timer = Timer(_inhaleDuration, () {
      if (!_isActive) return;

      setState(() {
        _statusText = "Hold";
        _subText = "Find your inner stillness";
      });

      _timer = Timer(_holdDuration, () {
        if (!_isActive) return;

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: themeProvider.backgroundGradient,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "E c h o o s",
                  style: TextStyle(
                    color: themeProvider.primaryTextColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "Inner Peace",
                  style: TextStyle(
                    color: themeProvider.breatheAccent.withOpacity(0.8),
                    fontSize: 20,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8, left: 8),
                  height: 2,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [themeProvider.breatheAccent, Colors.transparent],
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
                    gradient: RadialGradient(
                      colors: themeProvider.isDarkMode
                          ? [
                              const Color(0xFFB2FEFA),
                              const Color(0xFF0ED2F7),
                            ]
                          : [
                              const Color(0xFF80DEEA),
                              const Color(0xFF00BCD4),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.breatheAccent.withOpacity(0.3),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: _toggleBreathing,
                    child: Container(
                      width: _size * 0.8,
                      height: _size * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeProvider.isDarkMode
                              ? Colors.white24
                              : Colors.white70,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  _statusText,
                  style: TextStyle(
                    color: themeProvider.primaryTextColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subText,
                  style: TextStyle(
                    color: themeProvider.subtleTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}