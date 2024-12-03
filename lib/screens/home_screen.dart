import 'package:coden/components/contest_history.dart';
import 'package:coden/components/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const HomeScreen({super.key, required this.data});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final box = Hive.box('userBox');
    setState(() {
      _userId = box.get('lc-userId', defaultValue: 'Unknown User');
    });
  }

  List<FlSpot> _generateRatingPoints() {
    final userContestRankingHistory = widget.data['userContestRankingHistory'];
    return List.generate(
      userContestRankingHistory.length,
      (index) => FlSpot(
        index.toDouble(),
        userContestRankingHistory[index]['rating'] ?? 0.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userContestRanking = widget.data['userContestRanking'];
    final userContestRankingHistory = widget.data['userContestRankingHistory'];
    final ratingPoints = _generateRatingPoints();

    return Scaffold(
      backgroundColor: const Color(0xFF232530),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                children: [
                  const ProfilePic(radius: 40),
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
              _buildContestHistoryList(userContestRankingHistory),
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
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                isStrokeCapRound: true,
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
