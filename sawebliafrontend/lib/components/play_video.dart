import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  final String videoUrl;
  PlayVideo({required this.videoUrl});

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showControls: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.darkblue1,
      ),
      body: Center(
        child: Chewie(controller: _chewieController),
      ),
    );
  }
}
