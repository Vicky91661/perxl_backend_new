import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pexllite/screens/FullScreenImageViewer.dart';// Import the FullScreenImageViewer file

class ProfileImage extends StatelessWidget {
  final double size;
  final String url;

  const ProfileImage({super.key, required this.size, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the FullScreenImageViewer when the image is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageViewer(imageUrl: url),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(size)),
        child: CachedNetworkImage(
          width: size,
          height: size,
          fit: BoxFit.cover,
          imageUrl: url,
          errorWidget: (context, url, error) =>
              const CircleAvatar(child: Icon(CupertinoIcons.person)),
        ),
      ),
    );
  }
}
