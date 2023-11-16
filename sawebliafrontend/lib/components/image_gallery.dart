// import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:sawebliafrontend/services/airtableservices.dart';

// class ImageGalleryWidget extends StatefulWidget {
//   final String recordId;
//   ImageGalleryWidget({required this.recordId});

//   @override
//   _ImageGalleryWidgetState createState() => _ImageGalleryWidgetState();
// }

// class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
//   Future<List<String>>? _listImageUrlFuture;

//   AirtableServices _airtableServices = AirtableServices();

//   Future<List<String>> fetchImagesUrlFromAPI() async {
//     final imageUrlList = <String>[]; // Initialize the list here

//     final briefList =
//         await _airtableServices.fetchBreifByIdRecord(widget.recordId);

//     if (briefList.isNotEmpty) {
//       for (var briefItem in briefList) {
//         if (briefItem != null) {
//           if (briefItem['type'] == 'image/jpeg' ||
//               briefItem['type'] == 'image/png') {
//             imageUrlList.add(briefItem['url']);
//           }
//         }
//       }
//     }

//     return imageUrlList;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _listImageUrlFuture = fetchImagesUrlFromAPI();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: FutureBuilder<List<String>>(
//         future: _listImageUrlFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // While waiting for the future to complete, show a loading indicator
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             // If there's an error with the future, display an error message
//             return AlertDialog(
//               title: Text('Error'),
//               content: Text('Failed to load image URLs.'),
//             );
//           } else {
//             // If the future has completed successfully, show the gallery
//             List<String> imageUrls =
//                 snapshot.data ?? []; // Get the image URLs from the future
//             return PageView.builder(
//               itemCount: imageUrls.length,
//               itemBuilder: (BuildContext context, int index) {
//                 String imageUrl = imageUrls[index];
//                 return GestureDetector(
//                   onTap: () {
//                     _showSingleImage(context, imageUrl);
//                   },
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }

//   void _showSingleImage(BuildContext context, String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           contentPadding: EdgeInsets.zero,
//           content: SizedBox(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: PhotoView(
//               imageProvider: NetworkImage(imageUrl),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
