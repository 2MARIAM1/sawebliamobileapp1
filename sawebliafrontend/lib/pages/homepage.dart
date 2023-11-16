import 'dart:async';
import 'dart:developer';

import 'package:battery/battery.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sawebliafrontend/components/actualites.dart';
import 'package:sawebliafrontend/components/custom_appbar.dart';

import 'package:sawebliafrontend/components/infos_home.dart';
import 'package:sawebliafrontend/components/custom_sidebar.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';
import 'package:sawebliafrontend/utils/location_permission.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'newmission.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _firebaseMessaging = FirebaseMessaging.instance;

  ArtisanService artisanService = ArtisanService();
  final ArtisanService _artisanService = ArtisanService();
  final AirtableServices _airtableServices = AirtableServices();
  final AuthService _authService = AuthService();
  Artisan? currentArtisan;

  int nombreDeMissions = 0;
  double totalBonus = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      initializeData();
    });
  }

  Future<void> _initializeFirebaseMessaging(int artisanID) async {
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      _artisanService.updateFcmToken(artisanID, fcmToken);
    }
  }

  void initializeData() async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    final String savedEmail = _sharedPreferences.getString("emailkey") ?? "";
    final String savedPassword =
        _sharedPreferences.getString("passwordkey") ?? "";

    final Artisan? savedArtisan =
        await _authService.authenticate(savedEmail, savedPassword);

    if (savedArtisan != null) {
      _initializeFirebaseMessaging(savedArtisan.idArtisan!);
    }

    if (mounted) {
      setState(() {
        currentArtisan = savedArtisan;
      });
    }
    if (currentArtisan != null) {
      int numberOfMissions = await artisanService
          .getNumberOfMissionsForArtisan(currentArtisan!.idArtisan!);
      _airtableServices.updateNombrePrestations(
          currentArtisan!.idRecord!, numberOfMissions);

      setState(() {
        nombreDeMissions = numberOfMissions;

        totalBonus = currentArtisan?.totalBonus ?? 0;
      });
      Battery battery = Battery();
      int batteryLevel = await battery.batteryLevel;

      _airtableServices.updateBatteryLevel(
          currentArtisan?.idRecord ?? "", batteryLevel / 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSideBar(),
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: CustomAppbar(title: "الصفحة الرئيسية"),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfosHome(
                    number: nombreDeMissions,
                    text: "الخدمات",
                    iconLink: 'assets/images/Tools.svg',
                  ),
                  InfosHome(
                    number: totalBonus.toInt(),
                    currency: 'د.م',
                    text: "Bonus",
                    iconLink: "assets/images/Trophy.svg",
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Actualites(),
          ],
        ),
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: CustomMenu(),
        // ),
      ),
    );
  }

  @override
  void dispose() {
    // _positionStream?.listen(null);
    super.dispose();
  }
}
