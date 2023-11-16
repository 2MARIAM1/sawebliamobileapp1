import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/pages/formulaire_page.dart';
import 'package:sawebliafrontend/pages/homepage.dart';
import 'package:sawebliafrontend/pages/missions_terminees.dart';
import 'package:sawebliafrontend/pages/uploadtocloud.dart';
import 'package:sawebliafrontend/services/missionservice.dart';

import '../utils/MyColors.dart';

class finiShedMissionDialog extends StatefulWidget {
  final int missionId;
  const finiShedMissionDialog({super.key, required this.missionId});

  @override
  State<finiShedMissionDialog> createState() => _finiShedMissionDialogState();
}

class _finiShedMissionDialogState extends State<finiShedMissionDialog> {
  final MissionService _missionService = MissionService();
  bool paiementCollecte = false;
  Mission? mission;

  @override
  void initState() {
    super.initState();

    fetchMission();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mywidget(),
    );
  }

  Widget mywidget() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MissionsTerminees(),
                ),
              );
            },
            child: Text(
              "خروج",
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationThickness: 2,
                color: MyColors.darkblue1,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/CheckVector.svg',
                  height: 120,
                  width: 120,
                ),
                SizedBox(
                  height: 50,
                ),
                const Text(
                  'انتهت الخدمة بنجاح',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 2.0,
                    height: 1,
                    fontSize: 45,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7FBCE7),
                  ),
                  softWrap: true,
                ),

                SizedBox(
                  height: 30,
                ),

                /// TOTAL A PAYER
                /// IF MISSION MONTANT IS NOT NULL
                ///
                ///
                if (paiementCollecte == false && mission?.prixAAPayer != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    color: Colors.red.withOpacity(0.15),
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
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: Container(
                //     decoration: BoxDecoration(
                //         border: Border.all(color: Colors.red),
                //         borderRadius: BorderRadius.circular(10)),
                //     child: Text(
                //       '\$  لا تنس أن تأخذ مقابل الخدمة (الخلاص) من الزبون',
                //       textDirection: TextDirection.rtl,
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //         height: 1,
                //         fontSize: 19,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.red,
                //       ),
                //       softWrap: true,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAddBreifButton(context),
                if (mission?.typeMission?.toLowerCase().contains('visite') ??
                    false)
                  buildModifierDevisButton(context)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAddBreifButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 5, backgroundColor: MyColors.darkblue1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تحميل صور و فيديوهات',
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
                    missionId: widget.missionId,
                  ),
              fullscreenDialog: true),
        );
      },
    );
  }

  Widget buildModifierDevisButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 5, backgroundColor: MyColors.darkblue1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DEVIS إرسال معلومات',
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            softWrap: true,
          ),
          SizedBox(width: 10),
          SizedBox(
            height: 25,
            width: 25,
            child: Image.asset('assets/images/modify.png'),
          ),
        ],
      ),
      onPressed: () {
        if (mission != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FormSubmitPage(
                      missionsRecordId: mission!.idRecord!,
                    ),
                fullscreenDialog: true),
          );
        }
      },
    );
  }
}
