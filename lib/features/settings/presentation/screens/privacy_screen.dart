import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'RoamCam Privacy Policy',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Last updated: October 2026',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          SizedBox(height: 20),
          _Section(
            title: '1. Data Collection',
            body:
                'RoamCam does NOT collect or transmit any personal data to external servers. All data — GPS photos, passport stamps, favorites, and settings — is stored locally on your device only.',
          ),
          _Section(
            title: '2. Location Data',
            body:
                'Location access is used exclusively on-device to: (a) show nearby live webcams, (b) stamp GPS coordinates on your photos, and (c) calibrate the digital compass. Your location is never uploaded or shared.',
          ),
          _Section(
            title: '3. Camera Access',
            body:
                'Camera access is used only when you open the GPS Camera tool. Photos are processed on-device and saved to your local gallery. No photos are transmitted to any external server.',
          ),
          _Section(
            title: '4. Third-Party Content',
            body:
                'Live webcam streams and thumbnails are loaded from their respective providers (e.g., Windy Webcams, Unsplash for fallback images). These providers may have their own privacy policies.',
          ),
          _Section(
            title: '5. Map Data',
            body:
                'Map tiles are provided by OpenStreetMap contributors (openstreetmap.org) under the Open Database Licence (ODbL). No user tracking is performed through map usage.',
          ),
          _Section(
            title: '6. 360° Panoramas',
            body:
                'Panoramic images are sourced from Wikimedia Commons under Creative Commons licenses. Attribution is displayed in-app in the Settings > Image Credits section.',
          ),
          _Section(
            title: '7. Contact',
            body:
                'For questions about this policy, please contact the developer through the app store listing.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.cyan, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.6)),
        ],
      ),
    );
  }
}

