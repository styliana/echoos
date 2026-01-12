import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class GlobalPulsePage extends StatelessWidget {
  const GlobalPulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PulseBloc()..add(StreamPulses()),
      child: const GlobalPulseView(),
    );
  }
}

class GlobalPulseView extends StatefulWidget {
  const GlobalPulseView({super.key});

  @override
  State<GlobalPulseView> createState() => _GlobalPulseViewState();
}

class _GlobalPulseViewState extends State<GlobalPulseView> {
  final Map<String, _BubbleSettings> _bubbleConfigs = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              ...List.generate(15, (index) => const _BackgroundParticle()),

              Positioned(
                top: 58,
                left: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GlobalPulse",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      "Community",
                      style: TextStyle(
                        color: Colors.tealAccent.withOpacity(0.8),
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
                          colors: [Colors.tealAccent, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ...state.pulses.map((p) {
                _bubbleConfigs.putIfAbsent(p.id, () => _BubbleSettings());
                final config = _bubbleConfigs[p.id]!;

                return _FloatingBubble(
                  pulse: p,
                  config: config,
                  onTap: () => _showSupportModal(context, p),
                );
              }).toList(),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildFabRow(context, state),
        );
      },
    );
  }

  Widget _buildFabRow(BuildContext context, PulseState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: "history",
            onPressed: () => _showHistory(context, state.pulses),
            backgroundColor: Colors.white10,
            child: const Icon(Icons.history, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: "add",
            onPressed: state.hasPostedToday
                ? null
                : () => _showAddMoodDialog(context),
            backgroundColor: state.hasPostedToday
                ? Colors.grey
                : Colors.tealAccent,
            child: Icon(
              state.hasPostedToday ? Icons.check : Icons.add,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context, List<MoodPulse> allPulses) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final myHistory = allPulses.where((p) => p.userId == myUid).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "My Mood Journey",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
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
                            "${p.supports.length} supports received",
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
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

  void _showAddMoodDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (innerContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "How are you feeling?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Mood.values
                  .map(
                    (m) => IconButton(
                      icon: Text(
                        _moodIcons[m]!,
                        style: const TextStyle(fontSize: 40),
                      ),
                      onPressed: () {
                        context.read<PulseBloc>().add(AddPulse(m));
                        Navigator.pop(innerContext);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSupportModal(BuildContext context, MoodPulse pulse) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 30,
          right: 30,
          top: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Send Support",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Send a kind word to someone feeling ${pulse.mood.name}",
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<PulseBloc>().add(
                    AddSupport(pulse.id, controller.text.trim()),
                  );
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "SEND",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _BubbleSettings {
  final double size = 40.0 + Random().nextDouble() * 40.0;
  final Offset startPos = Offset(
    Random().nextDouble() * 300,
    150 + Random().nextDouble() * 400,
  );
  final double speed = 0.2 + Random().nextDouble() * 0.5;
}

class _FloatingBubble extends StatefulWidget {
  final MoodPulse pulse;
  final _BubbleSettings config;
  final VoidCallback onTap;

  const _FloatingBubble({
    required this.pulse,
    required this.config,
    required this.onTap,
  });

  @override
  State<_FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<_FloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _randomSeed;

  @override
  void initState() {
    super.initState();
    _randomSeed = Random().nextDouble() * 100;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value * 2 * pi;
        final dx = sin(t + _randomSeed) * 15;
        final dy = cos(t * 0.5 + _randomSeed) * 20;
        final pulseScale = 1.0 + (sin(t * 2) * 0.05);

        return Positioned(
          left: widget.config.startPos.dx + dx,
          top: widget.config.startPos.dy + dy,
          child: Transform.scale(
            scale: pulseScale,
            child: GestureDetector(
              onTap: widget.onTap,
              child: _buildBubbleUI(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBubbleUI() {
    final color = _moodColors[widget.pulse.mood]!;
    return Container(
      width: widget.config.size,
      height: widget.config.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.7), color.withOpacity(0.2)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _moodIcons[widget.pulse.mood]!,
              style: TextStyle(fontSize: widget.config.size * 0.45),
            ),
            if (widget.pulse.supports.isNotEmpty)
              Text(
                "${widget.pulse.supports.length}❤️",
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundParticle extends StatefulWidget {
  const _BackgroundParticle();

  @override
  State<_BackgroundParticle> createState() => _BackgroundParticleState();
}

class _BackgroundParticleState extends State<_BackgroundParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Offset pos;

  @override
  void initState() {
    super.initState();
    pos = Offset(Random().nextDouble() * 400, Random().nextDouble() * 800);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5 + Random().nextInt(5)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Positioned(
        left: pos.dx,
        top: pos.dy - (_ctrl.value * 100),
        child: Opacity(
          opacity: 0.1,
          child: Container(
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
