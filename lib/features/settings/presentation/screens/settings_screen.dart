import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useMiles = false;
  String _language = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info
          _SectionHeader(title: 'Preferences'),
          _SettingsTile(
            icon: Icons.language_rounded,
            color: AppColors.cyan,
            title: 'Language',
            trailing: DropdownButton<String>(
              value: _language,
              dropdownColor: AppColors.surfaceCard,
              underline: const SizedBox(),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              ],
              onChanged: (v) => setState(() => _language = v!),
            ),
          ),
          _SettingsTile(
            icon: Icons.straighten_rounded,
            color: AppColors.emerald,
            title: 'Distance Unit',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_useMiles ? 'Miles' : 'Kilometers',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(width: 8),
                Switch(
                  value: _useMiles,
                  activeColor: AppColors.cyan,
                  onChanged: (v) => setState(() => _useMiles = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            color: AppColors.purpleGlow,
            title: 'Privacy Policy',
            onTap: () => context.push('/privacy'),
          ),
          _SettingsTile(
            icon: Icons.info_rounded,
            color: AppColors.hotOrange,
            title: 'Version',
            trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
          _SettingsTile(
            icon: Icons.credit_card_rounded,
            color: AppColors.textSecondary,
            title: 'Image Credits',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surfaceCard,
                  title: const Text('Image Credits', style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text(
                    'Webcam thumbnails: Unsplash.com (free license)\n'
                    '360° panoramas: Wikimedia Commons (CC BY-SA)\n'
                    'Map tiles: OpenStreetMap contributors (ODbL)\n\n'
                    'No Google Street View or branded assets are used.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close', style: TextStyle(color: AppColors.cyan)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.cyan,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

