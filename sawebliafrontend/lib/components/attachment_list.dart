import 'package:flutter/material.dart';
import 'package:sawebliafrontend/components/play_audio.dart';
import 'package:sawebliafrontend/components/play_video.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AttachmentList extends StatelessWidget {
  final List<String> videoUrls;
  final List<String> audioUrls;
  final List<String> imageUrls;

  AttachmentList({
    required this.videoUrls,
    required this.audioUrls,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: videoUrls.length + audioUrls.length + imageUrls.length,
      itemBuilder: (context, index) {
        if (index < videoUrls.length) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PlayVideo(videoUrl: videoUrls[index]),
                    fullscreenDialog: true),
              );
            },
            child: Container(
              color: MyColors.darkblue1,
              child: Icon(
                Icons.video_library,
                color: Colors.white,
              ),
            ),
          );
        } else if (index < videoUrls.length + audioUrls.length) {
          int audioIndex = index - videoUrls.length;
          return GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AudioPlayerWidget(audioUrl: audioUrls[audioIndex]);
                  });
            },
            child: Container(
              color: MyColors.darkblue1,
              child: Icon(
                Icons.mic_outlined,
                color: Colors.white,
              ),
            ),
          );
        } else {
          int imageIndex = index - videoUrls.length - audioUrls.length;
          return GestureDetector(
            onTap: () {
              _showImageDialog(context, imageUrls[imageIndex]);
            },
            child: Image.network(
              imageUrls[imageIndex],
              fit: BoxFit.cover,
            ),
          );
        }
      },
    );
  }
}

void _showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.darkblue1, // Background color of the circle
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(
                        context); // Close the dialog when the close button is pressed
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
