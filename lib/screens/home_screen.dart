import 'package:coden/components/badge_card.dart';
import 'package:coden/components/detail_card.dart';
import 'package:coden/components/streak_card.dart';
import 'package:coden/components/sub_detail_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:coden/components/contest_history.dart';
import 'package:coden/components/profile_pic.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const HomeScreen({super.key, required this.data});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userId = '';
  late List<dynamic> _filteredContestHistory;
  late String _userRanking = 'N/A';
  late int _totalSolved = 0;
  late int _totalSubmissionCount = 0;
  double _acceptanceRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _filterContestHistory();
    _extractSubmissionStats();
  }

  late String _statsdt = '';
  late String _statdt2 = '';

  void _extractSubmissionStats() {
    final submitStats = widget.data['matchedUser']?['submitStats'];
    if (submitStats != null) {
      final acSubmissionNum =
          submitStats['acSubmissionNum'] as List<dynamic>? ?? [];
      final totalSubmissionNum =
          submitStats['totalSubmissionNum'] as List<dynamic>? ?? [];

      double acAllSubmissions = 0.0;
      double totalAllSubmissions = 0.0;

      for (var entry in acSubmissionNum) {
        if (entry['difficulty'] == 'All') {
          acAllSubmissions = (entry['submissions'] is int)
              ? (entry['submissions'] as int).toDouble()
              : entry['submissions'] ?? 0.0;
          _totalSubmissionCount = entry['count'] ?? 0; // Update here
          break;
        }
      }

      for (var entry in totalSubmissionNum) {
        if (entry['difficulty'] == 'All') {
          totalAllSubmissions = (entry['submissions'] is int)
              ? (entry['submissions'] as int).toDouble()
              : entry['submissions'] ?? 0.0;
          break;
        }
      }

      if (totalAllSubmissions != 0) {
        _acceptanceRate = (acAllSubmissions / totalAllSubmissions) * 100;
      } else {
        _acceptanceRate = 0.0;
      }

      setState(() {
        _statsdt = 'AC Rate\nEasy\nMed\nHard';
        _statdt2 =
            '${_acceptanceRate.toStringAsFixed(2)}%\n${_getSolvedCount(acSubmissionNum, 'Easy')}\n${_getSolvedCount(acSubmissionNum, 'Medium')}\n${_getSolvedCount(acSubmissionNum, 'Hard')}';
        _totalSolved = acAllSubmissions.toInt();
      });
    }
  }

  int _getSolvedCount(List<dynamic> submissionList, String difficulty) {
    return submissionList.firstWhere(
          (item) => item['difficulty'] == difficulty,
          orElse: () => {'count': 0},
        )['count'] ??
        0;
  }

  void _loadUserData() {
    final box = Hive.box('userBox');
    setState(() {
      _userId = box.get('lc-userId', defaultValue: 'Unknown User');
      final rawRanking = widget.data['matchedUser']?['profile']?['ranking'];
      if (rawRanking != null) {
        _userRanking = NumberFormat.decimalPattern().format(rawRanking);
      } else {
        _userRanking = 'N/A';
      }
    });
  }

  void _filterContestHistory() {
    final contestHistory = widget.data['userContestRankingHistory'] ?? [];
    _filteredContestHistory = contestHistory
        .where((contest) =>
            (contest['totalProblems'] ?? 0) > 0 &&
            (contest['problemsSolved'] ?? 0) > 0)
        .toList();
  }

  List<FlSpot> _generateFilteredRatingPoints() {
    return List.generate(
      _filteredContestHistory.length,
      (index) => FlSpot(
        index.toDouble(),
        _filteredContestHistory[index]['rating']?.toDouble() ?? 0.0,
      ),
    );
  }

  String _getTopLanguage() {
    final languageStats = widget.data['matchedUser']?['languageProblemCount'];
    if (languageStats != null &&
        languageStats is List &&
        languageStats.isNotEmpty) {
      final topLanguage = languageStats[0];
      return topLanguage['languageName'] ?? 'Unknown';
    }
    return 'N/A';
  }

  String _getLanguageImagePath(String language) {
    switch (language) {
      case 'C++':
        return 'lib/assets/images/cpp.png';
      case 'Python':
        return 'lib/assets/images/py.png';
      case 'Java':
        return 'lib/assets/images/java.png';
      case 'JavaScript':
        return 'lib/assets/images/js.png';
      case 'C':
        return 'lib/assets/images/C.png';
      default:
        return 'lib/assets/images/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userContestRanking = widget.data['userContestRanking'];
    final ratingPoints = _generateFilteredRatingPoints();
    final userAvatar =
        widget.data['matchedUser']?['profile']?['userAvatar'] ?? '';
    final userBadge = widget.data['matchedUser']?['activeBadge']?['icon'] ?? '';
    final userBadgeName =
        widget.data['matchedUser']?['activeBadge']?['displayName'] ?? '';
    final topLanguage = _getTopLanguage();
    final topLanguageImagePath = _getLanguageImagePath(topLanguage);

    return Scaffold(
      backgroundColor: const Color(0xFF232530),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: Row(
                  children: [
                    ProfilePic(
                      radius: 40,
                      avatarUrl: userAvatar,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _userId,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DetailsCard(
                title: "PROGRESS",
                icon: Icons.analytics_sharp,
                color: const Color.fromARGB(255, 255, 246, 144),
                dynamicText: '$_totalSubmissionCount',
                dynamicText2: 'Out of 3385\n$_userRanking platform ranking',
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SubDetailsCard(
                      title: "STATS",
                      imagePath: 'lib/assets/images/stats.png',
                      color: const Color.fromARGB(255, 243, 160, 104),
                      dynamicText: _statsdt,
                      dynamicText2: _statdt2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: StreakCard(
                      title: "STREAK",
                      imagePath: 'lib/assets/images/streak.png',
                      color: Color.fromARGB(255, 192, 235, 128),
                      dynamicText: '7',
                      subline1: 'DAY',
                      subline2: 'STREAK',
                      dynamicText2: '',
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BadgeCard(
                      title: "TOP LANGUAGE",
                      imagePath: topLanguageImagePath,
                      color: const Color.fromARGB(255, 231, 149, 244),
                      dynamicText: topLanguage,
                      subline: 'Your most preffered language is',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BadgeCard(
                      title: "BADGE",
                      imagePath: userBadge,
                      color: const Color.fromARGB(255, 138, 205, 255),
                      dynamicText: userBadgeName,
                      subline: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildContestStatisticsSection(userContestRanking),
              const SizedBox(height: 20),
              Text(
                'Rating Progress Over Contests',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildRatingProgressChart(ratingPoints),
              const SizedBox(height: 20),
              Text(
                'Contest History',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildContestHistoryList(_filteredContestHistory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContestStatisticsSection(Map<String, dynamic>? contestRanking) {
    if (contestRanking == null) return const SizedBox.shrink();

    return Card(
      color: const Color(0xFF2C2F3E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticRow(
                'Attended Contests', contestRanking['attendedContestsCount']),
            _buildStatisticRow('Rating', contestRanking['rating']),
            _buildStatisticRow(
                'Global Ranking', contestRanking['globalRanking']),
            _buildStatisticRow(
                'Total Participants', contestRanking['totalParticipants']),
            _buildStatisticRow(
                'Top Percentage', '${contestRanking['topPercentage']}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          Text(
            '$value',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingProgressChart(List<FlSpot> ratingPoints) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 150,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide.none,
                top: BorderSide.none,
                right: BorderSide.none,
                bottom: BorderSide(color: Colors.white24),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: ratingPoints,
                isCurved: false,
                color: Colors.blue,
                barWidth: 3,
                isStrokeCapRound: false,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: false,
                ),
              ),
            ],
            minX: 0,
            maxX: ratingPoints.isNotEmpty
                ? ratingPoints.length.toDouble() - 1
                : 0,
            minY: ratingPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) -
                10,
            maxY: ratingPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) +
                10,
          ),
        ),
      ),
    );
  }

  Widget _buildContestHistoryList(List<dynamic> contestHistory) {
    return Column(
      children: contestHistory.map((contest) {
        final title = contest['contest']['title'];
        final rating = (contest['rating'] ?? 0.0).toInt();
        final solved = contest['problemsSolved'] ?? 0;
        final totalProblems = contest['totalProblems'] ?? 0;

        final subtitle = 'Rating: $rating | Solved: $solved/$totalProblems';

        return ContestHistoryCard(
          title: title,
          subtitle: subtitle,
        );
      }).toList(),
    );
  }
}
