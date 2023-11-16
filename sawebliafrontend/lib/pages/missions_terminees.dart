import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:sawebliafrontend/components/custom_appbar.dart';
import 'package:sawebliafrontend/components/custom_sidebar.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/pages/formulaire_page.dart';
import 'package:sawebliafrontend/pages/uploadtocloud.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/utils/Generals.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissionsTerminees extends StatefulWidget {
  const MissionsTerminees({super.key});

  @override
  State<MissionsTerminees> createState() => _MissionsTermineesState();
}

class _MissionsTermineesState extends State<MissionsTerminees> {
  final ArtisanService _artisanService = ArtisanService();
  final AuthService _authService = AuthService();
  DateTime? selectedDate;
  Artisan? currentArtisan;

  @override
  void initState() {
    initializeProvider(context);
    super.initState();
  }

  void initializeProvider(BuildContext context) async {
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      helpText: "",
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2040),
    );
    //  locale: const Locale('ar', 'SA')
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
    });
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
            child: CustomAppbar(title: "الخدمات المنتهية"),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(left: 10, right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedDate != null ? Colors.green : MyColors.darkblue1,
              ),
              onPressed: () => selectedDate != null
                  ? _clearDateFilter()
                  : _selectDate(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset('assets/images/filterwhite.svg')),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : "البحث حسب التاريخ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
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
                  return Center(child: Text('لا توجد خدمات'));
                } else {
                  final missions = snapshot.data!
                      .where((mission) => mission.statutMission == "TerminÃ©")
                      .toList();
                  missions
                      .sort((a, b) => b.debutPrevu!.compareTo(a.debutPrevu!));
                  final filteredMissions = missions.where((mission) {
                    if (selectedDate != null) {
                      return mission.debutPrevu != null &&
                          mission.debutPrevu!.isAfter(selectedDate!);
                    } else {
                      return true;
                    }
                  }).toList();
                  print(missions);
                  return ListView.builder(
                    itemCount: filteredMissions.length,
                    itemBuilder: (context, index) {
                      final mission = filteredMissions[index];
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${mission.typeMission ?? ""}',
                                      textAlign: TextAlign.end,
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${Generals.replaceSpecialChars(mission.metier ?? "")} : الحرفة",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    softWrap: true,
                                  ),
                                  Text(
                                    "${mission.nomClient ?? ""}  : اسم الزبون",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    softWrap: true,
                                  ),
                                  Text(
                                      "${DateFormat('HH:mm - dd/MM/yyyy').format(mission.debutPrevu ?? DateTime(0))} : تاريخ و وقت الخدمة",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if (mission.typeMission
                                            ?.toLowerCase()
                                            .contains('visite') ??
                                        false)
                                      modifierDevis(mission),
                                    uploadMedia(mission),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      )),
    );
  }

  Widget modifierDevis(Mission mission) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: MyColors.darkblue1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'DEVIS',
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
              height: 20,
              width: 20,
              child: Image.asset('assets/images/modify.png'),
            ),
          ],
        ),
        onPressed: () {
          print("${mission.idRecord!}");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FormSubmitPage(
                missionsRecordId: "${mission.idRecord!}",
              ),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    );
  }

  Widget uploadMedia(Mission mission) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: MyColors.darkblue1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'تحميل صور و فيديوهات',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
            SizedBox(width: 10),
            Icon(
              Icons.video_library_outlined,
              color: Colors.white,
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadMediaToCloud(
                      missionId: mission.idMission!,
                    ),
                fullscreenDialog: true),
          );
        },
      ),
    );
  }
}
