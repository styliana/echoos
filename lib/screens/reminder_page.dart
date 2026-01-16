import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


// TODO : reminder does not working with date (i dont understand..)
class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  bool _isReminderEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 00);
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadSettings();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notificationsPlugin.initialize(const InitializationSettings(android: androidSettings));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderEnabled = prefs.getBool('reminder_enabled') ?? false;
      _selectedTime = TimeOfDay(
        hour: prefs.getInt('reminder_hour') ?? 20,
        minute: prefs.getInt('reminder_minute') ?? 0,
      );
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', _isReminderEnabled);
    await prefs.setInt('reminder_hour', _selectedTime.hour);
    await prefs.setInt('reminder_minute', _selectedTime.minute);
    await _scheduleNotification();
  }

  Future<void> _scheduleNotification() async {
    await _notificationsPlugin.cancelAll();

    if (!_isReminderEnabled) return;

    try {
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final durationUntilNotify = scheduledDate.difference(now);

      final tzScheduledDate = tz.TZDateTime.now(tz.local).add(durationUntilNotify);

      print("--- DEBUG ---");
      print("Maintenant : $now");
      print("Programmé pour : $scheduledDate");
      print("Dans : ${durationUntilNotify.inMinutes} minutes");

      await _notificationsPlugin.zonedSchedule(
        0,
        'Echoos',
        "Its time to share your mood !",
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'echoos_reminder_high_priority',
            'Rappels Echoos',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
            styleInformation: BigTextStyleInformation(''),
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print("Notification save !");
    } catch (e) {
      print("Error : $e");
    }
  }
  Future<void> _testNow() async {
    await _notificationsPlugin.show(
        99,
        'Echoos Test',
        'System ok !',
        const NotificationDetails(
            android: AndroidNotificationDetails(
              'test', 'test',
              importance: Importance.max,
              priority: Priority.high,
              color: Colors.purpleAccent,
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reminders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E1E3F),
                  Color(0xFF2D1B4E),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  _buildGlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Daily notification",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            Text("Stay consistent with your mood",
                                style: TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                        Switch(
                          value: _isReminderEnabled,
                          activeColor: Colors.purpleAccent,
                          activeTrackColor: Colors.purpleAccent.withOpacity(0.3),
                          inactiveThumbColor: Colors.white24,
                          onChanged: (val) {
                            setState(() => _isReminderEnabled = val);
                            _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildGlassCard(
                    child: InkWell(
                      onTap: _isReminderEnabled ? () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.purpleAccent)),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked);
                          _saveSettings();
                        }
                      } : null,
                      child: Opacity(
                        opacity: _isReminderEnabled ? 1.0 : 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.access_time_rounded, color: Colors.purpleAccent),
                                SizedBox(width: 12),
                                Text("Reminder time",
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.purpleAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Spacer(),

                  if (_isReminderEnabled)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Text(
                          "Next reminder at ${_selectedTime.format(context)}",
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}