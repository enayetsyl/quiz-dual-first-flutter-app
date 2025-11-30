import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

/// Dashboard Screen - Main menu after login
/// 
/// MERN Equivalent: This is like a React page component with Context
/// In React: 
/// ```javascript
/// const Dashboard = () => {
///   const { user, logout } = useContext(AuthContext);
///   return <div>Dashboard</div>;
/// };
/// ```
/// In Flutter: We use ConsumerWidget to access providers
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get auth state and notifier
    // MERN Equivalent: const { user, logout } = useContext(AuthContext);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        // Add logout button in app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Call logout method
              // MERN Equivalent: logout() -> clears token, sets user to null
              await authNotifier.logout();
              
              // Navigation will happen automatically via router redirect
              // But we can also navigate manually if needed
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to QuizDuel Lite!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Display user email if available
              // MERN Equivalent: <div>Logged in as: {user.email}</div>
              if (authState.email != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Logged in as: ${authState.email}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 40),
              
              // Create Room Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to lobby screen
                  // MERN Equivalent: navigate('/lobby')
                  context.go('/lobby');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Room',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Join Room Button (placeholder for now)
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Join Room - Coming in Phase 7!'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  side: const BorderSide(color: Colors.deepPurple, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Join Room',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Logout Button
              // MERN Equivalent: <button onClick={logout}>Logout</button>
              OutlinedButton.icon(
                onPressed: () async {
                  // Call logout method
                  // MERN Equivalent: logout() -> clears token, sets user to null
                  await authNotifier.logout();
                  
                  // Navigation will happen automatically via router redirect
                  // But we can also navigate manually if needed
                  if (context.mounted) {
                    context.go('/auth');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

