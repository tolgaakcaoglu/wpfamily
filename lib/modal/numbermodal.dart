import 'package:wpfamilylastseen/modal/graphmodal.dart';
import 'package:wpfamilylastseen/modal/productsmodal.dart';

class Number {
  final String id, statusDesc, name, countryCode, number;
  final int notification, status;
  final bool isTracking;
  final Products product;
  final List<Graphics> graphics;

  Number(
      {this.id,
      this.statusDesc,
      this.product,
      this.name,
      this.countryCode,
      this.number,
      this.graphics,
      this.notification,
      this.status,
      this.isTracking});

  static Number build(Map json) {
    return Number(
      id: json["id"],
      notification: json["notification"],
      status: json["status"],
      statusDesc: json["status_desc"],
      name: json["name"],
      countryCode: json["country_code"],
      number: json["number"],
      isTracking: json["is_tracking"],
      product:
          Products(sku: json["product"]["sku"], name: json["product"]["name"]),
      graphics: toGraph(json["graphics"]),
      
    );
  }

  static toGraph(List<Map> json) => json.map((e) => Graphics.build(e)).toList();
}
