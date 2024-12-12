import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String dynamicText;
  final String dynamicText2;

  const DetailsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.dynamicText,
    required this.dynamicText2,
  });

  @override
  Widget build(BuildContext context) {
    final int progressValue = int.tryParse(dynamicText) ?? 0;
    const int maxProgress = 3385;
    final double progressPercent =
        (progressValue / maxProgress).clamp(0.0, 1.0);

    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dynamicText,
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dynamicText2,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 10,
                color: Colors.black,
                backgroundColor: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
