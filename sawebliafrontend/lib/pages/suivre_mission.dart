import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:sawebliafrontend/components/custom_appbar.dart';
import 'package:sawebliafrontend/components/custom_sidebar.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/pages/mission_encours1.dart';
import 'package:sawebliafrontend/pages/mission_encours2.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/utils/Generals.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SuivreMission extends StatefulWidget {
  const SuivreMission({super.key});

  @override
  State<SuivreMission> createState() => _SuivreMissionState();
}

class _SuivreMissionState extends State<SuivreMission> {
  final ArtisanService _artisanService = ArtisanService();
  int selectedSegmentIndex = 1; // 0 for "خدمات اليوم", 1 for "جميع الخدمات"
  Artisan? currentArtisan;
  final AuthService _authService = AuthService();
  int? idMissionStarted = 0;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
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

    int? storedIdMissionStarted = _sharedPreferences.getInt("idMissionStarted");

    if (storedIdMissionStarted != null) {
      if (mounted) {
        setState(() {
          idMissionStarted = storedIdMissionStarted;
        });
      }
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CustomSideBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: CustomAppbar(title: "تتبع خدماتي"),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      color: CupertinoColors.systemGrey5,
                      child: CupertinoSegmentedControl<int>(
                        selectedColor: MyColors.darkblue1,
                        borderColor: Colors.transparent,
                        unselectedColor: Colors.transparent,
                        padding: EdgeInsets.all(5.0),
                        children: {
                          0: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.today,
                                  color: selectedSegmentIndex == 0
                                      ? Colors.white
                                      : Colors.black,
                                ), // Today's icon
                                SizedBox(width: 8),
                                Text(
                                  'خدمات اليوم',
                                  style: TextStyle(
                                    color: selectedSegmentIndex == 0
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          1: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.list,
                                  color: selectedSegmentIndex == 1
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'جميع الخدمات',
                                  style: TextStyle(
                                    color: selectedSegmentIndex == 1
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        },
                        onValueChanged: (index) {
                          setState(() {
                            selectedSegmentIndex = index;
                          });
                        },
                        groupValue: selectedSegmentIndex,
                      ),
                    ),
                  ),
                ],
              ),

              //////////////////
              Expanded(
                child: FutureBuilder<List<Mission>>(
                  future: currentArtisan != null
                      ? _artisanService
                          .getArtisanMissions(currentArtisan!.idArtisan!)
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('جاري التحميل  ...'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: Text('خدمات غير متوفرة'));
                    } else {
                      final missions = snapshot.data!
                          .where((mission) =>
                              mission.statutMission == "ProgrammÃ©e" ||
                              mission.statutMission?.toLowerCase() ==
                                  "en cours")
                          .toList();
                      print('MISSIOOOONS : $missions');

                      missions.sort((a, b) => a.debutPrevu!
                          .compareTo(b.debutPrevu!)); //FROM oldest to newest

                      if (selectedSegmentIndex == 0) {
                        final todayMissions = missions
                            .where((mission) =>
                                isSameDay(mission.debutPrevu!, DateTime.now()))
                            .toList();

                        todayMissions.sort(
                            (a, b) => a.debutPrevu!.compareTo(b.debutPrevu!));
                        return _buildMissionList(todayMissions);
                      } else {
                        return _buildMissionList(missions);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildMissionList(List<Mission> missions) {
    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return GestureDetector(
          onTap: () {
            if (idMissionStarted == mission.idMission) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MissionStep2(
                    missionId: mission.idMission!,
                  ),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MissionStep1(
                    missionId: mission.idMission!,
                  ),
                ),
              );
            }
          },
          child: Card(
            child: ListTile(
              title: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${mission.typeMission ?? ""}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 10,
                    ),
                    if (mission.typeMission != null &&
                        mission.typeMission!.toLowerCase().contains('visite'))
                      Icon(
                        Icons.remove_red_eye_outlined,
                        color: MyColors.darkblue1,
                      ),
                    if (mission.typeMission != null &&
                        mission.typeMission!
                            .toLowerCase()
                            .contains('prestation'))
                      Icon(
                        Icons.construction,
                        color: MyColors.darkblue1,
                      )
                  ],
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "${mission.metier ?? ""}  :الحرفة",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${Generals.replaceSpecialChars(mission.nomClient ?? "")}  : اسم الزبون",
                    // textAlign: TextAlign.end,
                    // textDirection: ui.TextDirection.rtl,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  Text(
                      "${DateFormat('HH:mm - dd/MM/yyyy').format(mission.debutPrevu ?? DateTime(0))} : تاريخ و وقت الخدمة",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  // Text(
                  //     "${DateFormat('HH:mm').format(mission.debutPrevu ?? DateTime(0))} : وقت الخدمة",
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: MyColors.darkblue1,
                          onPrimary: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // final missionIdProvider =
                          //     Provider.of<MissionProvider>(
                          //         context,
                          //         listen: false);
                          // missionIdProvider
                          //     .setMissionId(mission.idMission!);
                          if (idMissionStarted == mission.idMission) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => MissionStep2(
                                  missionId: mission.idMission!,
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => MissionStep1(
                                  missionId: mission.idMission!,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'تتبّع الخدمة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ),
                  if (idMissionStarted == mission.idMission) ...[
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '... في طور التنفيذ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Divider(
                      color:
                          Colors.red, // Choose the color you want for the line
                      height: 2, // Adjust the height of the line
                      thickness: 2, // Adjust the thickness of the line
                    )
                  ]
                ],
              ),

              // You can customize the ListTile as needed
            ),
          ),
        );
      },
    );
  }
}
