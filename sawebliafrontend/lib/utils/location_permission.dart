import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionManager {
  Future<bool> checkAndRequestPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    print(
        " await _geolocatorPlatform.isLocationServiceEnabled() : $serviceEnabled");
    if (!serviceEnabled) {
      _showLocationServiceDialog(
          context); // Show dialog to enable location services

      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}

void _showLocationServiceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Material(
        child: AlertDialog(
          title: Text('فعل خدمات تحديد الموقع'),
          content: Text(
            'لاستخدام هذا التطبيق، يرجى تمكين خدمات الموقع على جهازك',
          ),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('فتح الإعدادات'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        ),
      );
    },
  );
}
