import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContestHistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const ContestHistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'\d+$');
    final match = regex.firstMatch(title);
    final contestNumber = match != null ? match.group(0) : '';
    final mainTitle = contestNumber != null
        ? title.replaceAll(contestNumber, '').trim()
        : title;

    String? imagePath;
    if (mainTitle.contains('Weekly')) {
      imagePath = 'lib/assets/images/weekly.png';
    } else if (mainTitle.toLowerCase().contains('biweekly')) {
      imagePath = 'lib/assets/images/biweekly.png';
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
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: imagePath != null
                ? ClipOval(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainTitle.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
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
          if (contestNumber != null && contestNumber.isNotEmpty)
            Container(
              width: 80,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Text(
                    contestNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.white,
                    ),
                  ),
                  Text(
                    contestNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C2F3E),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
