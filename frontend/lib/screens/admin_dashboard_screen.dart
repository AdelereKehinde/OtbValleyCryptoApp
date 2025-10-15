import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/auth_provider.dart';
import 'package:cheeseball/services/api_service.dart';
import 'package:cheeseball/theme/app_theme.dart'; 
import 'package:cheeseball/theme/colors.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _adminStats = {};
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;

      // Load admin statistics
      final stats = await _apiService.getAdminStatistics(token);
      final users = await _apiService.getAllUsers(token);

      setState(() {
        _adminStats = stats;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading admin data: $e'),
          backgroundColor: AppTheme.negativeRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdminData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Statistics cards
                  _buildStatisticsCards(),
                  const SizedBox(height: 24),
                  // Users list
                  _buildUsersList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Users',
          _adminStats['total_users']?.toString() ?? '0',
          Icons.people,
          AppTheme.primaryBlue,
        ),
        _buildStatCard(
          'Watchlists',
          _adminStats['total_watchlists']?.toString() ?? '0',
          Icons.star,
          AppTheme.secondaryBlue,
        ),
        _buildStatCard(
          'Portfolios',
          _adminStats['total_portfolios']?.toString() ?? '0',
          Icons.wallet,
          AppTheme.accentBlue,
        ),
        _buildStatCard(
          'Active Alerts',
          _adminStats['total_alerts']?.toString() ?? '0',
          Icons.notifications,
          AppTheme.positiveGreen,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
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

  Widget _buildUsersList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Management',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            ..._users.map((user) => _buildUserItem(user)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
        child: Text(
          user['username'].toString().substring(0, 2).toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
      title: Text(user['username']),
      subtitle: Text(user['email']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            user['is_active'] ? Icons.check_circle : Icons.remove_circle,
            color: user['is_active'] ? AppTheme.positiveGreen : AppTheme.negativeRed,
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'toggle',
                child: Text('Toggle Active Status'),
              ),
              const PopupMenuItem(
                value: 'view',
                child: Text('View Details'),
              ),
            ],
            onSelected: (value) => _handleUserAction(value, user),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'toggle':
        _toggleUserStatus(user);
        break;
      case 'view':
        _viewUserDetails(user);
        break;
    }
  }

  void _toggleUserStatus(Map<String, dynamic> user) async {
    try {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;

      if (user['is_active']) {
        await _apiService.deactivateUser(user['id'], token);
      } else {
        await _apiService.activateUser(user['id'], token);
      }

      // Reload data
      _loadAdminData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${user['username']} status updated'),
          backgroundColor: AppTheme.positiveGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: AppTheme.negativeRed,
        ),
      );
    }
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User: ${user['username']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email']}'),
            Text('Status: ${user['is_active'] ? 'Active' : 'Inactive'}'),
            Text('Created: ${user['created_at']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}