import 'package:cloud_firestore/cloud_firestore.dart';

enum Mood { happy, stressed, sad, angry, calm }

class MoodPulse {
  final String id;
  final String userId;
  final Mood mood;
  final List<String> supports;
  final DateTime createdAt;

  MoodPulse({
    required this.id,
    required this.userId,
    required this.mood,
    this.supports = const [],
    required this.createdAt,
  });

  factory MoodPulse.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    /// Initializes a [MoodPulse] from a Firestore document
    ///
    /// Expected fields in data:
    /// - id (String): firestore document ID
    /// - userId (String): related user ID
    /// - mood (String): mood value (must match a [Mood] enum value)
    /// - supports (List<String>): related support factors
    /// - createdAt (Timestamp): creation date
    ///
    /// Defaults:
    /// - Invalid or missing mood → [Mood.calm]
    /// - Missing supports → empty list
    /// - Missing createdAt → [DateTime.now]
    return MoodPulse(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      mood: Mood.values.firstWhere(
            (e) => e.toString() == data['mood'],
        orElse: () => Mood.calm,
      ),
      supports: List<String>.from(data['supports'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mood': mood.toString(),
      'userId': userId,
      'supports': supports,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}