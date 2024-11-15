import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class MyPdfViewer extends StatefulWidget {
  final String pdfUrl; // This should be a local file path

  MyPdfViewer({required this.pdfUrl});

  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  PDFViewController pdfViewController;
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  String errorMessage = '';
  String localPdfPath = '';

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    createFileOfPdfUrl();
  }

  Future<void> requestStoragePermission() async {
    // PermissionHandler().requestPermissions([PermissionGroup.storage]);
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Storage permission denied.');
    } else {
      print('Storage permission granted.');
    }
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final url = widget.pdfUrl;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await http.get(Uri.parse(url));
      var bytes =request.bodyBytes;
      if (request.statusCode == 200) {
        var dir = await getApplicationDocumentsDirectory();
        String filePath = "${dir.path}/$filename/.pdf";
        File file = File(filePath);
        File urlFile =await file.writeAsBytes(bytes, flush: true);
        print('File size: ${await file.length()} bytes');

        if (await file.length() > 0) {
          setState(() {
            localPdfPath = urlFile.path;
          });
          completer.complete(file);
        } else {
          throw Exception('Downloaded file is empty.');
        }
      } else {
        throw Exception('Failed to download file: ${request.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error downloading PDF: $e';
      });
      print('Error downloading PDF: $e');
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: localPdfPath.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localPdfPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              onRender: (pages) {
                setState(() {
                  isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
                print('Error rendering PDF: $error');
              },
              onPageError: (page, error) {
                print('Page error on page $page: $error');
              },
              onPageChanged: (page, total) {
                setState(() {
                  currentPage = page ?? 0;
                });
              },
            ),
    );
  }
}
