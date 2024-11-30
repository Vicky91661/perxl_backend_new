import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MyPdfViewer extends StatefulWidget {
  final String pdfUrl; // This should be a URL

  MyPdfViewer({required this.pdfUrl});

  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _downloadPdf() async {
    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      try {
        Dio dio = Dio();
        String fileName = widget.pdfUrl.split('/').last;
        Directory tempDir = await getApplicationDocumentsDirectory();
        String savePath = '${tempDir.path}/$fileName';

        await dio.download(
          widget.pdfUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (mounted && total != -1) {
              setState(() {
                _downloadProgress = (received / total);
              });
            }
          },
        );

        if (mounted) {
          setState(() {
            _isDownloading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded to $savePath')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.black,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          _isDownloading
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: _downloadProgress,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.black,
                    semanticLabel: 'Download',
                  ),
                  onPressed: _downloadPdf,
                ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,
      ),
    );
  }
}
