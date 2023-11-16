import 'dart:convert';

import 'package:sawebliafrontend/models/FeedbackArtisan.dart';
import 'package:sawebliafrontend/utils/Generals.dart';
import 'package:http/http.dart' as http;

class FeedbackService {
  Future<FeedbackArtisan> addFeedbackToDatabase(
      FeedbackArtisan feedback) async {
    final apiUrl = '${Generals.BASE_URL}/feedbacks/add';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(feedback.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return FeedbackArtisan.fromJson(responseData);
    } else {
      throw Exception('Failed to add feedback');
    }
  }
}
