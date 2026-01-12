import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'global_pulse_page.dart';
import 'breathing_page.dart';
import 'stats_page.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const GlobalPulsePage(),
    const BreathingPage(),
    const StatsPage(),
  ];

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();

      await GoogleSignIn().signOut();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                onPressed: () => _showLogoutDialog(context),
                tooltip: 'Logout',
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildModernZenBar(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to log out?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildModernZenBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.emoji_emotions, "Pulse", const [Color(0xFFFFE082), Color(0xFFFFB300)]),
            _buildNavItem(1, Icons.spa, "Breathe", const [Color(0xFFB2FEFA), Color(0xFF0ED2F7)]),
            _buildNavItem(2, Icons.stacked_bar_chart, "Stats", const [Color(0xFFF3E5F5), Color(0xFFCE93D8)]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, List<Color> gradientColors) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors.map((c) => c.withOpacity(0.2)).toList(),
          ),
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: isSelected ? gradientColors : [Colors.grey.shade700, Colors.grey.shade700],
                ).createShader(bounds);
              },
              child: Icon(
                icon,
                color: Colors.white,
                size: isSelected ? 28 : 24,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: gradientColors[0],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}