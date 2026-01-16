import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pulse_event.dart';
import 'pulse_state.dart';
import '../data/models/pulse_model.dart';

class PulseBloc extends Bloc<PulseEvent, PulseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PulseBloc() : super(PulseState()) {
   on<StreamPulses>((event, emit) async {
  emit(state.copyWith(isLoading: true));

  await emit.forEach(
    _firestore
        .collection('pulses')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots(),
    onData: (QuerySnapshot snapshot) {
      final pulses = snapshot.docs.map((doc) => MoodPulse.fromFirestore(doc)).toList();
      final currentUid = _auth.currentUser?.uid;
      
      bool postedToday = false;
      String? todayId;

      if (currentUid != null) {
        final now = DateTime.now();
        
        try {
          // 1. Find the pulse that belongs to the user and was created today
          final MoodPulse todayPulse = pulses.firstWhere(
            (p) =>
                p.userId == currentUid &&
                p.createdAt.day == now.day &&
                p.createdAt.month == now.month &&
                p.createdAt.year == now.year,
          );

          // 2. If found, set these variables
          postedToday = true;
          todayId = todayPulse.id; 
        } catch (e) {
          // If no pulse is found, firstWhere throws an error, 
          // so we catch it and keep the default values (false/null)
          postedToday = false;
          todayId = null;
        }
      }

      return state.copyWith(
        pulses: pulses,
        isLoading: false,
        hasPostedToday: postedToday,
        todayPulseId: todayId, // Now todayId has a real value!
      );
    },
  );
});

    on<DeleteTodayPulse>((event, emit) async {
      try {
        await _firestore.collection('pulses').doc(event.pulseId).delete();
      } catch (e) {
        print("Error deleting pulse: $e");
      }
    });

    on<AddPulse>((event, emit) async {
      final uid = _auth.currentUser?.uid;
      if (uid == null || state.hasPostedToday) return;

      await _firestore.collection('pulses').add({
        'mood': event.mood.toString(),
        'userId': uid,
        'comment': event.comment,
        'supports': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    on<AddSupport>((event, emit) async {
      await _firestore.collection('pulses').doc(event.pulseId).update({
        'supports': FieldValue.arrayUnion([event.message])
      });
    });

    on<ToggleLike>((event, emit) async {
      try {
        final pulseRef = _firestore.collection('pulses').doc(event.pulseId);
        final doc = await pulseRef.get();
        if (!doc.exists) return;

        final List<String> likes = List<String>.from(doc.data()?['likes'] ?? []);

        if (likes.contains(event.userId)) {
          await pulseRef.update({
            'likes': FieldValue.arrayRemove([event.userId])
          });
        } else {
          await pulseRef.update({
            'likes': FieldValue.arrayUnion([event.userId])
          });
        }
      } catch (e) {
        print("Error toggling like: $e");
      }
    });
  }
}