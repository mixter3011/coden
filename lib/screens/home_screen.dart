import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:coden/components/contest_history.dart';
import 'package:coden/components/detail_card.dart';
import 'package:coden/components/profile_pic.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const HomeScreen({super.key, required this.data});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userId = '';
  late List<dynamic> _filteredContestHistory;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _filterContestHistory();
  }

  void _loadUserData() {
    final box = Hive.box('userBox');
    setState(() {
      _userId = box.get('lc-userId', defaultValue: 'Unknown User');
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

  @override
  Widget build(BuildContext context) {
    final userContestRanking = widget.data['userContestRanking'];
    final ratingPoints = _generateFilteredRatingPoints();

    final userAvatar =
        widget.data['matchedUser']?['profile']?['userAvatar'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF232530),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                children: [
                  ProfilePic(
                    radius: 40,
                    avatarUrl: userAvatar,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _userId.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const DetailsCard(
                title: "PROGRESS",
                icon: Icons.menu_book_outlined,
                color: Color.fromARGB(255, 255, 246, 144),
                dynamicText: 'Out of 3374 Questions',
              ),
              const SizedBox(height: 5),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DetailsCard(
                      title: "STATS",
                      icon: Icons.show_chart,
                      color: Color.fromARGB(255, 255, 136, 57),
                      dynamicText: 'LOL',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DetailsCard(
                      title: "LEVEL",
                      icon: Icons.leaderboard,
                      color: Color.fromARGB(255, 192, 235, 128),
                      dynamicText: 'LOL',
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DetailsCard(
                      title: "STATS",
                      icon: Icons.show_chart,
                      color: Color.fromARGB(255, 163, 71, 178),
                      dynamicText: 'LOL',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DetailsCard(
                      title: "LEVEL",
                      icon: Icons.leaderboard,
                      color: Color.fromARGB(255, 138, 205, 255),
                      dynamicText: 'LOL',
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
