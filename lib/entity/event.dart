enum EventType {
  unknown,
  nowPlaying,
  playerState,
}

class Event {
  final EventType type;
  final dynamic data;
  Event(this.type, this.data);
}
