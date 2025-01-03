import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'lchome_screen.dart';

class LCLoginScreen extends StatefulWidget {
  const LCLoginScreen({super.key});

  @override
  State<LCLoginScreen> createState() => _LCLoginScreenState();
}

class _LCLoginScreenState extends State<LCLoginScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _loading = false;

  Future<Map<String, dynamic>> _fetch(String username) async {
    const String url = 'https://leetcode.com/graphql';
    const String query = '''
      query languageStats(\$username: String!) {
        matchedUser(username: \$username) {
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
          languageProblemCount {
            languageName
            problemsSolved
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
        userContestRanking(username: \$username) {
          attendedContestsCount
          rating
          globalRanking
          totalParticipants
          topPercentage    
        }
        userContestRankingHistory(username: \$username) {
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
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'variables': {'username': username}
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];

        final acsubmissions =
            data['matchedUser']?['submitStats']?['acSubmissionNum'];
        final totalsubmissions =
            data['matchedUser']?['submitStats']?['totalSubmissionNum'];

        double actotal = 0;
        double totalall = 0;

        if (acsubmissions != null && acsubmissions is List) {
          for (var entry in acsubmissions) {
            if (entry['difficulty'] == 'All') {
              actotal = (entry['submissions'] is int)
                  ? (entry['submissions'] as int).toDouble()
                  : entry['submissions'] ?? 0.0;
              break;
            }
          }
        }

        if (totalsubmissions != null && totalsubmissions is List) {
          for (var entry in totalsubmissions) {
            if (entry['difficulty'] == 'All') {
              totalall = (entry['submissions'] is int)
                  ? (entry['submissions'] as int).toDouble()
                  : entry['submissions'] ?? 0.0;
              break;
            }
          }
        }

        if (totalall != 0) {
          double percentage = (actotal / totalall) * 100;
        } else {
          throw Exception('Total submissions for "All" difficulty is 0.');
        }

        return data;
      } else {
        throw Exception('Failed to retrieve data');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _goto() async {
    final username = _ctrl.text.trim();

    if (username.isEmpty) {
      _show('Please enter a valid username');
      return;
    }

    setState(() => _loading = true);

    try {
      final userdata = await _fetch(username);
      final box = Hive.box('userBox');
      await box.put('lc-userId', username);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LCHomeScreen(data: userdata),
        ),
      );
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _show(String message) {
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
              controller: _ctrl,
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
                    onPressed: _goto,
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
