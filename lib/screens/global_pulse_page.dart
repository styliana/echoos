import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../bloc/pulse_bloc.dart';
import '../bloc/pulse_event.dart';
import '../bloc/pulse_state.dart';
import '../data/models/pulse_model.dart';
import '../screens/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        final myUid = FirebaseAuth.instance.currentUser?.uid;
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: themeProvider.backgroundGradient,
                  ),
                ),
              ),
              ...List.generate(15, (index) => _BackgroundParticle(themeProvider: themeProvider)),

              Positioned(
                top: 50,
                left: 30,
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
                      "Community",
                      style: TextStyle(
                        color: themeProvider.pulseAccent.withOpacity(0.8),
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
                          colors: [themeProvider.pulseAccent, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ...state.pulses.map((p) {
                _bubbleConfigs.putIfAbsent(p.id, () => _BubbleSettings());
                final config = _bubbleConfigs[p.id]!;
                final isMine = p.userId == myUid;

                return _FloatingBubble(
                  pulse: p,
                  config: config,
                  isMine: isMine,
                  onTap: isMine
                      ? () => _showCannotSupportSelfSnack(context)
                      : () => _showSupportModal(context, p),
                );
              }).toList(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildFabRow(context, state, themeProvider),
        );
      },
    );
  }

Widget _buildFabRow(BuildContext context, PulseState state, ThemeProvider themeProvider) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 0, 10, 90),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "add",
          onPressed: state.hasPostedToday 
              ? () => _showDeleteConfirmation(context, state.todayPulseId)
              : () => _showAddMoodDialog(context),
          backgroundColor: state.hasPostedToday
              ? Colors.redAccent.withOpacity(0.4)
              : themeProvider.cardColor(0.4),
          child: Icon(
            state.hasPostedToday ? Icons.delete_outline : Icons.add,
            color: themeProvider.primaryTextColor,
          ),
        ), // <--- ADDED THIS CLOSING PARENTHESIS
      ],
    ),
  );
}

  void _showAddMoodDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final TextEditingController commentController = TextEditingController();
    Mood? selectedMood;
    final pulseBloc = context.read<PulseBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeProvider.isDarkMode
          ? const Color.fromARGB(255, 25, 29, 44)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (innerContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Share your mood",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryTextColor,
                ),
              ),
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
                        color: isSelected
                            ? themeProvider.accentColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? themeProvider.accentColor
                              : themeProvider.cardColor(0.1),
                        ),
                      ),
                      child: Text(_moodIcons[m]!, style: const TextStyle(fontSize: 30)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                style: TextStyle(color: themeProvider.primaryTextColor),
                maxLength: 35,
                decoration: InputDecoration(
                  hintText: "Optional note...",
                  hintStyle: TextStyle(color: themeProvider.subtleTextColor),
                  filled: true,
                  fillColor: themeProvider.cardColor(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.accentColor,
                    foregroundColor: Colors.black,
                  ),
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

  void _showDeleteConfirmation(BuildContext context, String? pulseId) {
  if (pulseId == null) return;
  
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final pulseBloc = context.read<PulseBloc>();

  showDialog(
    context: context,
    builder: (innerContext) => AlertDialog(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF161A2B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Delete today's mood?", 
        style: TextStyle(color: themeProvider.primaryTextColor)),
      content: Text("Are you sure you want to remove your entry for today?",
        style: TextStyle(color: themeProvider.secondaryTextColor)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(innerContext),
          child: Text("CANCEL", style: TextStyle(color: themeProvider.subtleTextColor)),
        ),
        TextButton(
          onPressed: () {
            pulseBloc.add(DeleteTodayPulse(pulseId)); // Make sure this event exists in pulse_event.dart
            Navigator.pop(innerContext);
          },
          child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

  void _showSupportModal(BuildContext context, MoodPulse pulse) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController();
    final pulseBloc = context.read<PulseBloc>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) => BlocBuilder<PulseBloc, PulseState>(
        bloc: pulseBloc,
        builder: (context, state) {
          final updatedPulse = state.pulses.firstWhere(
            (p) => p.id == pulse.id,
            orElse: () => pulse,
          );

          final hasLiked = currentUserId != null && updatedPulse.likes.contains(currentUserId);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: themeProvider.isDarkMode
                    ? [
                        const Color(0xFF161A2B),
                        const Color(0xFF101424),
                        const Color(0xFF000000),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF5F5F5),
                        const Color(0xFFEEEEEE),
                      ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 30,
                right: 30,
                top: 30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pulse Details",
                        style: TextStyle(
                          color: themeProvider.primaryTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                              color: hasLiked ? Colors.redAccent : themeProvider.secondaryTextColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${updatedPulse.likes.length}",
                              style: TextStyle(
                                color: hasLiked ? Colors.redAccent : themeProvider.secondaryTextColor,
                              ),
                            ),
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
                        color: themeProvider.cardColor(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: themeProvider.accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                color: themeProvider.accentColor.withOpacity(0.5),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "COMMENT",
                                style: TextStyle(
                                  color: themeProvider.accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            updatedPulse.comment!,
                            style: TextStyle(
                              color: themeProvider.primaryTextColor,
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
                    style: TextStyle(color: themeProvider.primaryTextColor),
                    decoration: InputDecoration(
                      hintText: "Send support message...",
                      hintStyle: TextStyle(color: themeProvider.subtleTextColor),
                      filled: true,
                      fillColor: themeProvider.cardColor(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.accentColor.withOpacity(0.8),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        pulseBloc.add(AddSupport(updatedPulse.id, controller.text));
                        Navigator.pop(sheetContext);
                      }
                    },
                    child: const Text(
                      "SEND SUPPORT",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
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
  final bool isMine;

  const _FloatingBubble({
    required this.pulse,
    required this.config,
    required this.onTap,
    required this.isMine,
  });

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
        border: widget.isMine
            ? Border.all(color: Colors.tealAccent.withOpacity(0.2), width: 3)
            : null,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.7), color.withOpacity(0.2)],
        ),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _moodIcons[widget.pulse.mood]!,
              style: TextStyle(fontSize: widget.config.size * 0.4),
            ),
            if (widget.pulse.likes.isNotEmpty || widget.pulse.supports.isNotEmpty)
              Text(
                "${widget.pulse.likes.length}❤️",
                style: const TextStyle(
                  fontSize: 10,
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
  final ThemeProvider themeProvider;
  
  const _BackgroundParticle({required this.themeProvider});

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
            decoration: BoxDecoration(
              color: widget.themeProvider.isDarkMode ? Colors.white : Colors.black26,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
  
}