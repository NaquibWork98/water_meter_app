import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';  // ✅ ADD THIS IMPORT
import '../../../authentication/presentation/bloc/auth_state.dart';  // ✅ ADD THIS IMPORT
import '../../../authentication/presentation/pages/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String userName = 'User';
            String userEmail = 'user@example.com';

            if (state is AuthAuthenticated) {
              userName = state.user.name;
              userEmail = state.user.email;
            }

            return ListView(
              children: [
                // User Profile Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // General Settings
                _buildSectionHeader('General'),
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications settings coming soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language settings coming soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  subtitle: 'Light mode',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme settings coming soon'),
                      ),
                    );
                  },
                ),

                // Account Settings
                _buildSectionHeader('Account'),
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile coming soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Change password coming soon'),
                      ),
                    );
                  },
                ),

                // App Information
                _buildSectionHeader('About'),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About App',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Meter Reading App',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),  // ✅ FIXED
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: AppTheme.primaryBlue,
                          size: 32,
                        ),
                      ),
                      children: [
                        const Text(
                          'A Flutter application for automating water meter reading and billing for commercial buildings.',
                        ),
                      ],
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy policy coming soon'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of service coming soon'),
                      ),
                    );
                  },
                ),

                // Logout
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLight,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),  // ✅ FIXED
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textLight,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textLight,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}