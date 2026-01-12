import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Mood { happy, stressed, sad, angry, calm }

const _moodLabels = {
  Mood.happy: 'Happy',
  Mood.stressed: 'Stressed',
  Mood.sad: 'Sad',
  Mood.angry: 'Angry',
  Mood.calm: 'Calm',
};

const _moodIcons = {
  Mood.happy: Icons.sentiment_satisfied,
  Mood.stressed: Icons.sentiment_dissatisfied,
  Mood.sad: Icons.mood_bad,
  Mood.angry: Icons.sentiment_very_dissatisfied,
  Mood.calm: Icons.self_improvement,
};

const _moodColors = {
  Mood.happy: Colors.amber,
  Mood.stressed: Colors.redAccent,
  Mood.sad: Colors.blueGrey,
  Mood.angry: Colors.deepOrange,
  Mood.calm: Colors.teal,
};

class GlobalPulsePage extends StatefulWidget {
  const GlobalPulsePage({super.key});

  @override
  State<GlobalPulsePage> createState() => _GlobalPulsePageState();
}

class _Particle {
  final String id;
  Offset pos;
  Offset vel;
  final Mood mood;
  final double size;
  final bool isMine;
  final List<String> supports;

  _Particle({
    required this.id,
    required this.pos,
    required this.vel,
    required this.mood,
    required this.size,
    this.isMine = false,
    List<String>? supports,
  }) : supports = supports ?? [];
}

class _GlobalPulsePageState extends State<GlobalPulsePage> with SingleTickerProviderStateMixin {
  final List<_Particle> _particles = [];
  late final Ticker _ticker;
  late final Random _rand;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _rand = Random();
    // start with a few particles
    for (var i = 0; i < 12; i++) {
      _particles.add(_randomParticle());
    }

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  _Particle _randomParticle({Offset? pos, Mood? mood, bool isMine = false}) {
    final moods = Mood.values;
    final chosen = mood ?? moods[_rand.nextInt(moods.length)];
    final size = 28.0 + _rand.nextDouble() * 36.0;
    final vel = Offset((_rand.nextDouble() - 0.5) * 120.0, (_rand.nextDouble() - 0.5) * 120.0);
    return _Particle(
      id: DateTime.now().microsecondsSinceEpoch.toString() + '-' + _rand.nextInt(10000).toString(),
      pos: pos ?? Offset(_rand.nextDouble() * 300, _rand.nextDouble() * 500),
      vel: vel,
      mood: chosen,
      size: size,
      isMine: isMine,
    );
  }

  void _onTick(Duration elapsed) {
    final dt = (_last == Duration.zero) ? 0.016 : (elapsed - _last).inMilliseconds / 1000.0;
    _last = elapsed;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    setState(() {
      for (final p in _particles) {
        var nx = p.pos.dx + p.vel.dx * dt;
        var ny = p.pos.dy + p.vel.dy * dt;

        // bounce
        if (nx < 0) { nx = 0; p.vel = Offset(-p.vel.dx, p.vel.dy); }
        if (nx > w - p.size) { nx = w - p.size; p.vel = Offset(-p.vel.dx, p.vel.dy); }
        if (ny < 0) { ny = 0; p.vel = Offset(p.vel.dx, -p.vel.dy); }
        if (ny > h - p.size - 80) { ny = h - p.size - 80; p.vel = Offset(p.vel.dx, -p.vel.dy); }

        // gentle friction
        p.vel = p.vel * 0.995;

        p.pos = Offset(nx, ny);
      }
    });
  }

  void _addParticle({Offset? where, Mood? mood, bool isMine = false}) {
    final pos = where ?? Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
    setState(() => _particles.add(_randomParticle(pos: pos, mood: mood, isMine: isMine)));
  }

  Future<void> _openMoodPicker() async {
    final chosen = await showModalBottomSheet<Mood>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            spacing: 10,
            children: Mood.values.map((m) {
              return ElevatedButton.icon(
                icon: Icon(_moodIcons[m], color: Colors.white),
                label: Text(_moodLabels[m]!),
                style: ElevatedButton.styleFrom(backgroundColor: _moodColors[m]),
                onPressed: () => Navigator.of(ctx).pop(m),
              );
            }).toList(),
          ),
        );
      },
    );

    if (chosen != null) {
      // add user's mood particle at center
      _addParticle(mood: chosen, isMine: true);
    }
  }

  Future<void> _openSupportModal(_Particle p) async {
    final option = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        final options = ['Send hug', 'Breathe together', 'Share resources', 'Send kind message'];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((o) => ListTile(title: Text(o), onTap: () => Navigator.of(ctx).pop(o))).toList(),
        );
      },
    );

    if (option != null) {
      if (!mounted) return;
      setState(() => p.supports.add('$option • ${TimeOfDay.now().format(context)}'));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support sent anonymously')));
    }
  }

  void _openMyMoods() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _MyMoodsPage(particles: _particles.where((p) => p.isMine).toList())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Pulse'),
        actions: [
          IconButton(onPressed: _openMyMoods, icon: const Icon(Icons.person)),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Account'),
                  content: Text(user == null
                      ? 'Not signed in'
                      : (user.isAnonymous ? 'Signed in anonymously' : 'Signed in as ${user.email ?? user.uid}')),
                  actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                ),
              );
            },
          ),
          IconButton(onPressed: () async => await FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: GestureDetector(
        // free clicks no longer add particles
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [Color(0xFF0F172A), Color(0xFF071126)],
            ),
          ),
          child: Stack(
            children: [
              // floating particles
              for (final p in _particles)
                Positioned(
                  left: p.pos.dx,
                  top: p.pos.dy,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (!p.isMine) _openSupportModal(p);
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: p.size,
                          height: p.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _moodColors[p.mood]!.withOpacity(0.95),
                            border: p.isMine ? Border.all(color: Colors.white, width: 2) : null,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                          ),
                          child: Icon(_moodIcons[p.mood], color: Colors.white, size: p.size * 0.6),
                        ),
                        if (!p.isMine && p.supports.isNotEmpty)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              child: Text('${p.supports.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        if (p.isMine)
                          const Positioned(
                            left: 0,
                            bottom: -14,
                            child: Text('You', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ),
                      ],
                    ),
                  ),
                ),

              // Center message
              const Center(child: Text('Press the mood button to set your mood • Tap other bubbles to send support', style: TextStyle(color: Colors.white70))),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Set mood',
        child: const Icon(Icons.mood),
        onPressed: _openMoodPicker,
      ),
    );
  }
}

class _MyMoodsPage extends StatelessWidget {
  final List<_Particle> particles;
  const _MyMoodsPage({required this.particles, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Moods')),
      body: particles.isEmpty
          ? const Center(child: Text('You have no recorded moods yet.'))
          : ListView.builder(
              itemCount: particles.length,
              itemBuilder: (context, index) {
                final p = particles[index];
                return ListTile(
                  leading: Icon(_moodIcons[p.mood], color: _moodColors[p.mood]),
                  title: Text(_moodLabels[p.mood]!),
                  subtitle: p.supports.isEmpty ? const Text('No support received') : Text('${p.supports.length} support(s) received'),
                  trailing: p.supports.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (_) {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: p.supports.map((s) => ListTile(title: Text(s))).toList(),
                                  );
                                });
                          },
                        ),
                );
              },
            ),
    );
  }
}