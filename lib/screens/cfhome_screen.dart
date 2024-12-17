import 'dart:convert';

import 'package:coden/components/cf_contest_history.dart';
import 'package:coden/components/sub_detail_card.dart';
import 'package:coden/screens/cflogin_screen.dart';
import 'package:coden/screens/lchome_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class CFHomeScreen extends StatefulWidget {
  const CFHomeScreen({super.key});

  @override
  State<CFHomeScreen> createState() => _CFHomeScreenState();
}

class _CFHomeScreenState extends State<CFHomeScreen> {
  late final Box _userBox;
  late List<dynamic> _contestHistory;
  bool isleet = false;
  bool iscf = true;

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

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box('userBox');
    _contestHistory = _userBox.get('cf-contestHistory', defaultValue: []);
  }

  List<FlSpot> _getLineChartSpots() {
    return _contestHistory.asMap().entries.map((entry) {
      int index = entry.key;
      final newRating = entry.value['newRating'] ?? 0;
      return FlSpot(index.toDouble(), newRating.toDouble());
    }).toList();
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'newbie':
        return Colors.grey;
      case 'pupil':
        return Colors.green;
      case 'specialist':
        return Colors.cyan;
      case 'expert':
        return Colors.blue;
      case 'candidate master':
        return Colors.purple;
      case 'master':
      case 'international master':
        return Colors.orange;
      case 'grandmaster':
      case 'international grandmaster':
      case 'legendary grandmaster':
      case 'tourist':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _userBox.get('cf-avatarUrl', defaultValue: '');
    final username = _userBox.get('cf-userId', defaultValue: '');
    final contribution = _userBox.get('cf-contribution', defaultValue: 0);
    final rating = _userBox.get('cf-rating', defaultValue: 0);
    final friends = _userBox.get('cf-friends', defaultValue: 0);
    final maxRating = _userBox.get('cf-maxRating', defaultValue: 0);
    final maxRank = _userBox.get('cf-maxRank', defaultValue: '');

    return Scaffold(
      backgroundColor: const Color(0xFF232530),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80.0),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      radius: 60.0,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      username,
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      maxRank,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: _getRankColor(maxRank),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SubDetailsCard(
                      title: 'STATS',
                      color: Colors.yellow,
                      subline:
                          'You have $friends friend. Contribute & make more friends.',
                      image: 'lib/assets/images/contri.png',
                      text: '$contribution',
                      rate: 'CONTRIBUTIONS',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SubDetailsCard(
                      title: 'RANK',
                      color: Colors.white,
                      subline:
                          'Your max rating was $maxRating. Attend more contests and increase your rank.',
                      image: 'lib/assets/images/cf.webp',
                      text: '$rating',
                      rate: 'CURRENT RATING',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Text(
                'PROGRESS CHART',
                style: GoogleFonts.poppins(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                height: 150,
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameSize: 12,
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide.none,
                        top: BorderSide.none,
                        right: BorderSide.none,
                        bottom: BorderSide(width: 1, color: Colors.white24),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getLineChartSpots(),
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 1,
                        isStrokeCapRound: false,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    minX: 0,
                    maxX: _getLineChartSpots().isNotEmpty
                        ? _getLineChartSpots().length.toDouble() - 1
                        : 0,
                    minY: _getLineChartSpots()
                            .map((e) => e.y)
                            .reduce((a, b) => a < b ? a : b) -
                        10,
                    maxY: _getLineChartSpots()
                            .map((e) => e.y)
                            .reduce((a, b) => a > b ? a : b) +
                        10,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'CONTEST HISTORY',
                style: GoogleFonts.poppins(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),
              _history(_contestHistory),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: Colors.white,
          child: BottomAppBar(
            color: const Color(0xFF2C2F3E),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final lcid =
                            _userBox.get('lc-userId', defaultValue: '');
                        final data = await _fetch(username);
                        if (lcid != null && lcid.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LCHomeScreen(data: data)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CFLoginScreen()),
                          );
                        }
                        setState(() {
                          iscf = true;
                          isleet = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        backgroundColor:
                            isleet ? Colors.blue : Colors.grey.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                              color: Colors.white.withOpacity(0.4), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/images/lc.webp',
                            height: 28,
                            width: 28,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'LeetCode',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          iscf = true;
                          isleet = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        backgroundColor:
                            iscf ? Colors.blue : const Color(0xFF2C2F3E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                              color: Colors.white.withOpacity(0.4), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/images/cf.webp',
                            height: 24,
                            width: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Codeforces',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _history(List<dynamic> contestHistory) {
    return Column(
      children: contestHistory.map((contest) {
        final title = contest['contestName'] ?? '';
        final rating = contest['newRating'] ?? 0;
        final rank = contest['rank'] ?? '';
        final subtitle = 'Rank: $rank | Rating: $rating';

        return CFContestHistoryCard(
          title: title,
          subtitle: subtitle,
        );
      }).toList(),
    );
  }
}
