import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sawebliafrontend/pages/newmission.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/services/missionservice.dart';
import 'package:sawebliafrontend/utils/Generals.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Actualites extends StatefulWidget {
  const Actualites({super.key});

  @override
  State<Actualites> createState() => _ActualitesState();
}

class _ActualitesState extends State<Actualites> {
  MissionService _missionService = MissionService();
  ArtisanService _artisanService = ArtisanService();
  final AuthService _authService = AuthService();
  Artisan? currentArtisan;

  @override
  void initState() {
    super.initState();

    setState(() {
      _loadStoredArtisan();

      fetchMissions();
    });
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

  void _showNewMissionDialog(int missionId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewMissionDialog(missionId: missionId),
        fullscreenDialog: true,
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<List<String>> loadRefusedMissions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> refusedMissions =
        prefs.getStringList("refusedMissionsList") ?? [];
    return refusedMissions;
  }

  Future<List<Mission>> fetchMissions() async {
    List<Mission> filteredMissions = [];

    if (currentArtisan != null) {
      try {
        final newMissions = await _artisanService
            .getNewAvailableMissionsForArtisan(currentArtisan!.idArtisan!);

        final refusedMissions = await loadRefusedMissions();

        filteredMissions = newMissions
            .where((mission) =>
                mission.debutPrevu!.isAfter(DateTime.now()) ||
                isSameDay(mission.debutPrevu!, DateTime.now()))
            .where((mission) =>
                !refusedMissions.contains(mission.idRecord.toString()))
            .toList();

        filteredMissions.sort((a, b) => b.debutPrevu!.compareTo(a.debutPrevu!));
      } catch (error) {
        print('Error fetching missions: $error');
      }
    }

    return filteredMissions;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      await fetchMissions();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      weight: 3,
                    )),
                // IconButton(
                //     onPressed: () {
                //       fetchMissions();
                //     },
                //     icon: Icon(
                //       Icons.refresh_rounded,
                //       color: MyColors.darkblue1,
                //       weight: 2,
                //     )),
                Text(
                  ": الخدمات المتوفرة",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Mission>>(
              future: currentArtisan != null ? fetchMissions() : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('جاري التحميل  ...'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text(' لا توجد خدمات متوفرة'));
                } else {
                  // final missions = snapshot.data!
                  //     .where((mission) =>
                  //         mission.debutPrevu!.isAfter(DateTime.now()) ||
                  //         isSameDay(mission.debutPrevu!, DateTime.now()))
                  //     .toList();
                  // missions.sort((a, b) =>
                  //     b.debutPrevu!.compareTo(a.debutPrevu!)); //FROM NEWEST TO OLDEST
                  final missions = snapshot.data!;
                  return ListView.builder(
                    itemCount: missions.length,
                    itemBuilder: (context, index) {
                      final mission = missions[index];
                      return GestureDetector(
                        onTap: () => _showNewMissionDialog(mission.idMission!),
                        child: Card(
                          child: ListTile(
                            title: Container(
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                      '${Generals.replaceSpecialChars(mission.typeMission ?? "")}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (mission.typeMission != null &&
                                      mission.typeMission!
                                          .toLowerCase()
                                          .contains('visite'))
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
                                Text(
                                  "${Generals.replaceSpecialChars(mission.metier ?? "")}  :الحرفة",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${mission.quartier ?? ""}  :الحي",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "${DateFormat('dd/MM/yyyy').format(mission.debutPrevu ?? DateTime(0))} :تاريخ الخدمة",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    "${DateFormat('HH:mm').format(mission.debutPrevu ?? DateTime(0))} :وقت الخدمة",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),

                                // Text(
                                //     "${DateFormat('HH:mm').format(mission.debutPrevu ?? DateTime(0))} :وقت الخدمة",
                                //     style: TextStyle(fontWeight: FontWeight.bold)),

                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: MyColors
                                            .darkblue1, // Background color
                                        onPrimary: Colors.white, // Text color
                                        elevation: 1, // Elevation (shadow)

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Button border radius
                                        ),
                                      ),
                                      onPressed: () {
                                        _showNewMissionDialog(
                                            mission.idMission!);
                                      },
                                      child: Text('تصفح الخدمة',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                ),
                              ],
                            ),
                            // You can customize the ListTile as needed
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
