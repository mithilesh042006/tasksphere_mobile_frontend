import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/providers/user_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TestApp(),
    ),
  );
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Provider Test',
      home: const TestScreen(),
    );
  }
}

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final displayName = ref.watch(userDisplayNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Provider Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Is Logged In: $isLoggedIn'),
            Text('Display Name: $displayName'),
            Text('Loading: ${userState.isLoading}'),
            Text('Error: ${userState.error ?? 'None'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ref.read(userProvider.notifier).login('bob_jones', 'testpass123');
              },
              child: const Text('Test Login'),
            ),
          ],
        ),
      ),
    );
  }
}
