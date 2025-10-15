import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/auth_provider.dart';
import 'package:cheeseball/theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return ListView(
            children: [
              // Profile header
              _buildProfileHeader(user),
              // Statistics
              _buildStatistics(),
              // Settings sections
              _buildSettingsSections(),
              // App info
              _buildAppInfo(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.8),
            AppTheme.secondaryBlue.withOpacity(0.9),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              user?['username']?.toString().substring(0, 2).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?['username'] ?? 'User',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            user?['email'] ?? 'user@example.com',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileStat('Portfolio', '\$12,456.78'),
              _buildProfileStat('Watchlist', '15 coins'),
              _buildProfileStat('Alerts', '3 active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('Total Trades', '47', Icons.swap_horiz),
              _buildStatCard('Win Rate', '68%', Icons.emoji_events),
              _buildStatCard('Avg. Return', '+12.5%', Icons.trending_up),
              _buildStatCard('Active Since', '2024', Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryBlue),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGray,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSections() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _buildSettingsItem(
                  Icons.wallet,
                  'Portfolio Settings',
                  'Manage your investment portfolio',
                  () => Navigator.pushNamed(context, '/portfolio-settings'),
                ),
                _buildSettingsItem(
                  Icons.notifications,
                  'Notification Settings',
                  'Configure alerts and notifications',
                  () => Navigator.pushNamed(context, '/notification-settings'),
                ),
                _buildSettingsItem(
                  Icons.security,
                  'Privacy & Security',
                  'Manage your account security',
                  () => Navigator.pushNamed(context, '/privacy-settings'),
                ),
                _buildSettingsItem(
                  Icons.payment,
                  'Payment Methods',
                  'Add or remove payment methods',
                  () => Navigator.pushNamed(context, '/payment-methods'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAppInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            _buildSettingsItem(
              Icons.help_outline,
              'Help & Support',
              'Get help using CheeseBall',
              () => Navigator.pushNamed(context, '/help'),
            ),
            _buildSettingsItem(
              Icons.info_outline,
              'About CheeseBall',
              'App version and information',
              () => Navigator.pushNamed(context, '/about'),
            ),
            _buildSettingsItem(
              Icons.logout,
              'Sign Out',
              'Sign out of your account',
              _signOut,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  void _buildSettingsItem(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.negativeRed : AppTheme.primaryBlue),
      title: Text(
        title,
        style: isDestructive ? TextStyle(color: AppTheme.negativeRed) : null,
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _editProfile() {
    Navigator.pushNamed(context, '/edit-profile');
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.negativeRed),
            ),
          ),
        ],
      ),
    );
  }
}