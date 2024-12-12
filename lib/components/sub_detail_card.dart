import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubDetailsCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color color;
  final String dynamicText;
  final String dynamicText2;
  final String dynamicText3;

  const SubDetailsCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
    required this.dynamicText,
    required this.dynamicText2,
    required this.dynamicText3,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = Uri.tryParse(imagePath)?.hasAbsolutePath ?? false;

    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.only(left: 6),
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
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isNetworkImage)
                        Image.network(
                          imagePath,
                          width: 60,
                          height: 60,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dynamicText,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            dynamicText2,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Center(
                          child: Text(
                            dynamicText3,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
