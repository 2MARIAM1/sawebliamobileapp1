import 'package:flutter/material.dart';
import 'package:sawebliafrontend/pages/missions_terminees.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';

import '../models/Formulaire.dart';

class FormSubmitPage extends StatefulWidget {
  final String missionsRecordId;

  const FormSubmitPage({super.key, required this.missionsRecordId});
  @override
  _FormSubmitPageState createState() => _FormSubmitPageState();
}

class _FormSubmitPageState extends State<FormSubmitPage> {
  final AirtableServices _airtableServices = AirtableServices();
  final _formKey = GlobalKey<FormState>();
  final _formSubmission = FormSubmission(
    prixTotalEstime: 0,
    prixMainDOeuvre: 0,
    prixEstimeFournitures: 0,
    dureeEstimee: 0,
    missionId: "", // Set the mission ID here
  );

  final TextEditingController _durationController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _formSubmission.missionId = widget.missionsRecordId;

    //   _durationController.addListener(_formatDurationInput);
  }

  // void _formatDurationInput() {
  //   final input = _durationController.text;
  //   final parts = input.split(':');

  //   if (parts.length == 1 && parts[0].length == 1) {
  //     // Format: mm => 00:mm:00
  //     _durationController.text = '00:$input:00';
  //   } else if (parts.length == 2 && parts[0].length == 1) {
  //     // Format: h:mm => 0h:mm:00
  //     _durationController.text = '0$input';
  //   }
  // }

  @override
  void dispose() {
    //   _durationController.removeListener(_formatDurationInput);
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DEVIS   استمارة'),
        centerTitle: true,
        backgroundColor: MyColors.darkblue1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر الإجمالي للخدمة',
                      labelStyle: TextStyle(
                          color: MyColors.darkblue1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      hintText: "0",
                      suffixText: 'درهم',
                      suffixStyle: TextStyle(color: MyColors.darkgrey1),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .darkblue1, // Change to your desired focused border color
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .backgroundgray, // Change to your desired focused border color
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        _formSubmission.prixTotalEstime = double.parse(value!),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'سعر عمل اليد',
                      labelStyle: TextStyle(
                          color: MyColors.darkblue1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      hintText: "0",
                      suffixText: 'درهم',
                      suffixStyle: TextStyle(color: MyColors.darkgrey1),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .darkblue1, // Change to your desired focused border color
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .backgroundgray, // Change to your desired focused border color
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        _formSubmission.prixMainDOeuvre = double.parse(value!),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'سعر السلع المطلوبة',
                      labelStyle: TextStyle(
                          color: MyColors.darkblue1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      suffixText: 'درهم',
                      suffixStyle: TextStyle(color: MyColors.darkgrey1),
                      hintText: "0",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .darkblue1, // Change to your desired focused border color
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .backgroundgray, // Change to your desired focused border color
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم';
                      }
                      return null;
                    },
                    onSaved: (value) => _formSubmission.prixEstimeFournitures =
                        double.parse(value!),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'ساعات العمل',
                      labelStyle: TextStyle(
                          color: MyColors.darkblue1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      hintText: "0",
                      suffixText: 'ساعات',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .darkblue1, // Change to your desired focused border color
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors
                              .backgroundgray, // Change to your desired focused border color
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Convert duration to seconds
                      List<String> durationParts =
                          _durationController.text.split(':');
                      if (durationParts.length == 3) {
                        int hours = int.parse(durationParts[0]);
                        int minutes = int.parse(durationParts[1]);
                        int seconds = int.parse(durationParts[2]);
                        _formSubmission.dureeEstimee =
                            hours * 3600 + minutes * 60 + seconds;
                      } else if (durationParts.length == 2) {
                        int hours = int.parse(durationParts[0]);
                        int minutes = int.parse(durationParts[1]);
                        _formSubmission.dureeEstimee =
                            hours * 3600 + minutes * 60;
                      } else if (durationParts.length == 1) {
                        int hours = int.parse(durationParts[0]);
                        _formSubmission.dureeEstimee = hours * 3600;
                      }

                      // Submit the form
                      _airtableServices.submitForm(_formSubmission).then((_) {
                        ////SHOW Success DIALOG
                        _ShowSuccessDialog();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(primary: MyColors.darkblue1),
                  child: Text(
                    'إرسال الاستمارة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ShowSuccessDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),
              SizedBox(width: 10),
              Text(
                'تم بنجاح',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'تم إرسال الاستمارة بنجاح!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MissionsTerminees(),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: Text(
                'X',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: MyColors.darkblue1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
