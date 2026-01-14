import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/pulse_model.dart';

const _moodColors2 = {
  Mood.happy: Colors.amber,
  Mood.stressed: Colors.redAccent,
  Mood.sad: Colors.blueGrey,
  Mood.angry: Colors.deepOrange,
  Mood.calm: Colors.teal,
};

class EmotionCalendarPage extends StatefulWidget {
  const EmotionCalendarPage({super.key});

  @override
  State<EmotionCalendarPage> createState() => _EmotionCalendarPageState();
}

class _EmotionCalendarPageState extends State<EmotionCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<DateTime> _getDaysInMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    return List.generate(
      daysInMonth,
          (index) => DateTime(date.year, date.month, index + 1),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.only(top: 20, left: 30, bottom: 30),
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
                            "Calendar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            "Mood tracker",
                            style: TextStyle(
                              color: Colors.blueAccent.withOpacity(0.8),
                              fontSize: 20,
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pulses')
                      .where('userId', isEqualTo: _uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Error loading calendar",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blueAccent),
                      );
                    }

                    final Map<String, Mood> moodMap = {};

                    for (var doc in snapshot.data!.docs) {
                      final pulse = MoodPulse.fromFirestore(doc);
                      final key =
                          "${pulse.createdAt.year}-${pulse.createdAt.month}-${pulse.createdAt.day}";
                      moodMap[key] = pulse.mood;
                    }

                    return Column(
                      children: [
                        _buildMonthHeader(),
                        _buildDaysOfWeek(),
                        Expanded(child: _buildCalendarGrid(moodMap)),
                        _buildLegend(),
                      ],
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

  Widget _buildMonthHeader() {
    final monthName = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    final title = "${monthName[_focusedDay.month - 1]} ${_focusedDay.year}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.blueAccent, size: 30),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              fontFamily: 'Georgia',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.blueAccent, size: 30),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map(
              (d) => Text(
            d,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, Mood> moodMap) {
    final days = _getDaysInMonth(_focusedDay);
    final firstDayWeekday = days.first.weekday;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: days.length + (firstDayWeekday - 1),
      itemBuilder: (context, index) {
        if (index < firstDayWeekday - 1) {
          return const SizedBox();
        }

        final date = days[index - (firstDayWeekday - 1)];
        final dateKey = "${date.year}-${date.month}-${date.day}";
        final mood = moodMap[dateKey];
        final isToday =
            date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;

        return Container(
          decoration: BoxDecoration(
            color: mood != null
                ? _moodColors2[mood]!.withOpacity(0.8)
                : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: Colors.blueAccent, width: 1)
                : mood != null
                ? Border.all(color: _moodColors2[mood]!.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Center(
            child: Text(
              "${date.day}",
              style: TextStyle(
                color: mood != null ? Colors.black : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: Mood.values.map((m) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _moodColors2[m],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.name[0].toUpperCase() + m.name.substring(1),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}