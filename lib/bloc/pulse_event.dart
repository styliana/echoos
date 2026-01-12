import '../data/models/pulse_model.dart';

sealed class PulseEvent {}

class StreamPulses extends PulseEvent {}

/// create a pulse
class AddPulse extends PulseEvent {
  final Mood mood;
  AddPulse(this.mood);
}

/// add a support in a pulse
class AddSupport extends PulseEvent {
  final String pulseId;
  final String message;
  AddSupport(this.pulseId, this.message);
}