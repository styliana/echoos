import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ZenMind Home'),
        backgroundColor: Colors.teal[100],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text('Welcome to ZenMind', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('A tiny app to support your mental health — breathing and mood check tools.'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.self_improvement),
              label: const Text('Guided Breathing'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _StubBreathingPage())),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.mood),
              label: const Text('Mood Check'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _StubMoodPage())),
            ),
            const Spacer(),
            const Text('Built for calm. No ads. No tracking.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
          ],
        ),
      ),

    );
  }
}

// Minimal stub pages to keep the app self-contained
class _StubBreathingPage extends StatelessWidget {
  const _StubBreathingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guided Breathing')),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.self_improvement, size: 80), SizedBox(height: 12), Text('Breathe in...'), SizedBox(height: 8), Text('Breathe out...')])),
    );
  }
}

class _StubMoodPage extends StatelessWidget {
  const _StubMoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Check')),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.mood, size: 80), SizedBox(height: 12), Text('How are you feeling today?')])),
    );
  }
}
