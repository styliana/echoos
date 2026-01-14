import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pulse_bloc.dart';
import '../bloc/pulse_event.dart';
import '../bloc/pulse_state.dart';
import '../data/models/pulse_model.dart';

const _moodIcons = {
  Mood.happy: '😊',
  Mood.stressed: '😫',
  Mood.sad: '😢',
  Mood.angry: '😡',
  Mood.calm: '🧘',
};

const _moodColors = {
  Mood.happy: Colors.amber,
  Mood.stressed: Colors.redAccent,
  Mood.sad: Colors.blueGrey,
  Mood.angry: Colors.deepOrange,
  Mood.calm: Colors.teal,
};

class MoodJourneyPage extends StatelessWidget {
  const MoodJourneyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PulseBloc()..add(StreamPulses()),
      child: const MoodJourneyView(),
    );
  }
}

class MoodJourneyView extends StatelessWidget {
  const MoodJourneyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        final myUid = FirebaseAuth.instance.currentUser?.uid;
        final myHistory = state.pulses.where((p) => p.userId == myUid).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Mood Journey'),
            backgroundColor: Colors.grey[900],
          ),
          backgroundColor: Colors.grey[900],
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "My Mood Journey",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24),
                Expanded(
                  child: myHistory.isEmpty
                      ? const Center(
                          child: Text(
                            "No history yet",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: myHistory.length,
                          itemBuilder: (context, index) {
                            final p = myHistory[index];
                            return ListTile(
                              leading: Text(
                                _moodIcons[p.mood]!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(
                                "Mood from ${p.createdAt.day}/${p.createdAt.month}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${p.supports.length} supports • ${p.likes.length} likes",
                                style: const TextStyle(color: Colors.tealAccent),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white24,
                              ),
                              onTap: () => _showComments(context, p),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComments(BuildContext context, MoodPulse p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(_moodIcons[p.mood]!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            const Text(
              "Community Support",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: p.supports.isEmpty
              ? const Text(
                  "No comments yet. Stay strong!",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: p.supports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final support = p.supports[index];
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _moodColors[p.mood]!.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _moodColors[p.mood]!.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("❤️", style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                support,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.tealAccent),
            ),
          ),
        ],
      ),
    );
  }
}