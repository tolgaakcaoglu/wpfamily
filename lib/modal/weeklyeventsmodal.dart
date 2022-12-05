import 'package:wpfamilylastseen/modal/eventsmodal.dart';

class WeeklyEvents {
  final String startDay, endDay;
  final List<Events> events;

  WeeklyEvents({this.startDay, this.endDay, this.events});

  static WeeklyEvents build(Map json) {
    return WeeklyEvents(
      startDay: json["start_day"],
      endDay: json["end_day"], // ! START DAY END DAY OLARAK GELECEK
      events: toEvents(json["events"]),
    );
  }

  static toEvents(List<Map> json) => json.map((e) => Events.build(e)).toList();
}
