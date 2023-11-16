import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Artisan.dart';
import '../models/NotificationMessage.dart';
import '../utils/Generals.dart';

class NotificationService {
  Future<bool> sendNotification(NotificationMessage notificationMessage) async {
    final String url = '${Generals.BASE_URL}/notifications/send_notification';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(notificationMessage.toJson()),
    );

    return response.statusCode == 201;
  }
}
