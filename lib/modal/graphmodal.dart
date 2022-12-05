class Graphics {
  final String hour, duraction;
  final int count;

  Graphics({this.hour, this.duraction, this.count});

  static Graphics build(Map json) {
    return Graphics(
      hour: json["hour"],
      count: json["count"],
      duraction: json["duraction"],
    );
  }
}
