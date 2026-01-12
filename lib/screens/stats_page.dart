import 'package:flutter/material.dart';

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

            _buildEmotionCalendar(),

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

  Widget _buildEmotionCalendar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emotion Calendar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Calendar by month will appear here...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // TODO: RE-IMPLEMENT AS A MONTHLY GRID (7 DAYS PER ROW)
          // Use a GridView.builder with crossAxisCount: 7
          // Logic should display days for each month and show the recorded emotion per day
        ],
      ),
    );
  }

  Widget _buildCalendarDayTile(int index) {
    // TODO: Connect to your emotion data provider
    bool hasEmotion = false;

    return Container(
      width: 55,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${DateTime.now().subtract(Duration(days: index)).day}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            hasEmotion ? Icons.face : Icons.radio_button_off,
            color: hasEmotion ? Colors.purpleAccent : Colors.white24,
            size: 20,
          ),
        ],
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
