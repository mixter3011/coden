import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CFHomeScreen extends StatefulWidget {
  const CFHomeScreen({super.key});

  @override
  State<CFHomeScreen> createState() => _CFHomeScreenState();
}

class _CFHomeScreenState extends State<CFHomeScreen> {
  late final Box _userBox;
  late List<dynamic> _contestHistory;

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl),
                    radius: 40.0,
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Max Rank: $maxRank',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F38),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Contribution', contribution.toString()),
                    _buildStatCard('Friends', friends.toString()),
                    _buildStatCard('Rating', rating.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Contest History',
                style: GoogleFonts.poppins(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                height: 300.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F38),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.white),
                        bottom: BorderSide(color: Colors.white),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getLineChartSpots(),
                        isCurved: true,
                        barWidth: 3.0,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.0,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
