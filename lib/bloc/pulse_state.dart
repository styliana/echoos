import '../data/models/pulse_model.dart';

class PulseState {

  /// list of pulses
  final List<MoodPulse> pulses;

  /// in load
  final bool isLoading;

  /// contain error message
  final String? error;

  /// verification to create new pulse
  final bool hasPostedToday;

  final String? todayPulseId;


  PulseState({
    this.pulses = const [],
    this.isLoading = false,
    this.error,
    this.hasPostedToday = false,
    this.todayPulseId,
  });

  PulseState copyWith({
    List<MoodPulse>? pulses,
    bool? isLoading,
    String? error,
    bool? hasPostedToday,
    String? todayPulseId,
  }) {
    return PulseState(
      pulses: pulses ?? this.pulses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasPostedToday: hasPostedToday ?? this.hasPostedToday,
      todayPulseId: todayPulseId ?? this.todayPulseId,
    );
  }
}