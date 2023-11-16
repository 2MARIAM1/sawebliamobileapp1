import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Generals {
  static String BASE_URL = "http://server_here:8083";

  static String AIRTABLE_API_KEY = "AIRTABLE_API_KEY";
  static String AIRTABLE_BASE_URL = "https://api.airtable.com/v0/";
  static String AIRTABLE_BASE_ID = "appTZK9iqlbwvnAVA";

  // static String AIRTABLE_API_KEY = "key7iX2hgalTzz18S";
  // static String AIRTABLE_BASE_ID = "app222fjsfTAbu6pr";

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy \nHH:mm').format(dateTime);
  }

  static String replaceSpecialChars(String input) {
    return input
        .replaceAll('Ã©', '\u00E9')
        .replaceAll('Ã‰', '\u00E9')
        .replaceAll('ã¨', '\u00E8')
        .replaceAll('Ãˆ', '\u00E8');
  }

  static Future<String?> getAddressFromCoordinates(
      double latitude, double longitude, String apiKey) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] is List &&
            data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (error) {
      print('Error fetching geocode data: $error');
    }

    return null; // Return null if there's an error or no address found
  }
}
