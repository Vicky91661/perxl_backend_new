import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MyPdfViewer extends StatefulWidget {
  final String pdfUrl; // This should be a local file path

  MyPdfViewer({required this.pdfUrl});

  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _downloadPdf() async {
    // Map<Permission, PermissionStatus> status =
    //     await [Permission.storage].request();

    // if (status[Permission.storage]!.isGranted) {
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
            if (total != -1) {
              setState(() {
                _downloadProgress = (received / total);
              });
            }
          },
        );

        setState(() {
          _isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded to $savePath')),
        );
      } catch (e) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    // } else {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text("Permission Denied")));
    // }
    
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
// import 'package:permission_handler/permission_handler.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// class MyPdfViewer extends StatefulWidget {
//   final String pdfUrl; // This should be a URL for an online PDF file.

//   MyPdfViewer({Key? key, required this.pdfUrl}) : super(key: key);

//   @override
//   _MyPdfViewerState createState() => _MyPdfViewerState();
// }

// class _MyPdfViewerState extends State<MyPdfViewer> {
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
//   bool _isDownloading = false;
//   double _downloadProgress = 0.0;

//   Future<void> _downloadPdf() async {
//     // Check and request storage permissions.
//     final status = await Permission.storage.request();
//      if (status.isPermanentlyDenied) {
//       // If the user permanently denied the permission, navigate them to settings.
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Permission permanently denied. Please enable it from settings.'),
//           action: SnackBarAction(
//             label: 'Settings',
//             onPressed: () {
//               openAppSettings();
//             },
//           ),
//         ),
//       );
//       return;
//     }
//     if (status.isGranted) {
//       setState(() {
//         _isDownloading = true;
//         _downloadProgress = 0.0;
//       });

//       try {
//         final dio = Dio();
//         final fileName = widget.pdfUrl.split('/').last;
//         final tempDir = await getExternalStorageDirectory();
//         if (tempDir == null) throw Exception('Unable to access storage');
//         final savePath = '${tempDir.path}/$fileName';

//         await dio.download(
//           widget.pdfUrl,
//           savePath,
//           onReceiveProgress: (received, total) {
//             if (total != -1) {
//               setState(() {
//                 _downloadProgress = received / total;
//               });
//             }
//           },
//         );

//         setState(() {
//           _isDownloading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Downloaded to $savePath')),
//         );
//       } catch (e) {
//         setState(() {
//           _isDownloading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Download failed: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Permission Denied")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF Viewer'),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(
//               Icons.bookmark,
//               color: Colors.white,
//               semanticLabel: 'Bookmark',
//             ),
//             onPressed: () {
//               _pdfViewerKey.currentState?.openBookmarkView();
//             },
//           ),
//           _isDownloading
//               ? Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       value: _downloadProgress,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )
//               : IconButton(
//                   icon: const Icon(
//                     Icons.download,
//                     color: Colors.white,
//                     semanticLabel: 'Download',
//                   ),
//                   onPressed: _downloadPdf,
//                 ),
//         ],
//       ),
//       body: SfPdfViewer.network(
//         widget.pdfUrl,
//         key: _pdfViewerKey,
//       ),
//     );
//   }
// }
