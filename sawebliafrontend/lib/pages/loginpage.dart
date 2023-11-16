import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/pages/homepage.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/artisanservice.dart';
import '../services/authentificationservice.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final _firebaseMessaging = FirebaseMessaging.instance;

  final AuthService authService = AuthService();
  final ArtisanService _artisanService = ArtisanService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AirtableServices _airtableServices = AirtableServices();
  int artisanID = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getLoginCredentials().whenComplete(() async {});

    //  _tryAutoLogin(); // Try to auto-login when the screen initializes
  }

//FONCTIONS
  Future<void> _initializeFirebaseMessaging(int artisanID) async {
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      _artisanService.updateFcmToken(artisanID, fcmToken);
    }
  }

  Future getLoginCredentials() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    String? storedEmail = sharedPreferences.getString("emailkey");
    String? storedPass = sharedPreferences.getString("passwordkey");

    if (storedEmail != null && storedPass != null) {
      setState(() {
        emailController.text = storedEmail;
        passwordController.text = storedPass;
      });
    }
    setState(() {
      _tryAutoLogin();
    });
  }

  _handleOnPressedLogin() async {
    //CHECK LOGIN PASSWORD FROM DATABASE
    final email = emailController.text;
    final password = passwordController.text;

    final Artisan? artisan = await authService.authenticate(email, password);

    if (email.isNotEmpty && password.isNotEmpty) {
      if (artisan != null) {
        artisanID = artisan.idArtisan!;

        // STORE THE CREDENTIALS
        final SharedPreferences _sharedPreferences =
            await SharedPreferences.getInstance();
        _sharedPreferences.setString("emailkey", emailController.text);
        _sharedPreferences.setString("passwordkey", passwordController.text);

        await _initializeFirebaseMessaging(artisanID);
        // ignore: use_build_context_synchronously
        final artisanProvider =
            Provider.of<ArtisanProvider>(context, listen: false);

        artisanProvider.login(artisan);
        //UPDATE LAST LOGIN
        artisanProvider.updateLastAppOpenTimestamp();
        final ID = artisan.idArtisan;
        final lastLogin = DateTime.now();
        _artisanService.updateLastOpenedApp(ID!, lastLogin);
        _airtableServices.updateLastOpenedAppInAirtable(
            artisan.idRecord!, lastLogin);

        // Navigate to the home page after successful login
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // ignore: use_build_context_synchronously
        showErrorDialog(context, 'Email ou mot de passe erroné.');
      }
    } else {
      // ignore: use_build_context_synchronously
      showErrorDialog(context, 'Remplir les champs vides.');
    }
  }

  _tryAutoLogin() async {
    //CHECK LOGIN PASSWORD FROM DATABASE
    final email = emailController.text;
    final password = passwordController.text;

    final Artisan? artisan = await authService.authenticate(email, password);

    if (email.isNotEmpty && password.isNotEmpty) {
      if (artisan != null) {
        artisanID = artisan.idArtisan!;

        // STORE THE CREDENTIALS
        final SharedPreferences _sharedPreferences =
            await SharedPreferences.getInstance();
        _sharedPreferences.setString("emailkey", emailController.text);
        _sharedPreferences.setString("passwordkey", passwordController.text);

        await _initializeFirebaseMessaging(artisanID);
        // ignore: use_build_context_synchronously
        final artisanProvider =
            Provider.of<ArtisanProvider>(context, listen: false);

        artisanProvider.login(artisan);
        //UPDATE LAST LOGIN
        artisanProvider.updateLastAppOpenTimestamp();
        final ID = artisan.idArtisan;
        final lastLogin = DateTime.now();
        _artisanService.updateLastOpenedApp(ID!, lastLogin);
        _airtableServices.updateLastOpenedAppInAirtable(
            artisan.idRecord!, lastLogin);

        // Navigate to the home page after successful login
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // ignore: use_build_context_synchronously
        showErrorDialog(context, 'Email ou mot de passe erroné.');
      }
    }
  }

//WIDGETS
  Widget buildEmail() {
    return Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: MyColors.darkblue1,
            width: 0.5,
          ),
        ),
        height: 50,
        child: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
              color: MyColors.darkblue1,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins'),
          decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.email_outlined,
                  color: MyColors.darkgrey1,
                ),
              ),
              hintText: 'Email',
              hintStyle: TextStyle(
                  color: MyColors.darkgrey1,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ));
  }

  Widget buildPassword() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white, // Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Color(0xFF445FD2),
          width: 0.4,
        ),
      ),
      height: 50,
      child: TextField(
        controller: passwordController,
        obscureText: _obscureText,
        style: TextStyle(
            color: Color(0xFF445FD2),
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins'),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.lock_open_rounded,
              color: Color(0xFFADA4A5),
            ),
          ),
          suffixIcon: IconButton(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFFADA4A5),
              ),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          hintText: 'Password',
          hintStyle: TextStyle(
            color: Color(0xFFADA4A5),
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void showErrorDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attention!'),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Material(
      elevation: 5,
      shadowColor: Colors.blue.withOpacity(0.45),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        height: MediaQuery.of(context).size.height * 0.06,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [MyColors.darkblue1, MyColors.lightblue1])),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Connexion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.login,
                  color: Colors.white,
                ),
              ],
            ),
            onPressed: _handleOnPressedLogin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // isLoading
          //     ? CircularProgressIndicator()
          //     :
          AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: GestureDetector(
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: constraints.maxHeight * 0.4,
                                  child: SvgPicture.asset(
                                    'assets/images/BLUEBUBBLES.svg',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  top: constraints.maxHeight * 0.15,
                                  left: 0,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/images/octopus.png',
                                    width: 130,
                                    height: 130,
                                  ),
                                ),
                                Positioned(
                                  top: constraints.maxHeight * 0.06,
                                  left: 0,
                                  right: 0,
                                  child: SvgPicture.asset(
                                    'assets/images/saweblia.svg',
                                    width: 140,
                                    height: 40,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(
                              "Connectez-vous",
                              style: TextStyle(
                                  fontFamily: "POppins",
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  color: MyColors.darkblue1),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: buildEmail(),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: buildPassword(),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Mot de passe oublié?',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2,
                                  decorationColor: MyColors.darkgrey1,
                                  fontFamily: "Poppins",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.darkgrey1),
                            ),
                            SizedBox(height: 60),
                            buildLoginButton(context),
                          ]),
                    ),
                  );
                }),
              )),
    );
  }
}
