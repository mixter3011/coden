import 'package:coden/screens/cfhome_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CFLoginScreen extends StatefulWidget {
  const CFLoginScreen({super.key});

  @override
  State<CFLoginScreen> createState() => _CFLoginScreenState();
}

class _CFLoginScreenState extends State<CFLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;

  Future<void> _fetch(String username) async {
    final String infourl =
        'https://codeforces.com/api/user.info?handles=$username';
    final String ratingurl =
        'https://codeforces.com/api/user.rating?handle=$username';
    final String statusurl =
        'https://codeforces.com/api/user.status?handle=$username&from=1&count=10';

    try {
      final inforesp = await http.get(Uri.parse(infourl));
      if (inforesp.statusCode != 200) {
        throw Exception('Failed to fetch user info from CodeForces API.');
      }
      final Map<String, dynamic> userInfoData = jsonDecode(inforesp.body);
      print('User Info: $userInfoData');

      final user = userInfoData['result'][0];
      final titlePhoto = user['titlePhoto'] ?? '';
      final contribution = user['contribution'] ?? 0;
      final rating = user['rating'] ?? 0;
      final friends = user['friendOfCount'] ?? 0;
      final maxRating = user['maxRating'] ?? 0;
      final maxRank = user['maxRank'] ?? '';

      final ratingresp = await http.get(Uri.parse(ratingurl));
      if (ratingresp.statusCode != 200) {
        throw Exception('Failed to fetch user rating from CodeForces API.');
      }
      final List<dynamic> ratingdata = jsonDecode(ratingresp.body)['result'];
      print('User Rating: $ratingdata');

      final statusresp = await http.get(Uri.parse(statusurl));
      if (statusresp.statusCode != 200) {
        throw Exception('Failed to fetch user status from CodeForces API.');
      }
      final List<dynamic> statusdata = jsonDecode(statusresp.body)['result'];
      print('User Status: $statusdata');

      final box = Hive.box('userBox');
      await box.put('cf-userId', username);
      await box.put('cf-avatarUrl', titlePhoto);
      await box.put('cf-contribution', contribution);
      await box.put('cf-rating', rating);
      await box.put('cf-friends', friends);
      await box.put('cf-maxRating', maxRating);
      await box.put('cf-maxRank', maxRank);
      await box.put('cf-contestHistory', ratingdata);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CFHomeScreen(),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _connect() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      _showError('Please enter a valid username');
      return;
    }

    setState(() {
      _loading = true;
    });

    _fetch(username).whenComplete(() {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232530),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'CODEN',
              style: GoogleFonts.poppins(
                fontSize: 48.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 40.0),
            Text(
              'Enter your CodeForces Username',
              style: GoogleFonts.poppins(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: GoogleFonts.poppins(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            const SizedBox(height: 24.0),
            _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 64.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'CONNECT',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
