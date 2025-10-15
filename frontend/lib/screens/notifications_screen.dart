import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cheeseball/providers/notifications_provider.dart';
import 'package:cheeseball/theme/colors.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openNotificationSettings,
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificationsProvider, child) {
          final notifications = notificationsProvider.notifications;

          return Column(
            children: [
              // Quick actions
              _buildQuickActions(),
              // Notifications list
              Expanded(
                child: notifications.isEmpty
                    ? _buildEmptyNotifications()
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _buildNotificationItem(notification);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _createPriceAlert,
              icon: const Icon(Icons.add_alert),
              label: const Text('Price Alert'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _manageAlerts,
              icon: const Icon(Icons.notifications_active),
              label: const Text('My Alerts'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppTheme.neutralGray.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.neutralGray,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your notifications will appear here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutralGray,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification['type']),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(notification['title'] ?? ''),
        subtitle: Text(notification['message'] ?? ''),
        trailing: Text(
          _formatTime(notification['timestamp']),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'price_alert':
        return AppTheme.primaryBlue;
      case 'news':
        return AppTheme.secondaryBlue;
      case 'portfolio':
        return AppTheme.positiveGreen;
      case 'warning':
        return AppTheme.negativeRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'price_alert':
        return Icons.attach_money;
      case 'news':
        return Icons.article;
      case 'portfolio':
        return Icons.wallet;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _createPriceAlert() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreatePriceAlertScreen(),
    );
  }

  void _manageAlerts() {
    Navigator.pushNamed(context, '/price-alerts');
  }

  void _openNotificationSettings() {
    Navigator.pushNamed(context, '/notification-settings');
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Handle notification tap based on type
    switch (notification['type']) {
      case 'price_alert':
        // Navigate to coin detail
        break;
      case 'news':
        // Open news article
        break;
      case 'portfolio':
        // Navigate to portfolio
        break;
    }
  }
}

class CreatePriceAlertScreen extends StatefulWidget {
  const CreatePriceAlertScreen({super.key});

  @override
  _CreatePriceAlertScreenState createState() => _CreatePriceAlertScreenState();
}

class _CreatePriceAlertScreenState extends State<CreatePriceAlertScreen> {
  String _selectedCoin = 'bitcoin';
  String _condition = 'above';
  double _targetPrice = 0.0;
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Create Price Alert',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),
          // Coin selection
          DropdownButtonFormField<String>(
            value: _selectedCoin,
            items: const [
              DropdownMenuItem(value: 'bitcoin', child: Text('Bitcoin (BTC)')),
              DropdownMenuItem(value: 'ethereum', child: Text('Ethereum (ETH)')),
              DropdownMenuItem(value: 'cardano', child: Text('Cardano (ADA)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCoin = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Coin',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Condition and price
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _condition,
                  items: const [
                    DropdownMenuItem(value: 'above', child: Text('Above')),
                    DropdownMenuItem(value: 'below', child: Text('Below')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _condition = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Price (\$)',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  onChanged: (value) {
                    _targetPrice = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Active switch
          SwitchListTile(
            title: const Text('Active Alert'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
          const Spacer(),
          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Alert'),
            ),
          ),
        ],
      ),
    );
  }

  void _createAlert() {
    // Create price alert logic
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Price alert created successfully'),
        backgroundColor: AppTheme.positiveGreen,
      ),
    );
  }
}