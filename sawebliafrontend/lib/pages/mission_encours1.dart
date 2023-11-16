import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:sawebliafrontend/components/attachment_list.dart';
import 'package:sawebliafrontend/components/custom_sidebar.dart';
import 'package:sawebliafrontend/components/image_gallery.dart';
import 'package:sawebliafrontend/components/media_infos_mission.dart';
import 'package:sawebliafrontend/components/play_audio.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/pages/mission_encours2.dart';
import 'package:sawebliafrontend/pages/suivre_mission.dart';
import 'package:sawebliafrontend/pages/uploadtocloud.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/services/missionservice.dart';
import 'package:sawebliafrontend/services/smsservice.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';
import 'package:sawebliafrontend/utils/location_permission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/custom_appbar.dart';
import '../components/play_video.dart';
import 'show_map.dart';
import '../utils/Generals.dart';
import '../utils/MyColors.dart';

class MissionStep1 extends StatefulWidget {
  final int missionId;
  MissionStep1({required this.missionId});

  @override
  State<MissionStep1> createState() => _MissionStep1State();
}

class _MissionStep1State extends State<MissionStep1> {
  final MissionService _missionService = MissionService();
  final AirtableServices _airtableServices = AirtableServices();
  final ArtisanService _artisanService = ArtisanService();
  final SmsService _smsService = SmsService();

  final LocationPermissionManager _locationPermissionManager =
      LocationPermissionManager();
  Mission? mission;
  Position? _artisanPosition;

  LatLng? clientLocation = const LatLng(0, 0);
  bool isWithinDesiredDistance = false;
  late Timer _timer;
  DateTime? clickTime;
  bool paiementCollecte = false;
  int? idMissionStarted = 0;
  bool bonusGiven = false;
  Artisan? currentArtisan;
  final AuthService _authService = AuthService();
  bool briefisnull = false;

  @override
  void initState() {
    super.initState();
    _loadStoredValues();
    initilizeData();
    checkEmptyBrief();
    _checkDistanceToDestination();
    if (mounted) {
      setState(() {});
    }

    _timer = Timer.periodic(Duration(seconds: 120), (timer) {
      _loadStoredValues();
      initilizeData();
      checkEmptyBrief();
      _checkDistanceToDestination();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void initilizeData() async {
    fetchMission();
    final permissionGranted =
        await _locationPermissionManager.checkAndRequestPermission(context);

    if (permissionGranted) {
      _artisanPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latitude = _artisanPosition!.latitude;
      final longitude = _artisanPosition!.longitude;
      String adresse = await Generals.getAddressFromCoordinates(
              latitude, longitude, "AIzaSyA8CvI5xsHg1QBR9knEPv6PC1G8pNkDFgs") ??
          "";

      if (currentArtisan != null) {
        //UPDATE LATITUDE LONGITUDE IN AIRTABLE
        await _airtableServices.updateLocationArtisan(
            currentArtisan!.idRecord!, longitude, latitude, adresse);
        // Update latitude and longitude in Database
        await _artisanService.updateLocation(
            currentArtisan!.idArtisan!, longitude, latitude, adresse);
      }
    }
    _checkDistanceToDestination();
  }

  Future<void> _loadStoredValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String savedEmail = prefs.getString("emailkey") ?? "";
    final String savedPassword = prefs.getString("passwordkey") ?? "";

    final Artisan? savedArtisan =
        await _authService.authenticate(savedEmail, savedPassword);
    if (mounted) {
      setState(() {
        currentArtisan = savedArtisan;
      });
    }
    int? storedIdMissionStarted = prefs.getInt("idMissionStarted");

    if (storedIdMissionStarted != null) {
      if (mounted) {
        setState(() {
          idMissionStarted = storedIdMissionStarted;
        });
      }
    }
  }

  Future<void> fetchMission() async {
    mission = await _missionService.getMissionById(widget.missionId);

    if (mission!.latitude != null && mission!.longitude != null) {
      clientLocation = LatLng(mission!.latitude!, mission!.longitude!);
    }
    if (mission != null) {
      if (mission!.paiementCollecte == true) {
        if (mounted) {
          setState(() {
            paiementCollecte = true;
          });
        }
      }
      if (mission!.giveBonus == true) {
        if (mounted) {
          setState(() {
            bonusGiven = true;
          });
        }
      }
    } else {
      print('Problem in front !!!');
    }
  }

  void _checkDistanceToDestination() async {
    bool newIsWithinDesiredDistance = false;

    if (_artisanPosition != null && clientLocation != null) {
      double distanceToDestination = Geolocator.distanceBetween(
        _artisanPosition!.latitude,
        _artisanPosition!.longitude,
        clientLocation!.latitude,
        clientLocation!.longitude,
      );

      // final currentTime = DateTime.now();

      if (distanceToDestination <= 150) {
        // print(
        //     "clickTime : ${clickTime?.timeZoneName}, mission!.debutPrevu! : ${mission!.debutPrevu!.timeZoneName}");
        // print(
        //     "clickTime : ${clickTime?.toLocal()}, mission!.debutPrevu! : ${mission!.debutPrevu!.toUtc()}");
        // I TAKE DATEPREVU FROM AIRTABLE AS UTC , FORMAT IT TO STRING TO BE CONSIDERED AS CASA TIMEZONE
        String formattedDebutPrevu =
            mission!.debutPrevu!.toString().split('.')[0];

        String formattedClickTime = clickTime.toString().split('.')[0];

        if (formattedClickTime.compareTo(formattedDebutPrevu) < 0) {
          // Artisan clicked on start before or right on time, send the SMS

          if (bonusGiven == false && currentArtisan != null) {
            bool newBonusGivenValue = true;
            if (currentArtisan?.tel != null) {
              _smsService.sendSms(
                currentArtisan!.tel!,
                "Mbrok 3lik! Rbehty 20DH bonus",
              );
            }
            _artisanService.addBonus(
                currentArtisan!.idArtisan!, 20); //ADD 20 TO FULL SCORE
            _airtableServices.updateBonusAirtable(mission!.idRecord!, true);
            _missionService.updateGiveBonus(mission!.idMission!, true);

            setState(() {
              bonusGiven = newBonusGivenValue;
            });

            _showBravoBonus();
          }
        }

        newIsWithinDesiredDistance = true;
      } else {
        newIsWithinDesiredDistance = false;
      }
    }
    if (mounted) {
      setState(() {
        isWithinDesiredDistance = newIsWithinDesiredDistance;
      });
    }
  }

  Future<bool> checkEmptyBrief() async {
    if (mission != null) {
      final briefList = await _airtableServices
          .fetchBreifByIdRecord(mission!.idRecord!); //widget.recordId
      if (briefList.isEmpty) {
        setState(() {
          briefisnull = true;
        });
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.darkblue1,
        centerTitle: true,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuivreMission(),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded)),
        ),
        title: Text("تتبّع الخدمة"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 30,
              ),
              _clientWidget(),

              SizedBox(
                height: 10,
              ),
              listItem(
                  "عنوان الزبون",
                  Generals.replaceSpecialChars(mission?.adresse ?? ""),
                  MyColors.lightblue1.withOpacity(0.05)),
              SizedBox(
                height: 10,
              ),
              listItem(
                  " الحرفة",
                  Generals.replaceSpecialChars(mission?.metier ?? ""),
                  MyColors.lightblue1.withOpacity(0.05)),
              SizedBox(
                height: 10,
              ),
              listItem(
                  "تاريخ الخدمة",
                  DateFormat('dd/MM/yyyy')
                      .format(mission?.debutPrevu ?? DateTime(0)),
                  MyColors.lightblue1.withOpacity(0.05)),
              SizedBox(
                height: 10,
              ),
              listItem(
                  "وقت بداية الخدمة",
                  DateFormat('HH:mm')
                      .format(mission?.debutPrevu ?? DateTime(0)),
                  MyColors.lightblue1.withOpacity(0.05)),

              if (mission?.prixMaxFournitures != null) ...[
                const SizedBox(
                  height: 10,
                ),
                _fournitureWidget()
              ],
              SizedBox(
                height: 10,
              ),
              //LOCALISATION CLIENT
              locationContainer(),
              const SizedBox(
                height: 10,
              ),
              //BRIEF
              if (briefisnull == false) briefContainer()
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: isWithinDesiredDistance
                        ? Colors.green
                        : Colors.green.withOpacity(0.3)),
                onPressed: isWithinDesiredDistance
                    ? () async {
                        clickTime = DateTime.now();
                        if (idMissionStarted == mission!.idMission) {
                          _checkDistanceToDestination();
                          _missionService.updateMissionStatus(
                              mission!.idMission!, "En Cours");
                          _airtableServices.updateMissionStatusAirtable(
                              mission!.idRecord!, "En Cours");
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MissionStep2(
                                missionId: mission!.idMission!,
                              ),
                              // fullscreenDialog: true,
                            ),
                          );
                        } else {
                          _areYouSureDialog();
                          _checkDistanceToDestination();

                          _airtableServices.postDebutReel(
                              mission!.idRecord!, clickTime!);
                          _missionService.saveDebutIntervention(
                              mission!.idMission!, clickTime!);
                        }
                      }
                    : () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(bottom: 3),
                              height: 40,
                              width: 40,
                              child: SvgPicture.asset(
                                  "assets/images/clapperboard.svg")),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "ابدأ الخدمة",
                      textDirection: ui.TextDirection.rtl,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fournitureWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: Colors.red.withOpacity(0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              "${mission?.prixMaxFournitures ?? 0} د.م",
              style: TextStyle(
                fontSize: 15,
              ),
              softWrap: true,
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 35,
              height: 35,
              child: Image.asset("assets/images/toolbox.png"),
            ),
          ),
          Expanded(
            child: Text(
              'الحد الأقصى لثمن السلعة :',
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _clientWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: MyColors.lightblue1.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              Generals.replaceSpecialChars(mission?.nomClient ?? ""),
              style: TextStyle(
                fontSize: 15,
              ),
              softWrap: true,
            ),
          ),
          if (mission?.telClient != null)
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.darkblue1,
                      ),
                      onPressed: () async {
                        final url = 'tel:${mission?.telClient}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Center(
                        child: Icon(
                          Icons.phone,
                          size: 24,
                        ),
                      )),
                ],
              ),
            ),
          Expanded(
            child: Text(
              "الزبون",
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem(String text, String value, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
              ),
              softWrap: true,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  _areYouSureDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'هل أنت متأكد؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SizedBox(
            height: 70,
            width: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: MyColors.darkblue1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(bottom: 3),
                    height: 50,
                    width: 50,
                    child: SvgPicture.asset("assets/images/clapperboard.svg")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    decoration: TextDecoration.underline),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.setInt("idMissionStarted", mission!.idMission!);
                _missionService.updateMissionStatus(
                    mission!.idMission!, "En Cours");
                _airtableServices.updateMissionStatusAirtable(
                    mission!.idRecord!, "En Cours");
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MissionStep2(
                      missionId: widget.missionId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  primary: Colors.green, minimumSize: Size(150, 50)),
              child: const Text(
                'بدأ الخدمة',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget locationContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: MyColors.lightblue1.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: MyColors.darkblue1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'خريطة',
                    softWrap: true,
                  ),
                  Icon(
                    Icons.location_on,
                  ),
                ],
              ),
              onPressed: () {
                print(mission!.idMission!);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShowMap(
                      missionId: mission!.idMission!,
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Text(
              'موقع الزبون',
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget briefContainer() {
    return Container(
      color: MyColors.lightblue1.withOpacity(0.05),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20, top: 3),
              child: Text(
                'معلومات الخدمة',
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ),
          ),
          Column(
            children: [
              InfosMission(recordId: "${mission?.idRecord}"),
            ],
          )
        ],
      ),
    );
  }

  _showBravoBonus() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
                'BRAVO !',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    color: MyColors.darkblue1,
                    fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 100,
                      width: 80,
                      child: Image.asset("assets/images/successtrophy.png")),
                  Text('وصلت في الوقت المناسب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: MyColors.darkblue1,
                          fontWeight: FontWeight.bold)),
                  Text('+ 20DH',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'إغلاق',
                    textDirection: ui.TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                )
              ]);
        });
  }

  // _missionAlreadyInProgressDialog() {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text(
  //           'تنبيه',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.red,
  //             fontSize: 24,
  //           ),
  //         ),
  //         content: const Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(
  //               Icons.warning_amber_rounded,
  //               size: 70,
  //             ),
  //             Text(
  //               'هناك مهمة أخرى قيد التنفيذ ، يرجى انهاء المهمة الحالية أولاً',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.of(context).pushReplacement(
  //                 MaterialPageRoute(
  //                   builder: (_) => SuivreMission(),
  //                   fullscreenDialog: true,
  //                 ),
  //               );
  //             },
  //             child: const Text(
  //               'إغلاق',
  //               style: TextStyle(
  //                 color: Colors.red,
  //                 fontSize: 18,
  //                 decoration: TextDecoration.underline,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
