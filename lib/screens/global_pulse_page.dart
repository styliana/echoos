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
        final myUid = FirebaseAuth.instance.currentUser?.uid;
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 21, 24, 36), 
                      Color(0xFF1E2235), // middle
                      Color.fromARGB(255, 39, 52, 78), // top-left
                      Color.fromARGB(255, 102, 115, 136), // bottom-right
                    ],
                  ),
                ),
              ),
              ...List.generate(15, (index) => const _BackgroundParticle()),

              Positioned(
                top: 30,
                left: 30,
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
                  onTap: p.userId == myUid
                      ? () => _showCannotSupportSelfSnack(context)
                      : () => _showSupportModal(context, p),
                );
              }).toList(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildFabRow(context, state),
        );
      },
    );
  }

  Widget _buildFabRow(BuildContext context, PulseState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 90), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: "history",
            onPressed: () => _showHistory(context, state.pulses),
            backgroundColor: Colors.white10,
            child: const Icon(Icons.mail_sharp, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: "add",
            onPressed: state.hasPostedToday ? null : () => _showAddMoodDialog(context),
            backgroundColor: state.hasPostedToday ? Color.fromARGB(255, 39, 52, 78).withOpacity(0.2) : Color.fromARGB(255, 102, 115, 136).withOpacity(0.4),
            child: Icon(
              state.hasPostedToday ? Icons.check : Icons.add,
              color: Colors.white,
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
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: myHistory.isEmpty
                  ? const Center(child: Text("No history yet", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                itemCount: myHistory.length,
                itemBuilder: (context, index) {
                  final p = myHistory[index];
                  return ListTile(
                    leading: Text(_moodIcons[p.mood]!, style: const TextStyle(fontSize: 24)),
                    title: Text("Mood from ${p.createdAt.day}/${p.createdAt.month}", style: const TextStyle(color: Colors.white)),
                    subtitle: Text("${p.supports.length} supports • ${p.likes.length} likes", style: const TextStyle(color: Colors.tealAccent)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white24),
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
    final TextEditingController commentController = TextEditingController();
    Mood? selectedMood;
    final pulseBloc = context.read<PulseBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (innerContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Share your mood", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: Mood.values.map((m) {
                  final isSelected = selectedMood == m;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedMood = m),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.tealAccent.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isSelected ? Colors.tealAccent : Colors.white10),
                      ),
                      child: Text(_moodIcons[m]!, style: const TextStyle(fontSize: 30)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                style: const TextStyle(color: Colors.white),
                maxLength: 15,
                decoration: InputDecoration(
                  hintText: "Optional note...",
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
                  onPressed: () {
                    if (selectedMood != null) {
                      pulseBloc.add(AddPulse(selectedMood!, comment: commentController.text));
                      Navigator.pop(innerContext);
                    }
                  },
                  child: const Text("SHARE"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportModal(BuildContext context, MoodPulse pulse) {
    final TextEditingController controller = TextEditingController();
    final pulseBloc = context.read<PulseBloc>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (sheetContext) => BlocBuilder<PulseBloc, PulseState>(
        bloc: pulseBloc,
        builder: (context, state) {
          final updatedPulse = state.pulses.firstWhere(
                (p) => p.id == pulse.id,
            orElse: () => pulse,
          );

          final hasLiked = currentUserId != null && updatedPulse.likes.contains(currentUserId);

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 30,
                right: 30,
                top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Pulse Details",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        if (currentUserId != null) {
                          pulseBloc.add(ToggleLike(updatedPulse.id, currentUserId));
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                              hasLiked ? Icons.favorite : Icons.favorite_border,
                              color: hasLiked ? Colors.redAccent : Colors.white54),
                          const SizedBox(width: 5),
                          Text("${updatedPulse.likes.length}",
                              style: TextStyle(
                                  color: hasLiked
                                      ? Colors.redAccent
                                      : Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (updatedPulse.comment != null && updatedPulse.comment!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.format_quote_rounded,
                                color: Colors.tealAccent.withOpacity(0.5), size: 18),
                            const SizedBox(width: 6),
                            const Text(
                              "COMMENT",
                              style: TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          updatedPulse.comment!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Send support message...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      pulseBloc.add(AddSupport(updatedPulse.id, controller.text));
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: const Text("SEND SUPPORT",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCannotSupportSelfSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("You can't send support to your own bubble."),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _BubbleSettings {
  final double size = 50.0 + Random().nextDouble() * 30.0;
  final Offset startPos = Offset(Random().nextDouble() * 300, 150 + Random().nextDouble() * 400);
}

class _FloatingBubble extends StatefulWidget {
  final MoodPulse pulse;
  final _BubbleSettings config;
  final VoidCallback onTap;

  const _FloatingBubble({required this.pulse, required this.config, required this.onTap});

  @override
  State<_FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<_FloatingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _randomSeed;

  @override
  void initState() {
    super.initState();
    _randomSeed = Random().nextDouble() * 100;
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
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
        return Positioned(
          left: widget.config.startPos.dx + dx,
          top: widget.config.startPos.dy + dy,
          child: GestureDetector(onTap: widget.onTap, child: _buildBubbleUI()),
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
        gradient: RadialGradient(colors: [color.withOpacity(0.7), color.withOpacity(0.2)]),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_moodIcons[widget.pulse.mood]!, style: TextStyle(fontSize: widget.config.size * 0.4)),
            if (widget.pulse.likes.isNotEmpty || widget.pulse.supports.isNotEmpty)
              Text(
                "${widget.pulse.likes.length}❤️",
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
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

class _BackgroundParticleState extends State<_BackgroundParticle> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Offset pos;

  @override
  void initState() {
    super.initState();
    pos = Offset(Random().nextDouble() * 400, Random().nextDouble() * 800);
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: 5 + Random().nextInt(5)))..repeat(reverse: true);
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
          child: Container(width: 2, height: 2, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}