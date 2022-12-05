import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wpfamilylastseen/modal/phonemodal.dart';
import 'package:wpfamilylastseen/modal/premiummodal.dart';
import 'package:http/http.dart' as http;

class Funcs {
  static const api = 'http://165.232.112.41/api/v1';

  static Future register(
      String device, String timezone, String locale, String version) async {
    Uri url = Uri.parse('$api/register');
    var res = await http.post(url, headers: {
      'X-Device': device,
      'Accept': 'application/json'
    }, body: {
      'uuid': device,
      'timezone': timezone,
      'locale': locale,
      'version': version
    });
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

  static Future settings(String device) async {
    Uri url = Uri.parse('$api/settings');
    var res = await http.get(
      url,
      headers: {'X-Device': device, 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

  static Future products(String device) async {
    Uri url = Uri.parse('$api/products');
    var res = await http.get(
      url,
      headers: {'X-Device': '', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

  static Future numbers(String device) async {
    Uri url = Uri.parse('$api/numbers');
    var res = await http.get(
      url,
      headers: {'X-Device': device, 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

  static Future number(String numId, String device) async {
    Uri url = Uri.parse('$api/number/$numId');
    var res = await http.get(
      url,
      headers: {'X-Device': device, 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

  static Future addNumber(String name, String number, String countryCode,
      String token, String detail, String device) async {
    Uri url = Uri.parse('$api/add-number');
    var res = await http.post(url, headers: {
      'X-Device': device,
      'Accept': 'application/json'
    }, body: {
      'name': name,
      'number': number,
      'country_code': countryCode,
      'product_sku': 'com.aildev.wpfamilylastseen',
      'purchase_token': token,
      'purchase_detail': detail,
    });
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

  static Future editNumber(String name, int notif, String device) async {
    Uri url = Uri.parse('$api/edit-number');
    var res = await http.post(url,
        headers: {'X-Device': device, 'Accept': 'application/json'},
        body: {'name': name, 'notification': notif});
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

  static Future removeNumber(String numId, String device) async {
    Uri url = Uri.parse('$api/remove-number/$numId');
    var res = await http.delete(
      url,
      headers: {'X-Device': device, 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return 'error';
    }
  }

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
