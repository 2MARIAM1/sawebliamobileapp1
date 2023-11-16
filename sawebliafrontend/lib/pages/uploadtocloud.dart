import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sawebliafrontend/models/FeedbackArtisan.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/pages/homepage.dart';
import 'package:sawebliafrontend/pages/missions_terminees.dart';
import 'package:sawebliafrontend/services/airtableservices.dart';
import 'package:sawebliafrontend/services/feedbackService.dart';
import 'package:sawebliafrontend/services/googlecloud_api.dart';
import 'package:sawebliafrontend/services/missionservice.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadMediaToCloud extends StatefulWidget {
  final int missionId;

  const UploadMediaToCloud({super.key, required this.missionId});
  @override
  _UploadMediaToCloudState createState() => _UploadMediaToCloudState();
}

class _UploadMediaToCloudState extends State<UploadMediaToCloud> {
  List<File> _images = [];
  List<Uint8List> _photoBytesList = [];

  List<File> _videos = [];
  List<Uint8List> _videoThumbnailBytesList = [];
  final picker = ImagePicker();
  CloudApi? api;
  bool loading = false;
  final MissionService _missionService = MissionService();
  final FeedbackService _feedbackService = FeedbackService();
  final AirtableServices _airtableServices = AirtableServices();
  Mission? mission;
  static const int maxVideos = 4;
  static const int maxImages = 4;

  @override
  void initState() {
    super.initState();
    fetchMission();

    rootBundle.loadString('assets/credentials.json').then((json) {
      api = CloudApi(json);
    });
  }

  Future<void> fetchMission() async {
    mission = await _missionService.getMissionById(widget.missionId);
    setState(() {});
  }

  void _getRecordedVideo() async {
    if (_videos.length < maxVideos) {
      final pickedFile = await picker.pickVideo(source: ImageSource.camera);

      setState(() {
        if (pickedFile != null) {
          _videos.add(File(pickedFile.path));
          _getVideoThumbnail(pickedFile.path);
        } else {
          print('No video recorded.');
        }
      });
    } else {
      // Show warning when max videos are reached
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum number of videos reached')),
      );
    }
  }

  void _getVideoFromGallery() async {
    if (_videos.length < maxVideos) {
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _videos.add(File(pickedFile.path));
          _getVideoThumbnail(pickedFile.path);
        } else {
          print('No video selected.');
        }
      });
    } else {
      // Show warning when max videos are reached
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا تتجاوز 4 فيديوهات')),
      );
    }
  }

  void _getImage(ImageSource source) async {
    if (_images.length < maxImages) {
      final pickedFile = await picker.pickImage(source: source);

      setState(() {
        if (pickedFile != null) {
          _images.add(File(pickedFile.path));
          _getPhotoThumbnail(pickedFile.path);
        } else {
          print('No media selected.');
        }
      });
    } else {
      // Show warning when max images are reached
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا تتجاوز 4 صور')),
      );
    }
  }

  Future<void> _getVideoThumbnail(String videoPath) async {
    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: videoPath,
      quality: 50,
    );

    setState(() {
      _videoThumbnailBytesList.add(thumbnailBytes!);
    });
  }

  void _getPhotoThumbnail(String photoPath) async {
    final photoBytes = File(photoPath).readAsBytesSync();

    setState(() {
      _photoBytesList.add(photoBytes);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _videos.removeAt(index);
      _videoThumbnailBytesList.removeAt(index);
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _images.removeAt(index);
      _photoBytesList.removeAt(index);
    });
  }

  Future<void> sendFeedbackToAirtable(
      String type, String name, String url, missionRecordId) async {
    await _airtableServices.addRecordToAirtable(
        type, name, url, missionRecordId);
  }

  Future<void> sendFeedbackToDatabase(
      Mission mymission, String type, String name, String url) async {
    await _feedbackService.addFeedbackToDatabase(FeedbackArtisan(
        mission: mymission, nomFichier: name, typeFichier: type, url: url));
  }

  void _saveAllToCloud() async {
    setState(() {
      loading = true;
    });

    for (int i = 0; i < _videos.length; i++) {
      final video = _videos[i];
      final videoBytes = video.readAsBytesSync();
      final videoName = video.path.split('/').last;

      final response = await api?.save(videoName, videoBytes);

      //SAVE TO AIRTABLE && database
      if (mission != null) {
        sendFeedbackToAirtable(
          'Video',
          videoName,
          '${response?.downloadLink}',
          mission!.idRecord!,
        );
        sendFeedbackToDatabase(
            mission!, 'Video', videoName, '${response?.downloadLink}');
      }
    }
    for (int i = 0; i < _images.length; i++) {
      final image = _images[i];
      final imageBytes = image.readAsBytesSync();
      final imageName = image.path.split('/').last;

      final response2 = await api?.save(imageName, imageBytes);
      //SAVE TO AIRTABLE && database
      if (mission != null) {
        sendFeedbackToAirtable(
          'Image',
          imageName,
          '${response2?.downloadLink}',
          mission!.idRecord!,
        );
        sendFeedbackToDatabase(
            mission!, 'Image', imageName, '${response2?.downloadLink}');
      }
    }

    setState(() {
      loading = false;
      _videos.clear();
      _videoThumbnailBytesList.clear();
      _images.clear();
      _photoBytesList.clear();
    });

    // Show success dialog
    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تحميل صور و فيديوهات"),
        centerTitle: true,
        backgroundColor: MyColors.darkblue1,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Center(
          child: Column(
            children: [
              //VIDEOS
              if (_videoThumbnailBytesList.isNotEmpty) _buildVideosContainer(),
              SizedBox(
                height: 20,
              ),

              //PHOTOS
              if (_photoBytesList.isNotEmpty) _buildPhotosContainer()
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed:
                _videos.isEmpty && _images.isEmpty ? null : _saveAllToCloud,
            tooltip: 'ارسال',
            hoverColor: MyColors.lightblue1,
            child: loading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Column(
                    children: [
                      Icon(Icons.done_outline_rounded),
                      Text(
                        "إرسال",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            backgroundColor:
                _videoThumbnailBytesList.isEmpty && _photoBytesList.isEmpty
                    ? Colors.grey
                    : MyColors.darkblue1,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 150,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: Colors.white),
              onPressed: () {
                _getRecordedVideo();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (Icons.videocam_rounded),
                    size: 28,
                    color: MyColors.darkblue1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "تسجيل",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text("فيديو",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: Colors.white),
              onPressed: () {
                _getVideoFromGallery();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (Icons.video_library_rounded),
                    size: 28,
                    color: MyColors.darkblue1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "تحميل",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text("فيديو",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: Colors.white),
              onPressed: () {
                _getImage(ImageSource.camera);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (Icons.camera),
                    size: 28,
                    color: MyColors.darkblue1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "تسجيل",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text("صورة",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: Colors.white),
              onPressed: () {
                _getImage(ImageSource.gallery);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (Icons.photo_library),
                    size: 28,
                    color: MyColors.darkblue1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "تحميل",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text("صورة",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosContainer() {
    return Container(
      width: double.infinity,
      height: 140,
      color: MyColors.backgroundgray.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 5),
            child: Text(
              'فيديوهات',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: MyColors.darkblue2,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: _videoThumbnailBytesList.length,
              itemBuilder: (context, index) {
                return _videoThumbnailBytesList.isNotEmpty
                    ? Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child:
                                  Image.memory(_videoThumbnailBytesList[index]),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline_outlined,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _removeVideo(index);
                              },
                            ),
                          ),
                        ],
                      )
                    : Text('Nothing selected');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosContainer() {
    return Container(
      width: double.infinity,
      height: 140,
      color: MyColors.backgroundgray.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 5),
            child: Text(
              'صور',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: MyColors.darkblue2,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: _photoBytesList.length,
              itemBuilder: (context, index) {
                return _photoBytesList.isNotEmpty
                    ? Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.memory(_photoBytesList[index]),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline_outlined,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _removePhoto(index);
                              },
                            ),
                          ),
                        ],
                      )
                    : Text('Nothing selected');
              },
            ),
          ),
        ],
      ),
    );
  }

  _showSuccessDialog() {
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
            'تم إرسال الملفات  بنجاح!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MissionsTerminees(),
                    // fullscreenDialog: true,
                  ),
                );
              },
              child: Text(
                'X',
                textAlign: TextAlign.right,
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

//  ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white, elevation: 1),
//               onPressed: () {
//                 _getRecordedVideo();
//               },
//               child: Column(
//                 children: [
//                   Icon(
//                     (Icons.videocam),
//                     color: MyColors.darkblue1,
//                   ),
//                   Text("تسجيل"),
//                   Text("فيديو")
//                 ],
//               ),
//             ),
