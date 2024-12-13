import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class StreakCard extends StatelessWidget {
  final String title;
  final String image;
  final Color color;
  final String number;
  final String text;

  const StreakCard({
    super.key,
    required this.title,
    required this.image,
    required this.color,
    required this.number,
    required this.text,
  });

  Future<void> _navigate(BuildContext context) async {
    final box = await Hive.openBox('userBox');
    final username = box.get('lc-userId', defaultValue: 'Unknown User');

    final url = 'https://leetcode.com/u/$username/';

    try {
      final Uri parsedUrl = Uri.parse(url);

      if (await canLaunchUrl(parsedUrl)) {
        await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open LeetCode profile')),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = Uri.tryParse(image)?.hasAbsolutePath ?? false;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.upload_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => _navigate(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNetworkImage)
                      Image.network(
                        image,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, color: Colors.red);
                        },
                      )
                    else
                      Image.asset(
                        image,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        number,
                        style: GoogleFonts.poppins(
                          fontSize: 44,
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
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
