import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:belfort/screens/emotion_calendar_page.dart';
import 'package:belfort/screens/stats_page.dart';
import 'package:belfort/screens/mood_journey_page.dart';
import 'package:belfort/screens/theme_provider.dart';
import 'package:belfort/screens/reminder_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('You logged out')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 30, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "E c h o o s",
                      style: TextStyle(
                        color: themeProvider.primaryTextColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        color: themeProvider.dashboardAccent.withOpacity(0.8),
                        fontSize: 20,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8, left: 8),
                      height: 2,
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.dashboardAccent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeProvider.dashboardAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              themeProvider.dashboardAccent.withOpacity(0.3),
                              themeProvider.dashboardAccent.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.transparent,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Icon(
                                  Icons.person,
                                  color: themeProvider.primaryTextColor,
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? "Utilisateur",
                              style: TextStyle(
                                color: themeProvider.primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? "",
                              style: TextStyle(
                                color: themeProvider.secondaryTextColor,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: SafeArea(
                  bottom: true,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    children: [
                      _buildMenuButton(
                        context,
                        themeProvider,
                        title: 'Statistics',
                        icon: Icons.bar_chart_sharp,
                        color: themeProvider.dashboardAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatsPage(),
                          ),
                        ),
                      ),
                      _buildMenuButton(
                        context,
                        themeProvider,
                        title: 'Calendar',
                        icon: Icons.calendar_month_sharp,
                        color: themeProvider.dashboardAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmotionCalendarPage(),
                          ),
                        ),
                      ),
                      _buildMenuButton(
                        context,
                        themeProvider,
                        title: 'My journey',
                        icon: Icons.mail_sharp,
                        color: themeProvider.dashboardAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoodJourneyPage(),
                          ),
                        ),
                      ),
                      _buildMenuButton(
                        context,
                        themeProvider,
                        title: 'Reminders',
                        icon: Icons.notifications_active_sharp,
                        color: themeProvider.dashboardAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReminderPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Theme Toggle Button
                      _buildMenuButton(
                        context,
                        themeProvider,
                        title: themeProvider.isDarkMode
                            ? 'Light Mode'
                            : 'Dark Mode',
                        icon: themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: themeProvider.isDarkMode
                            ? Colors.amber
                            : Colors.indigo,
                        onTap: () => themeProvider.toggleTheme(),
                      ),

                      const SizedBox(height: 10),
                      _buildMenuButton(
                        context,
                        themeProvider,
                        title: 'Logout',
                        icon: Icons.logout_sharp,
                        color: Colors.redAccent,
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    ThemeProvider themeProvider, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: isOutlined
                ? Colors.transparent
                : themeProvider.cardColor(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOutlined
                  ? color.withOpacity(0.5)
                  : color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  color: themeProvider.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: themeProvider.subtleTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
