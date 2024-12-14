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

class LCHomeScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const LCHomeScreen({super.key, required this.data});

  @override
  State<LCHomeScreen> createState() => _LCHomeScreenState();
}

class _LCHomeScreenState extends State<LCHomeScreen> {
  String _id = '';
  late List<dynamic> _filtered;
  late String _ranking = 'N/A';
  late int _total = 0;
  late int _totalsubscount = 0;
  double _acrate = 0.0;

  bool isleet = true;
  bool iscf = false;

  @override
  void initState() {
    super.initState();
    _load();
    _filter();
    _extract();
  }

  late String _text = '';
  late String _rate = '';
  late String _subline = '';

  void _extract() {
    final stats = widget.data['matchedUser']?['submitStats'];
    if (stats != null) {
      final acsubsnum = stats['acSubmissionNum'] as List<dynamic>? ?? [];
      final totalsubsnum = stats['totalSubmissionNum'] as List<dynamic>? ?? [];

      double acsubs = 0.0;
      double totalsubs = 0.0;

      for (var entry in acsubsnum) {
        if (entry['difficulty'] == 'All') {
          acsubs = (entry['submissions'] is int)
              ? (entry['submissions'] as int).toDouble()
              : entry['submissions'] ?? 0.0;
          _totalsubscount = entry['count'] ?? 0;
          break;
        }
      }

      for (var entry in totalsubsnum) {
        if (entry['difficulty'] == 'All') {
          totalsubs = (entry['submissions'] is int)
              ? (entry['submissions'] as int).toDouble()
              : entry['submissions'] ?? 0.0;
          break;
        }
      }

      if (totalsubs != 0) {
        _acrate = (acsubs / totalsubs) * 100;
      } else {
        _acrate = 0.0;
      }

      setState(() {
        _text = 'ACCEPTANCE RATE';
        _rate = '${_acrate.toStringAsFixed(2)}%';
        _subline =
            'You have solved ${_solved(acsubsnum, 'Easy')} Easy, ${_solved(acsubsnum, 'Medium')} Medium & ${_solved(acsubsnum, 'Hard')} Hard Questions.';
        _total = acsubs.toInt();
      });
    }
  }

  int _solved(List<dynamic> submissionList, String difficulty) {
    return submissionList.firstWhere(
          (item) => item['difficulty'] == difficulty,
          orElse: () => {'count': 0},
        )['count'] ??
        0;
  }

  void _load() {
    final box = Hive.box('userBox');
    setState(() {
      _id = box.get('lc-userId', defaultValue: 'Unknown User');
      final ranking = widget.data['matchedUser']?['profile']?['ranking'];
      if (ranking != null) {
        _ranking = NumberFormat.decimalPattern().format(ranking);
      } else {
        _ranking = 'N/A';
      }
    });
  }

  void _filter() {
    final history = widget.data['userContestRankingHistory'] ?? [];
    _filtered = history
        .where((contest) =>
            (contest['totalProblems'] ?? 0) > 0 &&
            (contest['problemsSolved'] ?? 0) > 0)
        .toList();
  }

  List<FlSpot> _generategraphpoints() {
    return List.generate(
      _filtered.length,
      (index) => FlSpot(
        index.toDouble(),
        (_filtered[index]['rating']?.toDouble() ?? 0.0),
      ),
    );
  }

  String _getlang() {
    final stats = widget.data['matchedUser']?['languageProblemCount'];
    if (stats != null && stats is List && stats.isNotEmpty) {
      var maxsolvedlang = stats.reduce((current, next) {
        final currsolved = current['problemsSolved'] ?? 0;
        final nextsolved = next['problemsSolved'] ?? 0;
        return currsolved > nextsolved ? current : next;
      });

      return maxsolvedlang['languageName'] ?? 'N/A';
    }
    return 'N/A';
  }

  String _mapping(String language) {
    switch (language) {
      case 'C++':
        return 'lib/assets/images/cpp.png';
      case 'Python':
        return 'lib/assets/images/py.png';
      case 'Python3':
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
    final ranking = widget.data['userContestRanking'];
    final ratingpoints = _generategraphpoints();
    final avatar = widget.data['matchedUser']?['profile']?['userAvatar'] ?? '';
    final badge = widget.data['matchedUser']?['activeBadge']?['icon'] ??
        'lib/assets/images/default-badge.png';
    final badgename =
        widget.data['matchedUser']?['activeBadge']?['displayName'] ?? 'NONE';
    final lang = _getlang();
    final langpath = _mapping(lang);

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
                      avatarurl: avatar,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _id,
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
                line: '$_totalsubscount',
                subline: 'Out of 3385\n$_ranking platform ranking',
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SubDetailsCard(
                      title: "STATS",
                      image: 'lib/assets/images/stats.png',
                      color: const Color.fromARGB(255, 243, 160, 104),
                      text: _rate,
                      rate: _text,
                      subline: _subline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: StreakCard(
                      title: "STREAK",
                      image: 'lib/assets/images/streak.png',
                      color: Color.fromARGB(255, 192, 235, 128),
                      number: '7',
                      text:
                          'Day Streak. Solve todays daily to keep you streak alive !',
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BadgeCard(
                      name: "LANGUAGE",
                      image: langpath,
                      color: const Color.fromARGB(255, 231, 149, 244),
                      content: lang,
                      subline: 'Your most preffered language is',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BadgeCard(
                      name: "BADGE",
                      image: badge,
                      color: const Color.fromARGB(255, 138, 205, 255),
                      content: badgename,
                      subline: 'Your Current Badge is',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                  child: Text(
                "CONTEST DATA",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              )),
              const SizedBox(height: 20),
              _contestats(ranking),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'PROGRESS CHART',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _graph(ratingpoints),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'CONTEST HISTORY',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _history(_filtered),
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
                      onPressed: () {
                        setState(() {
                          isleet = true;
                          iscf = false;
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

  Widget _contestats(Map<String, dynamic>? contestRanking) {
    if (contestRanking == null) return const SizedBox.shrink();

    final avatar = widget.data['matchedUser']?['profile']?['userAvatar'] ?? '';
    final ranking = contestRanking['rating'].toInt() ?? 0.0;
    final granking = contestRanking['globalRanking'] ?? 0;
    final percentage = contestRanking['topPercentage'] ?? 0;
    final total = contestRanking['totalParticipants'] ?? 0;

    return Card(
      color: const Color(0xFF2C2F3E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePic(radius: 30, avatarurl: avatar),
                const SizedBox(height: 8),
                Text(
                  'Rank # ${NumberFormat('#,###').format(granking)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$ranking Rating',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.public,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 8),
                Text(
                  'Top $percentage%',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Out of ${NumberFormat('#,###').format(total)} users',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stats(String label, dynamic value) {
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

  Widget _graph(List<FlSpot> ratingPoints) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.74,
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
                bottom: BorderSide.none,
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: ratingPoints,
                isCurved: false,
                color: Colors.blue,
                barWidth: 1,
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

  Widget _history(List<dynamic> contestHistory) {
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
