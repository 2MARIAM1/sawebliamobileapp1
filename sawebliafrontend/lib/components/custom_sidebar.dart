import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sawebliafrontend/pages/homepage.dart';
import 'package:sawebliafrontend/pages/loginpage.dart';
import 'package:sawebliafrontend/pages/missions_terminees.dart';
import 'package:sawebliafrontend/pages/profile_page.dart';
import 'package:sawebliafrontend/pages/suivre_mission.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'QR_contact.dart';

class CustomSideBar extends StatelessWidget {
  const CustomSideBar({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 60),
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.only(right: 20, top: 60),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 20),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Container(
                          color: Colors.white,
                          width: 250, // Adjust the width as needed
                          height: 300, // Adjust the height as needed
                          child: QRCodeWidget(),
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/images/SawebliaLOGO.svg',
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: MyColors.darkblue2,
                        ))
                  ],
                ),
              ),
            ),

            ListTile(
              trailing: SizedBox(
                  height: 28,
                  width: 28,
                  child: SvgPicture.asset('assets/images/Home.svg')),
              title: const Text(
                'الصفحة الرئيسية',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context); // Close the sidebar menu
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                ); // Navigate to the home page

                //   _showMessage(context, 'Home Page');
              },
            ),
            ListTile(
              trailing: Container(
                  height: 31,
                  width: 31,
                  child: SvgPicture.asset('assets/images/EnCours.svg')),
              title: const Text(
                'تتبع خدماتي',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context); // Close the sidebar menu
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SuivreMission()),
                );
                //  _showMessage(context, 'Suivre Missions Page');
              },
            ),
            ListTile(
              trailing: SizedBox(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset('assets/images/success.svg')),
              title: const Text(
                'الخدمات المنتهية',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context); // Close the sidebar menu
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MissionsTerminees()),
                );
                //   _showMessage(context, 'Missions términées');
              },
            ),
            ListTile(
              trailing: SizedBox(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset('assets/images/ProfileBlue.svg')),
              title: const Text(
                'معلوماتي الشخصية',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context); // Close the sidebar menu
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                //   _showMessage(context, 'Missions términées');
              },
            ),

            // ListTile(
            //   trailing: SizedBox(
            //       height: 30,
            //       width: 30,
            //       child: SvgPicture.asset('assets/images/logout.svg')),
            //   title: const Text(
            //     'تسجيل الخروج',
            //     textDirection: TextDirection.rtl,
            //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            //   ),
            //   onTap: () async {
            //     Navigator.pop(context); // Close the sidebar menu

            //     // Clear saved login credentials
            //     final SharedPreferences _sharedPreferences =
            //         await SharedPreferences.getInstance();
            //     _sharedPreferences.remove("emailkey");
            //     _sharedPreferences.remove("passwordkey");
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (_) => LoginPage(),
            //       ),
            //     ); // Navigate to the profile page

            //     //  _showMessage(context, 'You just logged out');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
