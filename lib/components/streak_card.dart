import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color color;
  final String dynamicText;
  final String subline1;
  final String subline2;

  const StreakCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
    required this.dynamicText,
    required this.subline1,
    required this.subline2,
    required String dynamicText2,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = Uri.tryParse(imagePath)?.hasAbsolutePath ?? false;

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
              children: [
                if (isNetworkImage)
                  Image.network(
                    imagePath,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  )
                else
                  Image.asset(
                    imagePath,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(width: 10),
                Text(
                  dynamicText,
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      subline1,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      subline2,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
