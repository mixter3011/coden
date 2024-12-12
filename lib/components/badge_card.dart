import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgeCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color color;
  final String dynamicText;
  final String subline;

  const BadgeCard(
      {super.key,
      required this.title,
      required this.imagePath,
      required this.color,
      required this.dynamicText,
      required this.subline});

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard> {
  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        Uri.tryParse(widget.imagePath)?.hasAbsolutePath ?? false;

    return Card(
      color: widget.color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            isNetworkImage
                ? Image.network(
                    widget.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  )
                : Image.asset(
                    widget.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 2),
            Column(
              children: [
                Text(
                  widget.subline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.dynamicText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
