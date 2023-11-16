import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/Mission.dart';
import '../utils/Generals.dart';

class MissionService {
  Future<Mission> getMissionById(int missionId) async {
    final String url = '${Generals.BASE_URL}/missions/$missionId';
    try {
      final response = await http.get(Uri.parse(url));
      // print("Response Status Code: ${response.statusCode}");
      //print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        //print("responseData : $jsonData");

        return Mission.fromJson(jsonData);
      }
    } catch (e) {
      print('Error updating statutMission: $e');
    }
    return Mission();
  }

  Future<void> updateMissionStatus(int missionId, String statutMission) async {
    final String url = '${Generals.BASE_URL}/missions/updatestatut/$missionId';

    final Map<String, dynamic> data = {
      'statutMission': statutMission,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Mission status updated successfully');
      } else {
        print('SERVICE : Failed to update Mission Status');
      }
    } catch (e) {
      print('Error updating statutMission: $e');
    }
  }

  Future<void> updateGiveBonus(int missionId, bool value) async {
    final String url =
        '${Generals.BASE_URL}/missions/updategiveBonus/$missionId';

    final Map<String, dynamic> data = {
      'giveBonus': value,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Give Bonus updated successfully');
      } else {
        print('SERVICE : Failed to update Give Bonus');
      }
    } catch (e) {
      print('Error updating Give Bonus: $e');
    }
  }

  Future<bool> assignMissionToArtisan(int missionId, int artisanId) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${Generals.BASE_URL}/missions/$missionId/assign-artisan/$artisanId'),
      );

      if (response.statusCode == 200) {
        return true; // Success, mission assigned to artisan
      } else if (response.statusCode == 409) {
        return false; // Conflict, artisan is already assigned to the mission
      } else {
        // Handle other status codes, e.g., 404 for mission or artisan not found
        return false;
      }
    } catch (e) {
      // Handle any exceptions or errors that occurred during the request
      return false;
    }
  }

  Future<void> saveDebutIntervention(int missionId, DateTime dateTime) async {
    final String url =
        '${Generals.BASE_URL}/missions/saveDebutIntervention/$missionId';

    final Map<String, dynamic> data = {
      'debutReel': dateTime.toUtc().toIso8601String(),
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Date de debut réel updated successfully');
      } else {
        print('SERVICE : Failed to update Date de debut réel');
      }
    } catch (e) {
      print('Error updating ate de debut réel: $e');
    }
  }
}
