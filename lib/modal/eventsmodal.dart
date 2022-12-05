class Events {
  final String onlineHour, offlineHour, duraction, onlineDate, offlineDate;

  Events(
      {this.onlineHour,
      this.offlineHour,
      this.duraction,
      this.onlineDate,
      this.offlineDate});

  static Events build(Map json) {
    return Events(
      onlineHour: json["online_hour"],
      offlineHour: json["offline_hour"],
      duraction: json["duraction"],
      onlineDate: json["online_date"],
      offlineDate: json["offline_date"],
    );
  }
}
