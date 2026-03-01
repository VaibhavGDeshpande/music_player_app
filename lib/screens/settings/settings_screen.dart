import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: profileAsync.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 32),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white24,
                  backgroundImage: profile.profileImageUrl != null
                      ? CachedNetworkImageProvider(profile.profileImageUrl!)
                      : null,
                  child: profile.profileImageUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              profile.displayName ?? 'Spotify User',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 48),

            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildProfileCard(
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFF1DB954),
                    title: 'Country',
                    value: 'IN', // Placeholder or use profile.country
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    icon: Icons.star_border,
                    iconColor: const Color(0xFF1DB954),
                    title: 'Subscription',
                    value: 'PREMIUM', // Placeholder
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    icon: Icons.fingerprint,
                    iconColor: const Color(0xFF1DB954),
                    title: 'Spotify ID',
                    value: profile.spotifyUserId ?? 'Unknown',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48), // Replaced Spacer with fixed space
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text(
                            'Log Out',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref.read(authProvider.notifier).logout();
                          },
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Unable to load profile')),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
