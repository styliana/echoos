import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color.fromARGB(255, 21, 24, 36),
  );

  // Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
  );

  // Gradient colors for dark mode
  List<Color> get backgroundGradient => _isDarkMode
      ? const [
          Color(0xFF151824),
          Color(0xFF1E2235),
          Color(0xFF27344E),
          Color(0xFF667388),
        ]
      : const [
          Color(0xFFF5F7FA),
          Color(0xFFE8EAF6),
          Color(0xFFB39DDB),
          Color(0xFF667388),
          Color(0xFF27344E),
        ];

  // Text colors
  Color get primaryTextColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get secondaryTextColor =>
      _isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
  Color get subtleTextColor =>
      _isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black38;

  // Card/Container colors
  Color cardColor(double opacity) => _isDarkMode
      ? Colors.white.withOpacity(opacity)
      : Colors.black.withOpacity(opacity);

  // Accent colors
  Color get accentColor => _isDarkMode ? Colors.tealAccent : Colors.teal;
  Color get breatheAccent =>
      _isDarkMode ? const Color(0xFFB2FEFA) : const Color(0xFF00BCD4);
  Color get dashboardAccent =>
      _isDarkMode ? const Color(0xFFCE93D8) : const Color(0xFF9C27B0);
  Color get pulseAccent => _isDarkMode ? Colors.yellow : Colors.amber;
}