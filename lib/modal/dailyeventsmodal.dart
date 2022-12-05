import 'package:wpfamilylastseen/modal/eventsmodal.dart';

class DailyEvents {
  final String day;
  final List<Events> events;

  DailyEvents({this.day, this.events});

  static DailyEvents build(Map json) {
    return DailyEvents(
      day: json["day"],
      events: toEvents(json["events"]),
    );
  }

  static toEvents(List<Map> json) => json.map((e) => Events.build(e)).toList();
}
