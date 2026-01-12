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

  // Ideally, keep state alive or use a PageView, but for MVP, this list works[cite: 50, 51].
  final List<Widget> _pages = [
    const GlobalPulsePage(),
    const BreathingPage(),
    const StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Preserves state of pages when switching
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public), 
            label: 'Pulse'
          ),
          NavigationDestination(
            icon: Icon(Icons.air), 
            label: 'Breathe'
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart), 
            label: 'Journey'
          ),
        ],
      ),
    );
  }
}