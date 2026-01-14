import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/pulse_bloc.dart';
import '../bloc/pulse_event.dart';
import '../bloc/pulse_state.dart';
import '../data/models/pulse_model.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PulseBloc()..add(StreamPulses()),
      child: const StatsView(),
    );
  }
}

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  int _calculateStreak(List<MoodPulse> pulses, String uid) {
    final userPulses = pulses.where((p) => p.userId == uid).toList();
    if (userPulses.isEmpty) return 0;

    final dates = userPulses
        .map((p) => DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (dates.first.isBefore(checkDate) && dates.first.isBefore(checkDate.subtract(const Duration(days: 1)))) {
      return 0;
    }

    for (var date in dates) {
      if (date == checkDate || date == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateReceivedSupports(List<MoodPulse> pulses, String uid) {
    return pulses
        .where((p) => p.userId == uid)
        .fold(0, (sum, p) => sum + p.supports.length);
  }

  int _calculateSentLikes(List<MoodPulse> pulses, String uid) {
    return pulses.fold(0, (sum, p) {
      return sum + (p.likes.contains(uid) ? 1 : 0);
    });
  }

  int _calculateReceivedLikes(List<MoodPulse> pulses, String uid) {
    return pulses
        .where((p) => p.userId == uid)
        .fold(0, (sum, p) => sum + p.likes.length);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 21, 24, 36),
              Color(0xFF1E2235),
              Color.fromARGB(255, 39, 52, 78),
              Color.fromARGB(255, 102, 115, 136),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 30, bottom: 30),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Statistics",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                            ),
                          ),
                          Text(
                            "Your progress",
                            style: TextStyle(
                              color: Colors.blueAccent.withOpacity(0.8),
                              fontSize: 16,
                              fontFamily: 'Georgia',
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<PulseBloc, PulseState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blueAccent),
                      );
                    }

                    final streak = _calculateStreak(state.pulses, uid);
                    final receivedSupports = _calculateReceivedSupports(state.pulses, uid);
                    final sentLikes = _calculateSentLikes(state.pulses, uid);
                    final receivedLikes = _calculateReceivedLikes(state.pulses, uid);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          _statCard(
                            icon: Icons.local_fire_department,
                            label: "Current Streak",
                            value: "$streak Days",
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _statCard(
                            icon: Icons.favorite,
                            label: "Support Received",
                            value: "$receivedSupports",
                            color: Colors.pinkAccent,
                          ),
                          const SizedBox(height: 16),
                          _statCard(
                            icon: Icons.thumb_up_alt_outlined,
                            label: "Likes Sent",
                            value: "$sentLikes",
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 16),
                          _statCard(
                            icon: Icons.volunteer_activism,
                            label: "Likes Received",
                            value: "$receivedLikes",
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}