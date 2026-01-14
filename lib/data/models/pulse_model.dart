import 'package:cloud_firestore/cloud_firestore.dart';

enum Mood { happy, stressed, sad, angry, calm }

class MoodPulse {
  final String id;
  final String userId;
  final Mood mood;
  final String? comment;
  final List<String> supports;
  final List<String> likes;
  final DateTime createdAt;

  MoodPulse({
    required this.id,
    required this.userId,
    required this.mood,
    this.comment,
    this.supports = const [],
    this.likes = const [],
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
    /// - comment (List<>) : related comment of pulse
    /// - supports (List<String>): related support messages
    /// - likes (List<String>) : related likes of users
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
      comment: data['comment'],
      supports: List<String>.from(data['supports'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
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