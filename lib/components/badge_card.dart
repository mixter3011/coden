import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class BadgeCard extends StatefulWidget {
  final String name;
  final String image;
  final Color color;
  final String content;
  final String subline;

  const BadgeCard(
      {super.key,
      required this.name,
      required this.image,
      required this.color,
      required this.content,
      required this.subline});

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard> {
  Future<void> _navigateToLeetCode(BuildContext context) async {
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
            const SnackBar(content: Text('Cannot open LeetCode profile')));
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final check = Uri.tryParse(widget.image)?.hasAbsolutePath ?? false;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.name,
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
                      onPressed: () => _navigateToLeetCode(context),
                    ),
                  ),
                ),
              ],
            ),
            check
                ? Image.network(
                    widget.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  )
                : Image.asset(
                    widget.image,
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
                  widget.content,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
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
