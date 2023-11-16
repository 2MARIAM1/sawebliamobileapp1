import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sawebliafrontend/components/play_audio.dart';
import 'package:sawebliafrontend/components/play_video.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/pages/loginpage.dart';
import 'package:sawebliafrontend/pages/mission_encours1.dart';
import 'package:sawebliafrontend/pages/suivre_mission.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/utils/Generals.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Mission.dart';
import 'homepage.dart';
import '../services/missionservice.dart';
import '../components/image_gallery.dart';

class NewMissionDialog extends StatefulWidget {
  final int missionId;
  NewMissionDialog({required this.missionId});

  @override
  _NewMissionDialogState createState() => _NewMissionDialogState();
}

class _NewMissionDialogState extends State<NewMissionDialog> {
  final MissionService _missionService = MissionService();
  final AirtableServices _airtableServices = AirtableServices();
  Mission? mission;
  late String debutPrevuFormatted = '';
  Artisan? currentArtisan;
  final AuthService _authService = AuthService();
  bool _processing = false;

  // DateTime? debutPrevu = DateTime.now();
  // late String debutPrevuFormatted = Generals.formatDateTime(debutPrevu!);

  @override
  void initState() {
    super.initState();

    fetchMission();
    _loadStoredArtisan();
  }

  Future<void> _loadStoredArtisan() async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    final String savedEmail = _sharedPreferences.getString("emailkey") ?? "";
    final String savedPassword =
        _sharedPreferences.getString("passwordkey") ?? "";

    final Artisan? savedArtisan =
        await _authService.authenticate(savedEmail, savedPassword);
    if (mounted) {
      setState(() {
        currentArtisan = savedArtisan;
      });
    }
  }

  Future<void> saveRefusedMission(String myMissionId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the existing list or create an empty list if it doesn't exist
    List<String> existingList =
        prefs.getStringList("refusedMissionsList") ?? [];

    // Add the new item to the list
    existingList.add(myMissionId);

    // Save the updated list to SharedPreferences
    await prefs.setStringList("refusedMissionsList", existingList);
  }

  Future<void> fetchMission() async {
    mission = await _missionService.getMissionById(widget.missionId);

    if (mission != null) {
      debutPrevuFormatted = Generals.formatDateTime(mission!.debutPrevu!);

      print('MISSION FETCHED !!');
    } else {
      print('Problem in front !!!');
    }
    setState(() {});
  }

  Widget _listItem(String text, String value, double fSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: fSize,
                  fontFamily: "Poppins",
                  color: MyColors.darkblue1),
              softWrap: true,
            ),
          ),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MyColors.darkblue2),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final artisanIdProvider = Provider.of<ArtisanProvider>(context);
    // final loggedInArtisan = artisanIdProvider.currentArtisan!;
    // print("id missionnn :" "${mission?.idMission}");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تصفح الخدمة',
        ),
        backgroundColor: MyColors.darkblue1,
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '! وصلتك خدمة جديدة',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: MyColors.darkblue1,
                        ),
                        softWrap: true,
                      ),
                      Image.asset(
                        'assets/images/party-popper.png', // Replace with your image file path
                        width: 55, // Set the width
                        height: 55, // Set the height
                      ),
                    ],
                  )),
              const SizedBox(height: 40),

              _listItem(" الحرفة :",
                  Generals.replaceSpecialChars(mission?.metier ?? ""), 18),
              const SizedBox(height: 20),
              _listItem(" الحي :", mission?.quartier ?? "", 18),
              const SizedBox(height: 20),
              _listItem(
                  'تاريخ و \nوقت الخدمة :', debutPrevuFormatted.toString(), 18),
              // if (mission?.prixAAPayer != null) ...[
              //   const SizedBox(height: 20),
              //   _listItem(
              //       'تكلفة الخدمة :', "${mission?.prixAAPayer ?? 0} د.م", 18),
              // ],
              // if (mission?.prixMaxFournitures != null) ...[
              //   const SizedBox(
              //     height: 20,
              //   ),
              //   _listItem('الحد الأقصى لثمن السلعة :',
              //       "${mission?.prixMaxFournitures ?? 0} د.م", 18),
              // ],

              const SizedBox(
                height: 20,
              ),

              _listItem('معلومات إضافية :', mission?.description ?? "", 12),

              const SizedBox(
                height: 80,
              ) //ADDED THIS BECAUSE CONTENT IS HIDDED UNDER THE BOTTOM BOTTONS
            ],
          ),
        ),
        //BOUTONS ACCEPTER ET REFUSER
        (mission?.envoyerNotif?.toLowerCase() == "on")
            ? _bottomButtonForAffManuelle()
            : _bottomButtons(),
      ]),
    );
  }

  Widget _bottomButtonForAffManuelle() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Expanded(
                child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuivreMission(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: MyColors.darkblue1,
                // padding: EdgeInsets.only(right: ),
                minimumSize: const Size(100, 80),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('تتبّع الخدمة',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22)),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 24,
                  )
                ],
              ),
            ))));
  }

  Widget _bottomButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /////BOUTON ACCEPTERR
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 132, 225, 135),
                  // padding: EdgeInsets.only(right: ),
                  minimumSize: const Size(140, 80),
                ),
                onPressed: //mission?.statutMission == "ProgrammÃ©e"

                    () async {
                  try {
                    setState(() {
                      _processing = true; // Start processing
                    });
                    await _onAccepterProcess();

                    if (mounted) {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SuivreMission(),
                        ),
                      );
                    }
                  } catch (e) {
                    // If the mission was not updated
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          '! تنبيه',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.red),
                        ),
                        content: const Text(
                            '. كان هناك خطأ. الرجاء المحاولة في وقت لاحق'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } finally {
                    setState(() {
                      _processing = false; // Processing is done
                    });
                  }
                },
                child: _processing
                    ? CircularProgressIndicator(
                        color: MyColors.darkblue1,
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('قبول',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22)),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        ],
                      ),
              ),
            ),
            /////BOUTON REFUSERRRRRRRRRRRRRR
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final refusedMissionId = mission!.idRecord ?? "";
                  saveRefusedMission(refusedMissionId);

                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MyHomePage(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 236, 123, 123),
                  minimumSize: const Size(140, 80),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('رفض',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _successDialog() async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
          content: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                'تم تسجيل العملية بنجاح',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.thumb_up_rounded,
                color: MyColors.darkblue1,
                size: 40,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(_).pop();
              },
              child: const Text(
                'إغلاق',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            )
          ]),
    );
  }

  Future<void> _onAccepterProcess() async {
    // Update mission status to programmée in database
    await _missionService.updateMissionStatus(
        mission!.idMission!, "Programmée");
    // Update mission status to programmée in airtable

    await _airtableServices.updateMissionStatusAirtable(
        mission!.idRecord!, "Programmée");

    // Add the artisan who clicked to the mission's ArtisansTest field
    if (currentArtisan != null) {
      await _airtableServices.updateArtisansInMissionRecord(
          mission!.idRecord!, currentArtisan!.idRecord!);

      // Add the artisan who clicked to the mission's table in database

      await _missionService.assignMissionToArtisan(
          mission!.idMission!, currentArtisan!.idArtisan!);
      await Future.delayed(const Duration(seconds: 0), () {
        _successDialog();
      });
    }
  }
}
