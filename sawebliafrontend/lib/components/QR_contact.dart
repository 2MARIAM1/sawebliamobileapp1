import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeWidget extends StatelessWidget {
  const QRCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImageView(
        data: generateContactVCard(),
        version: QrVersions.auto,
        size: 180.0,
      ),
    );
  }

  // Generate a vCard (contact) in plain text format
  String generateContactVCard() {
    const String name = "SAWEBLIA";
    const String phoneNumber = "0677-330404";
    const String email = "Sales@saweblia.ma";
    const String address =
        "5e étage, 10, rue Moussa Ibnou Noussair, Casablanca 20060";
    const String website = "www.saweblia.ma";
    const String facebook = "https://www.facebook.com/saweblia";
    const String linkedin = "https://www.linkedin.com/company/saweblia";
    const String instagram = "https://www.instagram.com/saweblia";

    return "BEGIN:VCARD\n"
        "VERSION:3.0\n"
        "FN:$name\n"
        "TEL:$phoneNumber\n"
        "EMAIL:$email\n"
        "ADR:$address\n"
        "URL:$website\n"
        "X-SOCIALPROFILE;type=facebook:$facebook\n"
        "X-SOCIALPROFILE;type=linkedin:$linkedin\n"
        "X-SOCIALPROFILE;type=instagram:$instagram\n"
        "END:VCARD";
  }
}
