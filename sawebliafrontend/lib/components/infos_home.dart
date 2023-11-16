import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sawebliafrontend/pages/suivre_mission.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';

class InfosHome extends StatefulWidget {
  final int number;
  final String? currency;

  final String text;
  final String iconLink;
  const InfosHome(
      {super.key,
      required this.number,
      this.currency,
      required this.text,
      required this.iconLink});

  @override
  State<InfosHome> createState() => _InfosHomeState();
}

class _InfosHomeState extends State<InfosHome> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.text != "Bonus") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SuivreMission(),
              fullscreenDialog: true,
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 231, 230, 230),
              spreadRadius: 1,
              blurRadius: 30,
              offset: Offset(0, 10), // Set box shadow properties
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //TITLE + ICON
              Row(
                children: [
                  Text(
                    widget.text,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  SizedBox(
                      width: 40,
                      height: 40,
                      child: SvgPicture.asset(widget.iconLink)),
                ],
              ),
              SizedBox(
                height: 10,
              ),

              //NUMBER
              Container(
                height: 70,
                width: 150,
                decoration: BoxDecoration(
                    color: MyColors.backgroundgray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                      (widget.currency != null)
                          ? widget.number.toString() + " " + widget.currency!
                          : widget.number.toString(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
