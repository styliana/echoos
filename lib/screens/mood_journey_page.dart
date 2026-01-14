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
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

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
                            "My journey",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                            ),
                          ),
                          Text(
                            "Personal history",
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
                        child: CircularProgressIndicator(color: Colors.tealAccent),
                      );
                    }

                    final myPulses = state.pulses.where((p) => p.userId == uid).toList();

                    if (myPulses.isEmpty) {
                      return const Center(
                        child: Text(
                          "No pulses found yet.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: myPulses.length,
                      itemBuilder: (context, index) {
                        final pulse = myPulses[index];
                        return _buildMoodCard(context, pulse);
                      },
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

  Widget _buildMoodCard(BuildContext context, MoodPulse pulse) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPulseDetails(context, pulse),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                _moodIcons[pulse.mood] ?? '❓',
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pulse.mood.name.toUpperCase(),
                      style: TextStyle(
                        color: _moodColors[pulse.mood],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pulse.createdAt.toString().split('.')[0],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPulseDetails(BuildContext context, MoodPulse p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 25, 29, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(_moodIcons[p.mood] ?? '', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Text(
              p.mood.name.toUpperCase(),
              style: TextStyle(
                color: _moodColors[p.mood],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: p.supports.isEmpty
              ? const Text(
            "No support messages yet.",
            style: TextStyle(color: Colors.white70),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: p.supports.length,
            itemBuilder: (context, index) {
              final support = p.supports[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
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