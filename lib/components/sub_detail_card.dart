import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubDetailsCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color color;
  final String dynamicText;
  final String dynamicText2;

  const SubDetailsCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
    required this.dynamicText,
    required this.dynamicText2,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      dynamicText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      dynamicText2,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
