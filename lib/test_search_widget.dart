import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'models/user.dart';

class TestSearchWidget extends StatefulWidget {
  const TestSearchWidget({super.key});

  @override
  State<TestSearchWidget> createState() => _TestSearchWidgetState();
}

class _TestSearchWidgetState extends State<TestSearchWidget> {
  final _authService = AuthService();
  final _controller = TextEditingController();
  List<User> _results = [];
  bool _isLoading = false;

  Future<void> _testSearch(String query) async {
    if (query.length < 2) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _authService.searchUsers(query);
      setState(() {
        _results = users;
        _isLoading = false;
      });
      print('✅ Found ${users.length} users');
    } catch (e) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      print('❌ Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search Users',
                suffixIcon: _isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.search),
              ),
              onChanged: _testSearch,
            ),
            const SizedBox(height: 16),
            Text('Results: ${_results.length}'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  return ListTile(
                    title: Text(user.fullDisplayName),
                    subtitle: Text('@${user.username} - ${user.userId}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
