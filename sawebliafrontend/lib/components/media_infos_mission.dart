import 'package:flutter/material.dart';

import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';

import 'attachment_list.dart';

class InfosMission extends StatefulWidget {
  final String recordId;

  InfosMission({required this.recordId});
  @override
  State<InfosMission> createState() => _InfosMissionState();
}

class _InfosMissionState extends State<InfosMission> {
  final AirtableServices _airtableServices = AirtableServices();

  @override
  void initState() {
    super.initState();
    fetchVideoUrlsFromAPI();
    fetchAudioUrlsFromAPI();
    fetchImageUrlsFromAPI();
  }

  Future<List<String>> fetchVideoUrlsFromAPI() async {
    List<String> listurl = [];
    // print("Hello 2");
    // print(widget.recordId);
    final briefList = await _airtableServices
        .fetchBreifByIdRecord(widget.recordId); //widget.recordId
    // print("Hello 1");
    if (briefList.isNotEmpty) {
      for (var briefItem in briefList) {
        if (briefItem != null) {
          if (briefItem['type'] == 'video/mp4') {
            final videoUrl = briefItem['url'];
            listurl.add(videoUrl);
          }
        }
      }
    }
    return listurl;
  }

  Future<List<String>> fetchAudioUrlsFromAPI() async {
    List<String> listurl = [];
    final briefList = await _airtableServices
        .fetchBreifByIdRecord(widget.recordId); //widget.recordId
    // print("audio");
    if (briefList.isNotEmpty) {
      for (var briefItem in briefList) {
        if (briefItem != null) {
          if (briefItem['type'] == 'audio/ogg' ||
              briefItem['type'] == 'audio/mpeg' ||
              briefItem['type'] == 'audio/wav' ||
              briefItem['type'] == 'audio/mp3') {
            final audioUrl = briefItem['url'];
            listurl.add(audioUrl);
          }
        }
      }
    }
    return listurl;
  }

  Future<List<String>> fetchImageUrlsFromAPI() async {
    List<String> listurl = [];
    final briefList = await _airtableServices
        .fetchBreifByIdRecord(widget.recordId); //widget.recordId
    // print("image");
    if (briefList.isNotEmpty) {
      for (var briefItem in briefList) {
        if (briefItem != null) {
          if (briefItem['type'] == 'image/jpeg' ||
              briefItem['type'] == 'image/png' ||
              briefItem['type'] == 'image/jpg') {
            final imageUrl = briefItem['url'];
            listurl.add(imageUrl);
          }
        }
      }
    }
    return listurl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 200,
      child: FutureBuilder<List<String>>(
        future: fetchVideoUrlsFromAPI(),
        builder: (context, videoSnapshot) {
          if (videoSnapshot.connectionState == ConnectionState.waiting) {
            // Return loading indicator or placeholder widget
            return Center(
                child: CircularProgressIndicator(
              color: MyColors.darkblue1,
            ));
          } else if (videoSnapshot.hasError) {
            // Handle error case
            return Text('Error loading video URLs');
          } else {
            // Fetch audio and image URLs only when video URLs are fetched
            return FutureBuilder<List<String>>(
              future: fetchAudioUrlsFromAPI(),
              builder: (context, audioSnapshot) {
                if (audioSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: MyColors.darkblue1));
                } else if (audioSnapshot.hasError) {
                  return Text('Error loading audio URLs');
                } else {
                  return FutureBuilder<List<String>>(
                    future: fetchImageUrlsFromAPI(),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                                color: MyColors.darkblue1));
                      } else if (imageSnapshot.hasError) {
                        return Text('Error loading image URLs');
                      } else {
                        return AttachmentList(
                          videoUrls: videoSnapshot.data ?? [],
                          audioUrls: audioSnapshot.data ?? [],
                          imageUrls: imageSnapshot.data ?? [],
                        );
                      }
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
