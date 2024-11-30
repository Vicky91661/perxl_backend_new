import 'package:flutter/material.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pexllite/constants.dart';
import 'package:video_player/video_player.dart';

class FilePreviewScreen extends StatefulWidget {
  final String filePath;
  final Function onSend;

  FilePreviewScreen({required this.filePath, required this.onSend});

  @override
  _FilePreviewScreenState createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.filePath.endsWith('.mp4')) {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          setState(() {}); // Update UI once video is initialized
        }).catchError((e) {
          print('Error initializing video: $e');
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildFilePreview() {
    if (widget.filePath.endsWith('.jpg') ||
        widget.filePath.endsWith('.jpeg') ||
        widget.filePath.endsWith('.png')) {
      return Image.file(File(widget.filePath), fit: BoxFit.cover);
    } else if (widget.filePath.endsWith('.pdf')) {
      return SfPdfViewer.file(
        File(widget.filePath)
      );
    } else if (widget.filePath.endsWith('.mp4')) {
      return _videoController != null && _videoController!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          : Center(child: Text('Video: ${widget.filePath.split('/').last}'));
    } else {
      return Center(child: Text('Unsupported file type'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'File Preview',
              style: TextStyle(
              color: Colors.white,
            ),
          ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: _buildFilePreview()),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed:() {
                  widget.onSend();
                  Navigator.pop(context, true); // Return to ChatScreen with a flag
                },
                icon: Icon(Icons.send),
                label: Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
