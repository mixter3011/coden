import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String line;
  final String subline;

  const DetailsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.line,
    required this.subline,
  });

  Future<void> _navigate() async {
    final box = await Hive.openBox('userBox');
    final username = box.get('lc-userId', defaultValue: 'Unknow User');

    final url = 'https://leetcode.com/u/$username/';

    try {
      final Uri parsedUrl = Uri.parse(url);

      if (await canLaunchUrl(parsedUrl)) {
        await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');

        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Cannot open LeetCode profile')));
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int progress = int.tryParse(line) ?? 0;
    const int max = 3385;
    final double ppercent = (progress / max).clamp(0.0, 1.0);

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
                      onPressed: _navigate,
                    ),
                  ),
                ),
              ],
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
                      line,
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      subline,
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
                value: ppercent,
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
