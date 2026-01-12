import 'package:flutter/material.dart';
// Removed Firestore and auth to simplify and make the page self-contained



class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Public Pulses"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            SizedBox(height: 12),
            Icon(Icons.history, size: 60, color: Colors.teal),
            SizedBox(height: 12),
            Text('Recent pulses (local)', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            Text('This view is a local placeholder. Live data was removed to keep the app self-contained.'),
          ],
        ),
      ),
    );
  }
}