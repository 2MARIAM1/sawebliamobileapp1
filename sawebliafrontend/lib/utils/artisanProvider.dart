import 'package:flutter/foundation.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtisanProvider extends ChangeNotifier {
  Artisan? _currentArtisan;
  Artisan? get currentArtisan => _currentArtisan;

  void login(Artisan artisan) {
    _currentArtisan = artisan;
    notifyListeners();
  }

  void logout() {
    _currentArtisan = null;
    notifyListeners();
  }

  Future<void> updateLastAppOpenTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAppOpenTimestampKey = 'lastAppOpenTimestamp';
    final currentTime = DateTime.now();

    await prefs.setString(
        lastAppOpenTimestampKey, currentTime.toIso8601String());
    notifyListeners();
  }
}
