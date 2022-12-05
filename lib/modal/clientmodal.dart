class Client {
  final String uuid, timezone, locale, version;

  Client({this.uuid, this.timezone, this.locale, this.version});

  static Client build(Map json) {
    return Client(
      uuid: json["uuid"],
      timezone: json["timezone"],
      locale: json["locale"],
      version: json["version"],
    );
  }
}
