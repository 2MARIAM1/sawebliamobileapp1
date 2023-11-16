import 'dart:convert';

import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/Formulaire.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/services/missionservice.dart';

import '../utils/Generals.dart';
import 'package:http/http.dart' as http;

class AirtableServices {
  Future<List<dynamic>> fetchMissionsFromAirtable() async {
    final url = Uri.parse(
      'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Missions%20App%20Mobile',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['records'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchArtisansFromAirtable() async {
    final url = Uri.parse(
      'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Artisans%20App%20Mobile',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['records'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchBreifByIdRecord(String idRecord) async {
    final url = Uri.parse(
      'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Missions%20App%20Mobile/$idRecord',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      final briefData = responseData['fields']['Brief'];
      if (briefData is List<dynamic>) {
        return briefData;
      } else {
        // 'Breif' field is not a list or is null
        return [];
      }
    } else {
      print("${response.statusCode} : ${response.body}");
      return [];
    }
  }

  Future<void> updateArtisansInMissionRecord(
      String missionRecordId, String artisanRecordId) async {
    final apiUrl =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Missions%20App%20Mobile/$missionRecordId';
    final headers = {
      'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      'Content-Type': 'application/json',
    };

    // Fetch the existing mission record
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final missionData = jsonDecode(response.body);
      List<String> existingArtisanIds =
          missionData['fields']['Artisans'] != null
              ? List<String>.from(missionData['fields']['Artisans'])
              : [];

      // Add the new artisan's ID to the list
      existingArtisanIds.add(artisanRecordId);

      final updateData = {
        'fields': {'Artisans': existingArtisanIds}
      };

      // Update the mission record
      final updateResponse = await http.patch(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(updateData),
      );

      if (updateResponse.statusCode == 200) {
        print('Artisan added to mission record successfully');
      } else {
        print('Failed to add artisan to mission record');
      }
    } else {
      print('Failed to fetch mission record');
    }
  }

  Future<void> updateMissionStatusAirtable(
      String missionRecordId, String text) async {
    final apiUrl =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Missions%20App%20Mobile/$missionRecordId';
    final headers = {
      'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      'Content-Type': 'application/json',
    };

    final updateData = {
      'fields': {'Statut de l\'intervention': '${text}'}
    };

    // Update the mission record
    final updateResponse = await http.patch(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(updateData),
    );

    if (updateResponse.statusCode == 200) {
      print('Mission Status Updated successfully');
    } else {
      print('Failed to update mission status in airtable');
    }
  }

  Future<void> submitForm(FormSubmission formSubmission) async {
    final apiUrl =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Formulaire';
    final headers = {
      'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      'Content-Type': 'application/json',
    };

    final requestData = {
      'records': [
        {
          'fields': formSubmission.toJson(),
        },
      ],
    };

    final response = await http.post(Uri.parse(apiUrl),
        headers: headers, body: jsonEncode(requestData));

    if (response.statusCode == 200) {
      print('Form submitted successfully');
    } else {
      print('Error submitting form: ${response.statusCode}');
    }
  }

  Future<void> updateLastOpenedAppInAirtable(
      String idRecord, DateTime lastLogin) async {
    final url =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Artisans%20App%20Mobile/$idRecord';

    final Map<String, dynamic> data = {
      'fields': {
        'Dernière connexion': lastLogin.toIso8601String(),
      },
    };

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${Generals.AIRTABLE_API_KEY}', // Replace with your Airtable API key
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Last opened app updated in Airtable successfully');
    } else {
      print('Failed to update last opened app in Airtable');
    }
  }

  Future<void> updateLocationArtisan(String idRecord, double longitude,
      double latitude, String adresse) async {
    final url =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Artisans%20App%20Mobile/$idRecord';

    final Map<String, dynamic> data = {
      'fields': {
        'longitude': longitude,
        'latitude': latitude,
        'Adresse': adresse
      },
    };

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('updateLongLatArtisan successful');
    } else {
      print('updateLongLatArtisan failed');
    }
  }

  Future<void> updateBonusAirtable(String missionRecordId, bool value) async {
    final apiUrl =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Missions%20App%20Mobile/$missionRecordId';
    final headers = {
      'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      'Content-Type': 'application/json',
    };

    final updateData = {
      'fields': {'Bonus': value}
    };
    print('Bonus : $value');

    // Update the mission record
    final updateResponse = await http.patch(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(updateData),
    );
    print('Bonus : $value');

    if (updateResponse.statusCode == 200) {
      print('Bonus Updated successfully in airtable');
    } else {
      print('Failed to update bonus in airtable');
    }
  }

  Future<void> updateNombrePrestations(
      String artisanRecordId, int value) async {
    final apiUrl =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Artisans%20App%20Mobile/$artisanRecordId';
    final headers = {
      'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      'Content-Type': 'application/json',
    };

    final updateData = {
      'fields': {'Nombre Prestations': value}
    };

    // Update the mission record
    final updateResponse = await http.patch(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(updateData),
    );
    print('Nombre Prestations : $value');

    if (updateResponse.statusCode == 200) {
      print('Nombre Prestations Updated successfully in airtable');
    } else {
      print('Nombre Prestations to update bonus in airtable');
    }
  }

  Future<void> addRecordToAirtable(
      String type, String name, String url, String missionRecordId) async {
    final apiUrl =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Feedback%20Artisans'; // Airtable API endpoint

    final headers = {
      'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      'Content-Type': 'application/json',
    };

    List<String> listIds = [];
    listIds.add(missionRecordId);

    final body = jsonEncode({
      'fields': {
        'Type': type,
        'Nom': name,
        'Url': url,
        'Missions App Mobile': listIds
      }
    });

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Record added to Airtable successfully');
      } else {
        print('Failed to add record to Airtable');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error adding record to Airtable: $error');
    }
  }

  Future<void> postDebutReel(String idRecord, DateTime debutReel) async {
    final url =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Missions%20App%20Mobile/$idRecord';

    final Map<String, dynamic> data = {
      'fields': {
        'A commencé l\'intervention': debutReel.toIso8601String(), //.utc()
      },
    };

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${Generals.AIRTABLE_API_KEY}', // Replace with your Airtable API key
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Debut reel updated in Airtable successfully');
    } else {
      print('Failed to update debut reel in Airtable');
    }
  }

  Future<void> postFinIntervention(String idRecord, DateTime fin) async {
    final url =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Missions%20App%20Mobile/$idRecord';

    final Map<String, dynamic> data = {
      'fields': {
        'A terminé l\'intervention': fin.toIso8601String(),
      },
    };

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${Generals.AIRTABLE_API_KEY}', // Replace with your Airtable API key
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Fin intervention updated in Airtable successfully');
    } else {
      print('Failed to update Fin d intervention in Airtable');
    }
  }

  Future<void> updateBatteryLevel(String artisanRecordId, double value) async {
    final apiUrl =
        'https://api.airtable.com/v0/${Generals.AIRTABLE_BASE_ID}/Artisans%20App%20Mobile/$artisanRecordId';
    final headers = {
      'Authorization': 'Bearer ${Generals.AIRTABLE_API_KEY}',
      'Content-Type': 'application/json',
    };

    final updateData = {
      'fields': {'Battery Level': value}
    };

    // Update the mission record
    final updateResponse = await http.patch(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(updateData),
    );

    if (updateResponse.statusCode == 200) {
      print('Battery Level Updated successfully in airtable');
    } else {
      print('Battery Level to update bonus in airtable');
    }
  }
}
