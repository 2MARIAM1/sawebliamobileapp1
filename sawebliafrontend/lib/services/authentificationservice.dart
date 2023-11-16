import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/Artisan.dart';
import '../utils/Generals.dart';

// class AuthService {
//   Future<User?> authenticate(String email, String password) async {
//     try {
//       final response =
//           await http.get(Uri.parse('${Generals.BASE_URL}/users/all'));

//       if (response.statusCode == 200) {
//         final List<dynamic> users = jsonDecode(response.body);

//         final user = users.firstWhere(
//           (u) => u['email'] == email && u['password'] == password,
//           orElse: () => null,
//         );

//         if (user != null) {
//           return User.fromJson(user);
//         }
//       }
//     } on SocketException {
//       print("CHECK CONNECTION !!!");
//     } on FormatException {
//       print("ERROR RETREIVING DATA !!");
//     } catch (exp) {
//       print("SERVICE ERROR");
//     }

//     // authentication failed
//     return null;
//   }
// }

class AuthService {
  Future<Artisan?> authenticate(String email, String password) async {
    try {
      final response =
          await http.get(Uri.parse('${Generals.BASE_URL}/artisans/all'));

      //    print("Response Status Code: ${response.statusCode}");
      //  print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> artisans = jsonDecode(response.body);

        final artisan = artisans.firstWhere(
          (a) => a['login'] == email && a['password'] == password,
          orElse: () => null,
        );

//        print("Logged Body: ${artisan.toString()}");

        if (artisan != null) {
          // print('ARTISAN NOOOT NULL IN SERVICE : $artisan');
          return Artisan.fromJson(artisan);
        } else {
          print("No artisan found with the provided email and password.");
        }
      } else {
        print("Error: Request failed with status code ${response.statusCode}");
      }
    } on SocketException {
      print("CHECK CONNECTION !!!");
    } on FormatException {
      print("ERROR RETRIEVING DATA !!");
    } catch (exp) {
      print("SERVICE ERROR: $exp");
    }
    return null;
  }
}
