import 'package:coden/screens/cflogin_screen.dart';
import 'package:coden/screens/lclogin_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232530),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CODEN',
                style: GoogleFonts.poppins(
                  fontSize: 48.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please select your preferred Platform',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildPlatformButton(
                context,
                imagePath: 'lib/assets/images/lc.webp',
                label: 'LeetCode',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LCLoginScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildPlatformButton(
                context,
                imagePath: 'lib/assets/images/cf.webp',
                label: 'CodeForces',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CFLoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformButton(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
