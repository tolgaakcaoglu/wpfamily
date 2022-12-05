import 'package:geocoding/geocoding.dart';

class Utils {
  static Future<String> getTimezone(locationData) async {
    var placemark = await placemarkFromCoordinates(
        locationData.latitude, locationData.longitude);

    return '${placemark.first.country}/${placemark.first.administrativeArea}';
  }
}
