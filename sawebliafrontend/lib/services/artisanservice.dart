import 'dart:convert';
import 'dart:io';

import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:http/http.dart' as http;
import 'package:sawebliafrontend/models/Mission.dart';

import '../utils/Generals.dart';

class ArtisanService {
  Future<List<Artisan>> getAllArtisans() async {
    final response =
        await http.get(Uri.parse('${Generals.BASE_URL}/artisans/all'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((json) => Artisan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load artisans');
    }
  }

  Future<Artisan> getArtisanById(int artisanId) async {
    final String url = '${Generals.BASE_URL}/artisans/$artisanId';

    final response = await http.get(Uri.parse(url));
    // print("Response Status Code: ${response.statusCode}");
    //print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      //print("responseData : $jsonData");
      return Artisan.fromJson(jsonData);
    } else {
      // If the server returns an error response, throw an exception.
      throw HttpException('Failed to fetch mission: ${response.statusCode}');
    }
  }

  Future<List<Mission>> getNewAvailableMissionsForArtisan(int artisanId) async {
    final String url =
        '${Generals.BASE_URL}/artisans/$artisanId/newAvailableMissions';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((json) => Mission.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load new available missions for artisan');
    }
  }

  Future<void> updateFcmToken(int artisanId, String fcmToken) async {
    final String url =
        '${Generals.BASE_URL}/artisans/updatefcmtoken/$artisanId';

    final Map<String, dynamic> data = {
      'fcmToken': fcmToken,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('FCM Token updated successfully');
      } else {
        print('Failed to update FCM Token');
      }
    } catch (e) {
      print('Error updating FCM Token: $e');
    }
  }

  Future<void> updateArtisan(int artisanId, Artisan updatedArtisan) async {
    final String url = '${Generals.BASE_URL}/artisans/update/$artisanId';

    final Map<String, dynamic> data = updatedArtisan.toJson();

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Artisan updated successfully');
      } else {
        print('Failed to update artisan');
      }
    } catch (e) {
      print('Error updating artisan: $e');
    }
  }

  Future<int> getNumberOfMissionsForArtisan(int artisanId) async {
    final url =
        Uri.parse('${Generals.BASE_URL}/artisans/$artisanId/missions/count');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final int numberOfMissions = jsonDecode(response.body);
        return numberOfMissions;
      } else if (response.statusCode == 404) {
        throw Exception('Artisan not found');
      } else {
        throw Exception('Failed to fetch number of missions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Mission>> getArtisanMissions(int artisanId) async {
    final url = Uri.parse('${Generals.BASE_URL}/artisans/$artisanId/missions');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((json) => Mission.fromJson(json)).toList();
      } else {
        throw Exception('error fetching Missionsfor artisan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateLastOpenedApp(int artisanId, DateTime lastLogin) async {
    final String url =
        '${Generals.BASE_URL}/artisans/updateLastLogin/$artisanId';

    final Map<String, dynamic> data = {
      'lastLogin': lastLogin.toIso8601String(),
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Last opened app updated successfully ');
    } else {
      print('Failed to update opened app');
    }
  }

  Future<void> updateLocation(
      int artisanId, double longitude, double latitude, String adresse) async {
    final String url =
        '${Generals.BASE_URL}/artisans/updateLocation/$artisanId';

    final Map<String, dynamic> data = {
      'longitude': longitude,
      'latitude': latitude,
      'adresse': adresse
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Lat long updated successfully in database');
    } else {
      print('Failed to update Lat long in database');
    }
  }

  Future<void> addBonus(int artisanId, double bonusToAdd) async {
    final String url = '${Generals.BASE_URL}/artisans/addToBonus/$artisanId';

    final Map<String, dynamic> data = {
      'totalBonus': bonusToAdd,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Bonus successfully added');
    } else {
      print('Failed to add Bonus');
    }
  }
}
