import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_info_widget.dart';
import '../../utils/theme.dart';

class UserProviderDemo extends ConsumerWidget {
  const UserProviderDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch different aspects of the user state
    final userState = ref.watch(userProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final isLoading = ref.watch(userLoadingProvider);
    final error = ref.watch(userErrorProvider);
    final displayName = ref.watch(userDisplayNameProvider);
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Provider Demo'),
        actions: [
          // User status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: UserStatusWidget(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Widget Demo
            Text(
              'User Info Widget',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (isLoggedIn) ...[
              UserInfoWidget(
                showFullInfo: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User info tapped!')),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // User Avatar Demo
              Text(
                'User Avatar Widget',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  UserAvatarWidget(radius: 20),
                  const SizedBox(width: 16),
                  UserAvatarWidget(radius: 30),
                  const SizedBox(width: 16),
                  UserAvatarWidget(radius: 40),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Provider State Demo
            Text(
              'Provider State Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStateRow('Is Logged In', isLoggedIn.toString()),
                    _buildStateRow('Is Loading', isLoading.toString()),
                    _buildStateRow('Display Name', displayName),
                    _buildStateRow('User ID', userId ?? 'null'),
                    _buildStateRow('Error', error ?? 'null'),
                    _buildStateRow('User Object', currentUser != null ? 'Available' : 'null'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Text(
              'Provider Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (isLoggedIn) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    ref.read(userProvider.notifier).refreshUser();
                  },
                  child: isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Refresh User Data'),
                ),
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    ref.read(userProvider.notifier).logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to login screen
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text('Go to Login'),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Error Handling Demo
            if (error != null) ...[
              Text(
                'Error Handling',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: AppTheme.errorColor),
                        const SizedBox(width: 8),
                        Text(
                          'Error',
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(error),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(userProvider.notifier).clearError();
                      },
                      child: const Text('Clear Error'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
