import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class UserStateDebugWidget extends ConsumerStatefulWidget {
  const UserStateDebugWidget({super.key});

  @override
  ConsumerState<UserStateDebugWidget> createState() => _UserStateDebugWidgetState();
}

class _UserStateDebugWidgetState extends ConsumerState<UserStateDebugWidget> {
  String _debugInfo = '';
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkUserState();
  }

  Future<void> _checkUserState() async {
    final info = StringBuffer();
    
    try {
      // Check SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      info.writeln('SharedPreferences user data:');
      info.writeln(userJson ?? 'null');
      info.writeln('');
      
      // Check AuthService
      final authUser = await _authService.getCurrentUser();
      info.writeln('AuthService getCurrentUser():');
      info.writeln(authUser?.toString() ?? 'null');
      info.writeln('');
      
      // Check if authenticated
      final isAuth = await _authService.isAuthenticated();
      info.writeln('AuthService isAuthenticated(): $isAuth');
      info.writeln('');
      
      // Check provider state
      final userState = ref.read(userProvider);
      info.writeln('Provider state:');
      info.writeln('  User: ${userState.user?.toString() ?? 'null'}');
      info.writeln('  Loading: ${userState.isLoading}');
      info.writeln('  Error: ${userState.error ?? 'null'}');
      info.writeln('  IsLoggedIn: ${userState.isLoggedIn}');
      
    } catch (e) {
      info.writeln('Error checking user state: $e');
    }
    
    setState(() {
      _debugInfo = info.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User State Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkUserState,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Provider State
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Provider State',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('User: ${userState.user?.fullDisplayName ?? 'null'}'),
                    Text('User ID: ${userState.user?.userId ?? 'null'}'),
                    Text('Loading: ${userState.isLoading}'),
                    Text('Error: ${userState.error ?? 'null'}'),
                    Text('Is Logged In: ${userState.isLoggedIn}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(userProvider.notifier).login('bob_jones', 'testpass123');
                            _checkUserState();
                          },
                          child: const Text('Test Login'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(userProvider.notifier).logout();
                            _checkUserState();
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(userProvider.notifier).reloadUserFromStorage();
                            _checkUserState();
                          },
                          child: const Text('Reload from Storage'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(userProvider.notifier).refreshUser();
                            _checkUserState();
                          },
                          child: const Text('Refresh from API'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Debug Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _debugInfo.isEmpty ? 'Loading...' : _debugInfo,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
