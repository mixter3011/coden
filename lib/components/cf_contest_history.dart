import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CFContestHistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const CFContestHistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'\d+$');
    final match = regex.firstMatch(title);
    final contestnum = match != null ? match.group(0) : '';
    final main =
        contestnum != null ? title.replaceAll(contestnum, '').trim() : title;

    String? image;
    if (main.contains('Weekly')) {
      image = 'lib/assets/images/weekly.png';
    } else if (main.toLowerCase().contains('biweekly')) {
      image = 'lib/assets/images/biweekly.png';
    }

    return Card(
      color: const Color(0xFF2C2F3E),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'lib/assets/images/cf.webp',
                height: 2,
                width: 2,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    main.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (contestnum != null && contestnum.isNotEmpty)
            Container(
              width: 80,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              alignment: Alignment.center,
            ),
        ],
      ),
    );
  }
}
