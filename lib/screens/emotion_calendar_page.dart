import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml if needed, or use basic formatting
import '../data/models/pulse_model.dart';

// Reusing your mood colors
const _moodColors = {
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

  // Helper to get days in month
  List<DateTime> _getDaysInMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    return List.generate(daysInMonth, (index) => DateTime(date.year, date.month, index + 1));
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Mood Journey", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch ALL of the user's pulses to map them to the calendar
        stream: FirebaseFirestore.instance
            .collection('pulses')
            .where('userId', isEqualTo: _uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading calendar", style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          // Process Data: Map DateTime(Day) -> MoodPulse
          // We use a Map<String, Mood> where Key is "YYYY-MM-DD" for easy lookup
          final Map<String, Mood> moodMap = {};
          
          for (var doc in snapshot.data!.docs) {
            final pulse = MoodPulse.fromFirestore(doc);
            // Key format: 2023-10-05
            final key = "${pulse.createdAt.year}-${pulse.createdAt.month}-${pulse.createdAt.day}";
            // If multiple entries exist for a day, this simple logic takes the last one processed.
            // You could add logic here to "average" them or pick the most intense one.
            moodMap[key] = pulse.mood;
          }

          return Column(
            children: [
              _buildMonthHeader(),
              _buildDaysOfWeek(),
              Expanded(
                child: _buildCalendarGrid(moodMap),
              ),
              _buildLegend(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader() {
    // Basic date formatting
    final monthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final title = "${monthName[_focusedDay.month - 1]} ${_focusedDay.year}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.tealAccent, size: 30),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300, fontFamily: 'Georgia'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.tealAccent, size: 30),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) => Text(d, style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold))).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, Mood> moodMap) {
    final days = _getDaysInMonth(_focusedDay);
    // Calculate offset for the first day of the month (Monday = 1, Sunday = 7)
    final firstDayWeekday = days.first.weekday; 
    
    // Grid Logic
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days a week
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      // Total count includes empty slots before the 1st of the month
      itemCount: days.length + (firstDayWeekday - 1),
      itemBuilder: (context, index) {
        if (index < firstDayWeekday - 1) {
          return const SizedBox(); // Empty slot
        }
        
        final date = days[index - (firstDayWeekday - 1)];
        final dateKey = "${date.year}-${date.month}-${date.day}";
        final mood = moodMap[dateKey];
        final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year;

        return Container(
          decoration: BoxDecoration(
            color: mood != null 
                ? _moodColors[mood]!.withOpacity(0.8) 
                : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: Colors.white, width: 2) : null,
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
      color: Colors.white10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: Mood.values.map((m) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12, 
                height: 12, 
                decoration: BoxDecoration(color: _moodColors[m], shape: BoxShape.circle),
              ),
              const SizedBox(height: 4),
              Text(
                m.name[0].toUpperCase() + m.name.substring(1), 
                style: const TextStyle(color: Colors.white70, fontSize: 10)
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}