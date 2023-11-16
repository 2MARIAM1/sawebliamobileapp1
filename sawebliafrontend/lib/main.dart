import 'dart:async';
import 'dart:typed_data';

import 'package:battery/battery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/NotificationMessage.dart';
import 'package:sawebliafrontend/pages/homepage.dart';
import 'package:sawebliafrontend/pages/loginpage.dart';
import 'package:sawebliafrontend/pages/missions_terminees.dart';
import 'package:sawebliafrontend/pages/suivre_mission.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/utils/Generals.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sawebliafrontend/utils/location_permission.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/newmission.dart';
import 'services/firebase_api.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  if (message != null && message.notification != null) {
    await FirebaseApi().showNotification(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ArtisanProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<NotificationMessage> notifications = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ArtisanService _artisanService = ArtisanService();
  final AuthService _authService = AuthService();
  final AirtableServices _airtableServices = AirtableServices();
  final LocationPermissionManager permissionManager =
      LocationPermissionManager();
  late Timer _timer2;

//LAST TIME THE USER OPENED THE APP
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _periodicAction();
    _getInitialMessage();

    _timer2 = Timer.periodic(Duration(seconds: 60), (timer) {
      _periodicAction();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      await _periodicAction();

      final artisanProvider =
          Provider.of<ArtisanProvider>(context, listen: false);
      artisanProvider.updateLastAppOpenTimestamp();

      // Get the current artisan and their ID
      final currentArtisan = artisanProvider.currentArtisan;
      if (currentArtisan != null) {
        final artisanId = currentArtisan.idArtisan;

        // Call the service function to update the last opened app timestamp
        final lastLogin = DateTime.now();
        Battery battery = Battery();
        int batteryLevel = await battery.batteryLevel;

        //ADD NEW LASTLOGIN TO DATABASE
        _artisanService.updateLastOpenedApp(artisanId!, lastLogin);
        // Update LAST LOGIN in Airtable
        _airtableServices.updateLastOpenedAppInAirtable(
            currentArtisan.idRecord!, lastLogin);
        _airtableServices.updateBatteryLevel(
            currentArtisan.idRecord!, batteryLevel / 100);
      }
    }
  }

  Future<Position> _getArtisanCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  _periodicAction() async {
    // GET THE SAVED ARTISAN IN SHARED PREFERENCES
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    final String savedEmail = _sharedPreferences.getString("emailkey") ?? "";
    final String savedPassword =
        _sharedPreferences.getString("passwordkey") ?? "";

    final Artisan? savedArtisan =
        await _authService.authenticate(savedEmail, savedPassword);

    final locationPermissionGranted =
        // ignore: use_build_context_synchronously
        await permissionManager.checkAndRequestPermission(context);
    if (savedArtisan != null) {
      Battery battery = Battery();
      int batteryLevel = await battery.batteryLevel;

      _airtableServices.updateBatteryLevel(
          savedArtisan.idRecord!, batteryLevel / 100);
      if (locationPermissionGranted) {
        Future.delayed(Duration.zero, () async {
          // GET AND UPDATE CURRENT LOCATION

          final position = await _getArtisanCurrentLocation();
          final latitude = position.latitude;
          final longitude = position.longitude;
          String adresse = await Generals.getAddressFromCoordinates(
                  latitude, longitude, "google cloud key here") ??
              "";
          //UPDATE LATITUDE LONGITUDE IN AIRTABLE
          _airtableServices.updateLocationArtisan(
              savedArtisan.idRecord!, longitude, latitude, adresse);
          // Update latitude and longitude in Database
          await _artisanService.updateLocation(
              savedArtisan.idArtisan!, longitude, latitude, adresse);

          _airtableServices.updateLastOpenedAppInAirtable(
              savedArtisan.idRecord!, DateTime.now());
        });
      }
    }
  }

  Future<void> _getInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseApi().showNotification(initialMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    int? missionId;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await FirebaseApi().showNotification(message);
        if (message.data['missionId'] != null) {
          missionId = int.parse(message.data['missionId']);

          await Future.delayed(const Duration(seconds: 1), () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => NewMissionDialog(missionId: missionId!),
                fullscreenDialog: true,
              ),
            );
          });
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await FirebaseApi().showNotification(message);
        if (message.data['missionId'] != null) {
          missionId = int.parse(message.data['missionId']);

          final SharedPreferences _sharedPreferences =
              await SharedPreferences.getInstance();
          final String savedEmail =
              _sharedPreferences.getString("emailkey") ?? "";
          final String savedPassword =
              _sharedPreferences.getString("passwordkey") ?? "";
          if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
            await Future.delayed(const Duration(seconds: 1), () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => NewMissionDialog(missionId: missionId!),
                  fullscreenDialog: true,
                ),
              );
            });
          }
        }
      }
    });

    return ChangeNotifierProvider(
      create: (context) => ArtisanProvider(),
      child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData(
            primaryColor: MyColors.darkblue1,
            primarySwatch: const MaterialColor(0xFF445FD2, {
              50: Color(0xFFE5EAF1), // Lightest shade
              100: Color(0xFFBCCAD9),
              200: Color(0xFF8AA9C0),
              300: Color(0xFF58989A),
              400: Color(0xFF287777),
              500: Color(0xFF445FD2), // Main color
              600: Color(0xFF101F38),
              700: Color(0xFF0D1B2C),
              800: Color(0xFF0A1620),
              900: Color(0xFF080F17), // Darkest shade
            }),
          ),
          home: LoginPage(),
          routes: {
            '/home': (context) => MyHomePage(),
            //  '/login': (context) => LoginPage(),
            '/suivremission': (context) => SuivreMission(),
            '/missionsterminees': (context) => MissionsTerminees(),
          }),
    );
  }

  @override
  void dispose() {
    _timer2.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
