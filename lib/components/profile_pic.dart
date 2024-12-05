import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePic extends StatelessWidget {
  final double radius;
  final String avatarUrl;

  const ProfilePic({
    super.key,
    this.radius = 50.0,
    required this.avatarUrl, // Now accepts avatarUrl from HomeScreen
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl, // Use the passed avatarUrl
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(
            Icons.account_circle,
            size: radius * 2,
            color: Colors.grey,
          ),
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
        ),
      ),
    );
  }
}
