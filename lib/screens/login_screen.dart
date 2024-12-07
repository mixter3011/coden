import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:html/parser.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  Future<String?> _scrapeLeetCodeSpanValue(String username) async {
    final String url = 'https://leetcode.com/u/$username/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = parse(response.body);
        var elements = document.getElementsByClassName(
          'mx-1 text-sm font-medium text-brand-orange dark:text-dark-brand-orange',
        );
        if (elements.isNotEmpty) {
          return elements[0].text.trim();
        } else {
          throw Exception('Span element not found');
        }
      } else {
        throw Exception('Failed to load LeetCode page');
      }
    } catch (e) {
      print('Error scraping LeetCode data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchLeetCodeData(String username) async {
    const String apiUrl = 'https://leetcode.com/graphql';
    final String query = '''
  query {
    matchedUser(username: "$username") {
      username
      githubUrl
      twitterUrl
      linkedinUrl
      contributions {
          points
          questionCount
          testcaseCount
      }
      profile {
          realName
          userAvatar
          birthday
          ranking
          reputation
          websites
          countryName
          company
          school
          skillTags
          aboutMe
          starRating
      }
      badges {
          id
          displayName
          icon
          creationDate
      }
      upcomingBadges {
          name
          icon
      }
      activeBadge {
          id
          displayName
          icon
          creationDate
      }
      submitStats {
          totalSubmissionNum {
              difficulty
              count
              submissions
          }
          acSubmissionNum {
              difficulty
              count
              submissions
          }
      }
      submissionCalendar
    }
    userContestRanking(username: "$username") {
      attendedContestsCount
      rating
      globalRanking
      totalParticipants
      topPercentage    
    }
    userContestRankingHistory(username: "$username") {
      attended
      trendDirection
      problemsSolved
      totalProblems
      finishTimeInSeconds
      rating
      ranking
      contest {
        title
        startTime
      }
    }
  }
  ''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];
        return data;
      } else {
        throw Exception('Failed to retrieve LeetCode data');
      }
    } catch (e) {
      print('Error fetching LeetCode data: $e');
      rethrow;
    }
  }

  void _navigateToHomeScreen() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      _showErrorDialog('Please enter a valid username');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = await _fetchLeetCodeData(username);
      final scrapedValue = await _scrapeLeetCodeSpanValue(username);
      print('Scraped value: $scrapedValue');

      final submitStats = userData['matchedUser']?['submitStats'];
      final submissionCalendar = userData['matchedUser']?['submissionCalendar'];

      print('$userData');
      print('submitStats: $submitStats');
      print('submissionCalendar: $submissionCalendar');

      final box = Hive.box('userBox');
      await box.put('lc-userId', username);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(data: userData),
        ),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
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
              'Enter your LeetCode Username',
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
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: _navigateToHomeScreen,
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
