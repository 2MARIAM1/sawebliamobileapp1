import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sawebliafrontend/components/custom_sidebar.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/custom_appbar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  Artisan? currentArtisan;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadLoggedArtisan();
    _loadProfileImageUrl();
  }

  Future<void> _loadProfileImageUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String savedImageUrl = prefs.getString('profileImageUrl') ?? "";

    if (mounted) {
      setState(() {
        imageUrl = savedImageUrl;
      });
    }
  }

  Future<void> _loadLoggedArtisan() async {
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

  Widget _listItem(String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 70,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30),
              child: Text(
                value,
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                softWrap: true,
              ),
            )),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 70,
            child: Center(
                child: Icon(
              icon,
              size: 28,
              color: MyColors.darkblue2.withOpacity(0.7),
            ))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSideBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: CustomAppbar(title: "معلوماتي الشخصية"),
              ),
              Stack(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black),
                    child: imageUrl != ""
                        ? ClipOval(
                            child: Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColors.darkblue2
                            .withOpacity(0.7), // Change the color as needed
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showEditOptions();
                        },
                        icon: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                currentArtisan?.nomComplet ?? "",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColors.darkblue2),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  color: Colors.grey,
                  height: 0.3,
                  thickness: 0.2,
                ),
              ),
              _listItem(currentArtisan?.email ?? "", Icons.person_sharp),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  color: Colors.grey,
                  height: 0.3,
                  thickness: 0.2,
                ),
              ),
              _listItem(
                  currentArtisan?.password ?? "", Icons.lock_open_rounded),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  color: Colors.grey,
                  height: 0.3,
                  thickness: 0.2,
                ),
              ),
              _listItem(currentArtisan?.tel ?? "", Icons.phone_enabled_rounded),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  color: Colors.grey,
                  height: 0.3,
                  thickness: 0.2,
                ),
              ),
              _listItem(currentArtisan?.cin ?? "", Icons.credit_card),
              const Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                    color: Colors.grey,
                    height: 0.3,
                    thickness: 0.2,
                  )),
              _listItem(currentArtisan?.metiers?.join(' ,') ?? "",
                  Icons.construction_rounded),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  color: Colors.grey,
                  height: 0.3,
                  thickness: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageUrl = pickedFile.path;
        print("imageUrl : $imageUrl");
      });

      // Save the image URL to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', imageUrl);
    }
  }

  Future<void> _deleteProfilePhoto() async {
    // Remove the image URL from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImageUrl');

    // Reset the imageUrl variable to an empty string
    setState(() {
      imageUrl = '';
    });
  }

  _showEditOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              trailing: Icon(
                Icons.photo_library_rounded,
                color: MyColors.darkblue2,
              ),
              title: Text(
                'اختر صورة جديدة',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              onTap: () {
                Navigator.pop(context); // Close the BottomSheet
                _updateProfilePhoto(); // Choose a new photo
              },
            ),
            ListTile(
              trailing: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: Text(
                'حذف الصورة',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              onTap: () {
                Navigator.pop(context); // Close the BottomSheet
                _deleteProfilePhoto(); // Delete the profile photo
              },
            ),
          ],
        );
      },
    );
  }
}
