class PremiumPackage {
  final String packageName, tag;
  final double price;

  PremiumPackage({this.packageName, this.tag, this.price});

  factory PremiumPackage.build(Map<String, dynamic> json) {
    return PremiumPackage(
      packageName: json['packageName'],
      tag: json['tag'],
      price: double.parse(json['price']),
    );
  }
}
