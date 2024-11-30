import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

Future<XFile?> compressImage(File imageFile, {int quality = 10}) async {
  print("the original image is ${imageFile.path}");

  final targetPath =
      "${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}";

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    imageFile.path, // Source file path
    targetPath, // Destination file path
    quality: quality, // Compression quality (1-100)
  );
   if (compressedFile == null) {
    print("Failed to compress image.");
    return null;
  }
  print("The original file size is =>${imageFile.lengthSync()}");
  print("The compressed file size is =>${compressedFile.length}");
  return compressedFile;
}
