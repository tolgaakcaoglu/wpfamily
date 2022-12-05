class Products {
  final String sku, trackHour, name, line_1;
  final bool isDemo;
  Products({this.isDemo, this.sku, this.trackHour, this.name, this.line_1});

  static Products build(Map json) {
    return Products(
      sku: json["sku"],
      trackHour: json["track_hour"],
      isDemo: json["uuid"],
      name: json["name"],
      line_1: json["line_1"],
    );
  }
}
