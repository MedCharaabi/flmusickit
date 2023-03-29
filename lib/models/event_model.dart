import 'package:flmusickit/entity/event.dart';

class EventModel extends Event {
  EventModel(super.type, super.data);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final type = EventType.values.firstWhere(
      (element) => element.name == json['type'],
      orElse: () => EventType.unknown,
    );
    return EventModel(
      type,
      json['data'],
    );
  }
}
