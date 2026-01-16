import '../data/models/pulse_model.dart';

sealed class PulseEvent {}

class StreamPulses extends PulseEvent {}

/// ADD a pulse
class AddPulse extends PulseEvent {
  final Mood mood;
  final String? comment;
  AddPulse(this.mood, {this.comment});
}

/// ADD a support in a pulse
class AddSupport extends PulseEvent {
  final String pulseId;
  final String message;
  AddSupport(this.pulseId, this.message);
}

/// ADD/DELETE like in a pulse
class ToggleLike extends PulseEvent {
  final String pulseId;
  final String userId;
  ToggleLike(this.pulseId, this.userId);
}
/// DELETE today's pulse
class DeleteTodayPulse extends PulseEvent {
  final String pulseId;
  DeleteTodayPulse(this.pulseId);
}