import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({required this.audioUrl});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

   @override
  void initState() {
    super.initState();
    // Add a listener to handle when the audio completes
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final String audioUrl = widget.audioUrl;

    if (_isPlaying) {
      print("The audio url is $audioUrl");
      await _audioPlayer.pause();
    } else {
      // Check if the audio URL is valid
      if (widget.audioUrl.isNotEmpty) {
        print("The audio url is ${widget.audioUrl}");
        await _audioPlayer.play(UrlSource(widget.audioUrl));
      } else {
        print("Invalid audio URL.");
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45, // Set a slightly smaller width
      height: 50, // Set a custom height
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
               
              children: [
                Icon(_isPlaying ? Icons.cancel : Icons.play_arrow,color: Colors.white, size: 30,),
                const SizedBox(width: 5),
                Text(
                  'Audio.mp3',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Ensures the text doesn't overflow
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
