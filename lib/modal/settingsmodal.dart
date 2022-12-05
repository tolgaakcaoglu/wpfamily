class Settings {
  final String appSku, ctaPeriod, marketUrl, privacyPolicy, termsOfUse;

  Settings(
      {this.appSku,
      this.ctaPeriod,
      this.marketUrl,
      this.privacyPolicy,
      this.termsOfUse});

  static Settings build(Map json) {
    return Settings(
      appSku: json["app_sku"],
      ctaPeriod: json["cta_period"],
      marketUrl: json["market_url"],
      privacyPolicy: json["privacy_policy"],
      termsOfUse: json["terms_of_use"],
    );
  }
}
