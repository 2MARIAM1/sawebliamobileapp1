import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sawebliafrontend/utils/Generals.dart';

class SmsService {
  Future<void> sendSms(String phoneNumber, String message) async {
    try {
      final url = Uri.parse('${Generals.BASE_URL}/send-sms');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        // SMS sent successfully
        print('SMS sent successfully');
      } else {
        // Handle other status codes (if needed)
        print('Failed to send SMS. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error sending SMS: $e');
    }
  }
}
