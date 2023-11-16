import 'package:flutter/material.dart';

class MyColors {
  static Color darkblue1 = const Color(0xFF445FD2);
  static Color darkblue2 = const Color.fromARGB(255, 18, 48, 181);
  static Color lightblue1 = const Color.fromARGB(255, 136, 196, 255);
  static Color darkgrey1 = const Color(0xFFADA4A5);
  static Color yellow1 = const Color(0xFFC3BC83);
  static Color backgroundgray = const Color(0xFFD9D9D9);

  // static LinearGradient bluelinearMENU =
  //     linearGradient(MyColors.lightblue1.withOpacity(0), MyColors.darkblue1);

  static LinearGradient bluelinearMENU = linearGradient3(
      MyColors.lightblue1.withOpacity(0),
      MyColors.darkblue1.withOpacity(0.7),
      MyColors.darkblue2);

  static LinearGradient bluelinearBAR = linearGradient(
    MyColors.lightblue1.withOpacity(0.5),
    MyColors.lightblue1.withOpacity(0),
  );

  static LinearGradient linearGradient(Color startColor, Color endColor) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient linearGradient3(
      Color startColor, Color middleColor, Color endColor) {
    return LinearGradient(
      colors: [startColor, middleColor, endColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
