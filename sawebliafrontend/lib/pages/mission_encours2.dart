import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sawebliafrontend/components/attachment_list.dart';
import 'package:sawebliafrontend/pages/congrats.dart';
import 'package:sawebliafrontend/components/custom_sidebar.dart';
import 'package:sawebliafrontend/components/image_gallery.dart';
import 'package:sawebliafrontend/components/media_infos_mission.dart';
import 'package:sawebliafrontend/components/play_audio.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/pages/formulaire_page.dart';
import 'package:sawebliafrontend/pages/mission_encours1.dart';
import 'package:sawebliafrontend/pages/uploadtocloud.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/missionservice.dart';
import 'package:sawebliafrontend/services/smsservice.dart';
import 'package:sawebliafrontend/utils/location_permission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/custom_appbar.dart';
import '../components/play_video.dart';
import 'show_map.dart';
import '../utils/Generals.dart';
import '../utils/MyColors.dart';

class MissionStep2 extends StatefulWidget {
  final int missionId;
  MissionStep2({required this.missionId});

  @override
  State<MissionStep2> createState() => _MissionStep2State();
}

class _MissionStep2State extends State<MissionStep2> {
  final MissionService _missionService = MissionService();
  final AirtableServices _airtableServices = AirtableServices();
  final ArtisanService _artisanService = ArtisanService();
  Mission? mission;
  Position? _artisanPosition;
  bool paiementCollecte = false;
  bool briefisnull = false;

  @override
  void initState() {
    super.initState();

    fetchMission();
    checkEmptyBrief();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchMission() async {
    Mission mymission = await _missionService.getMissionById(widget.missionId);
    if (mounted) {
      setState(() {
        mission = mymission;
      });
    }

    if (mission != null) {
      if (mission!.paiementCollecte == true) {
        if (mounted) {
          setState(() {
            paiementCollecte = true;
          });
        }
      }
    } else {
      print('Problem in front !!!');
    }
  }

  Widget listItem(String text, String value, Color containercolor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: containercolor,
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
              textDirection: TextDirection.rtl,
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
        title: Text("خدمة في طور الإنجاز"),
        backgroundColor: MyColors.darkblue1,
        centerTitle: true,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MissionStep1(
                      missionId: widget.missionId,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  _clientWidget(mission),

                  SizedBox(
                    height: 10,
                  ),

                  ////////
                  if (mission?.prixAAPayer != null) ...[
                    if (!paiementCollecte) _totalAPayerWidget(mission),
                    if (!paiementCollecte)
                      SizedBox(
                        height: 10,
                      ),
                    if (!paiementCollecte) modePaiementWidget(),
                    if (!paiementCollecte)
                      SizedBox(
                        height: 10,
                      ),
                  ],

//////
                  listItem('معلومات إضافية ', mission?.description ?? "",
                      MyColors.lightblue1.withOpacity(0.05)),
                  SizedBox(
                    height: 10,
                  ),

                  ////BRIEF
                  if (briefisnull == false)
                    Container(
                      color: MyColors.lightblue1.withOpacity(0.05),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 20, top: 3),
                              child: Text(
                                'معلومات الخدمة',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                          InfosMission(recordId: "${mission?.idRecord}"),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  // if (mission?.typeMission?.toLowerCase().contains('visite') ??
                  //     false)
                  //   modifierDevis(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width * 0.3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.lightblue1.withOpacity(0.5),
                  elevation: 0,
                ),
                onPressed: () async {
                  const url = 'tel:0702098500';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: SizedBox(
                  height: 65,
                  width: 65,
                  child: SvgPicture.asset('assets/images/callcenter.svg'),
                ),
              ),
            ),
            SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width * 0.7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  _areYouSureDialog();

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => finiShedMissionDialog(
                  //       missionId: widget.missionId,
                  //     ),
                  //   ),
                  // );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 40,
                        width: 40,
                        child:
                            SvgPicture.asset('assets/images/finish_line.svg')),
                    SizedBox(width: 20),
                    Text(
                      "إنهاء الخدمة",
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

  Widget _clientWidget(Mission? mission) {
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

  Widget _totalAPayerWidget(Mission? mission) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: MyColors.lightblue1.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              "${mission?.prixAAPayer ?? 0} د.م",
              style: TextStyle(
                fontSize: 15,
              ),
              softWrap: true,
            ),
          ),
          Expanded(
              child: Icon(
            Icons.monetization_on_outlined,
            size: 30,
            color: MyColors.darkblue2,
          )),
          Expanded(
            child: Text(
              'تكلفة الخدمة ',
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

  Widget modePaiementWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: MyColors.lightblue1
          .withOpacity(0.05), // MyColors.lightblue1.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/cash_money.png',
                    height: 40,
                    width: 40,
                  ),
                  if (mission?.moyenPaiement?.toLowerCase() != 'espã¨ce')
                    Stack(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          color: MyColors.backgroundgray.withOpacity(0.5),
                        ),
                        CustomPaint(
                          size: Size(40, 40),
                          painter: CrossedOutPainter(),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Stack(children: [
                Image.asset(
                  'assets/images/credit_cards.png',
                  height: 40,
                  width: 40,
                ),
                if (mission?.moyenPaiement?.toLowerCase() != 'carte bancaire')
                  Stack(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        color: MyColors.backgroundgray.withOpacity(0.5),
                      ),
                      CustomPaint(
                        size: Size(40, 40),
                        painter: CrossedOutPainter(),
                      ),
                    ],
                  ),
              ]),
            ],
          ),
          Expanded(
            child: Text(
              'طريقة الدفع',
              textDirection: TextDirection.rtl,
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

  Widget modifierDevis() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: Colors.red.withOpacity(0.05),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: MyColors.darkblue1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: Image.asset('assets/images/modify.png'),
                ),
                Text(
                  'تغيير',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  softWrap: true,
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FormSubmitPage(
                    missionsRecordId: "${mission?.idRecord!}",
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ),
        Flexible(
          child: Text(
            'تريد تغيير تكاليف الخدمة؟',
            textDirection: ui.TextDirection.rtl,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
          ),
        ),
      ]),
    );
  }

  _areYouSureDialog() {
    //   final DateTime? missionStartTime = mission?.debutReel;
    // final DateTime currentTime = DateTime.now();
    // final Duration elapsedTime = currentTime.difference(missionStartTime ?? currentTime);
    // final bool isButtonEnabled = elapsedTime.inMinutes >= 5;

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 70,
                  width: 70,
                  child: Image.asset('assets/images/finish_flag.png')),
              SizedBox(
                height: 20,
              ),
              if (!paiementCollecte && mission?.prixAAPayer != null) ...[
                Text(
                  ':(الخلاص) تكلفة الخدمة',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),

                SizedBox(height: 10),
                ////////// PRIX A PAYER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: MyColors.lightblue1.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${mission?.prixAAPayer ?? 0} د.م",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        softWrap: true,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 30,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                //////////

                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: MyColors.lightblue1.withOpacity(
                      0.05), // MyColors.lightblue1.withOpacity(0.2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            'assets/images/cash_money.png',
                            height: 40,
                            width: 40,
                          ),
                          if (mission?.moyenPaiement?.toLowerCase() !=
                              'espã¨ce')
                            Stack(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  color:
                                      MyColors.backgroundgray.withOpacity(0.5),
                                ),
                                CustomPaint(
                                  size: Size(40, 40),
                                  painter: CrossedOutPainter(),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Stack(children: [
                        Image.asset(
                          'assets/images/credit_cards.png',
                          height: 40,
                          width: 40,
                        ),
                        if (mission?.moyenPaiement?.toLowerCase() !=
                            'carte bancaire')
                          Stack(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                color: MyColors.backgroundgray.withOpacity(0.5),
                              ),
                              CustomPaint(
                                size: Size(40, 40),
                                painter: CrossedOutPainter(),
                              ),
                            ],
                          ),
                      ]),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'إلغاء',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    decoration: TextDecoration.underline),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                DateTime currentTime = DateTime.now();
                _missionService.updateMissionStatus(
                    mission!.idMission!, "Terminé");
                _airtableServices.updateMissionStatusAirtable(
                    mission!.idRecord!, "Terminé");
                _airtableServices.postFinIntervention(
                    mission!.idRecord!, currentTime);
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => finiShedMissionDialog(
                      missionId: widget.missionId,
                    ),
                  ),
                );

                //CLEAR MISSION STARTED (en cours)
                final SharedPreferences _sharedPreferences =
                    await SharedPreferences.getInstance();
                _sharedPreferences.remove("idMissionStarted");
              },
              style: ElevatedButton.styleFrom(
                  primary: Colors.red, minimumSize: Size(150, 50)),
              child: const Text(
                'إنهاء الخدمة',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CrossedOutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red // Set the color of the cross-out line
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
