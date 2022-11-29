import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wpfamilylastseen/modal/phonemodal.dart';
import 'package:wpfamilylastseen/modal/premiummodal.dart';
// import 'package:http/http.dart' as http;

class Funcs {
  static const api = 'https://api.wppanel.test/api/v1';

  // static register(Map deviceData) async {
  //   Uri url = Uri.parse('$api/register');
  //   var res = await http.post(url, headers: {});
  // }

  static Future getPhones() async {
    final file = await rootBundle.loadString('lib/json/phones.json');
    final json = jsonDecode(file);
    List<Phone> phones = [];
    if (json != null) {
      for (Map<String, dynamic> map in json) {
        phones.add(Phone.build(map));
      }
    }
    return phones;
  }

  static Future getPremiumPackages() async {
    final file = await rootBundle.loadString('lib/json/premiumpackage.json');
    final json = jsonDecode(file);
    List<PremiumPackage> packages = [];
    if (json != null) {
      for (Map<String, dynamic> map in json) {
        packages.add(PremiumPackage.build(map));
      }
    }
    return packages;
  }
}
