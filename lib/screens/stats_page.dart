import 'package:flutter/material.dart';
import 'emotion_calendar_page.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  // TODO: Implement logic to fetch emotions by date from DB/State
  // Map<DateTime, String> get emotionsData => ...

  // TODO: Calculate the number of consecutive days an emotion was set (streak)
  int get consecutiveDaysStreak => 0;

  // TODO: Fetch the count of support messages received
  int get receivedMessagesCount => 0;

  // TODO: Fetch the count of messages sent
  int get sentMessagesCount => 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FloatingActionButton(
          heroTag: "stats_details",
          onPressed: () => _showStatsModal(context),
          backgroundColor: Colors.white10,
          child: const Icon(Icons.bar_chart, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 8,
                  left: 30,
                  bottom: 20
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "GlobalPulse",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "Stats",
                    style: TextStyle(
                      color: Colors.purple.withOpacity(0.8),
                      fontSize: 20,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 2,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pass context to the builder method
            _buildEmotionCalendar(context),

            const Divider(color: Colors.white10, height: 40),

            const Expanded(
              child: Center(
                child: Text(
                  'Detailed history will appear here...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to navigate to the new page
  Widget _buildEmotionCalendar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmotionCalendarPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Emotion Calendar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to view your full history',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month, color: Colors.purpleAccent),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Your Statistics",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _statRow(
                icon: Icons.local_fire_department,
                label: "Emotion Streak",
                value: "$consecutiveDaysStreak Days",
                color: Colors.orange,
              ),
              const Divider(color: Colors.white10, height: 32),
              _statRow(
                icon: Icons.favorite,
                label: "Support Received",
                value: "$receivedMessagesCount Messages",
                color: Colors.pinkAccent,
              ),
              const Divider(color: Colors.white10, height: 32),
              _statRow(
                icon: Icons.send_rounded,
                label: "Messages Sent",
                value: "$sentMessagesCount",
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _statRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}