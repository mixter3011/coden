import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePic extends StatelessWidget {
  final double radius;

  const ProfilePic({
    super.key,
    this.radius = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('userBox');
    final username = box.get('lc-userId', defaultValue: 'Unknown');

    final profilePicUrl =
        'https://assets.leetcode.com/users/$username/avatar_1695594708.png';

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: profilePicUrl,
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
