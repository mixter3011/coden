import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class SubDetailsCard extends StatelessWidget {
  final String title;
  final String image;
  final Color color;
  final String text;
  final String rate;
  final String subline;

  const SubDetailsCard({
    super.key,
    required this.title,
    required this.image,
    required this.color,
    required this.text,
    required this.rate,
    required this.subline,
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
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
            const SizedBox(height: 6),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isNetworkImage)
                      Image.network(
                        image,
                        width: 60,
                        height: 60,
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
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
                          rate,
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
                          subline,
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
    );
  }
}
