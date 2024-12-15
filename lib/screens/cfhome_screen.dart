import 'package:coden/components/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CFHomeScreen extends StatefulWidget {
  const CFHomeScreen({super.key});

  @override
  State<CFHomeScreen> createState() => _CFHomeScreenState();
}

class _CFHomeScreenState extends State<CFHomeScreen> {
  String _username = 'User';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final box = Hive.box('userBox');
    setState(() {
      _username = box.get('cf-userId', defaultValue: 'Guest');
      _avatarUrl = box.get('cf-avatarUrl', defaultValue: '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232530),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80.0),
          Center(
            child: ProfilePic(
              avatarurl: _avatarUrl.isNotEmpty ? _avatarUrl : '',
              radius: 60.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Center(
            child: Text(
              _username,
              style: const TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
