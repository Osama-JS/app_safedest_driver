import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class MapboxService {
  static Future<double?> getDrivingDistance(
      double startLat, double startLng, double endLat, double endLng) async {
    try {
      final url = Uri.parse(
          'https://api.mapbox.com/directions/v5/mapbox/driving/$startLng,$startLat;$endLng,$endLat?access_token=${AppConfig.mapboxAccessToken}&overview=false&geometries=geojson');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          // Distance is returned in meters, convert to kilometers
          final distanceInMeters = data['routes'][0]['distance'];
          return distanceInMeters / 1000.0;
        }
      }
      return null;
    } catch (e) {
      print('Mapbox API Error: $e');
      return null;
    }
  }
}
