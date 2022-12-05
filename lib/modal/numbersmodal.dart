import 'package:wpfamilylastseen/modal/eventsmodal.dart';
import 'package:wpfamilylastseen/modal/productsmodal.dart';

class Numbers {
  final String id, statusDesc, name, countryCode, number;
  final int notification, status;
  final bool isTracking;
  final Products product;
  final List<Events> events;

  Numbers(
      {this.id,
      this.statusDesc,
      this.events,
      this.name,
      this.countryCode,
      this.number,
      this.notification,
      this.status,
      this.isTracking,
      this.product});

  static Numbers build(Map json) {
    return Numbers(
        id: json["id"],
        notification: json["notification"],
        status: json["status"],
        statusDesc: json["status_desc"],
        name: json["name"],
        countryCode: json["country_code"],
        number: json["number"],
        isTracking: json["is_tracking"],
        product: Products(
          sku: json["product"]["sku"],
          name: json["product"]["name"],
        ),
        events: toEvent(json["events"]));
  }

  static toEvent(List<Map> json) => json.map((e) => Events.build(e)).toList();
}
