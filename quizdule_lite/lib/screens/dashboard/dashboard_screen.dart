import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';

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
    
    // Get match state and notifier
    // MERN Equivalent: const { matchState, createMatch, joinMatch } = useContext(MatchContext);
    final matchState = ref.watch(matchProvider);
    final matchNotifier = ref.read(matchProvider.notifier);
    
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
              // MERN Equivalent: <button onClick={handleCreateRoom}>Create Room</button>
              ElevatedButton(
                onPressed: matchState.isLoading
                    ? null
                    : () async {
                        // Get current user info
                        if (authState.userId == null || authState.email == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login first'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Create match in Firestore
                        // MERN Equivalent: await createMatch(userId, userEmail)
                        await matchNotifier.createMatch(
                          authState.userId!,
                          authState.email!,
                        );

                        // Check if there was an error
                        if (matchState.error != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${matchState.error}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Navigate to lobby screen
                        // MERN Equivalent: navigate('/lobby')
                        if (context.mounted) {
                          context.go('/lobby');
                        }
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
                child: matchState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Room',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Join Room Button
              // MERN Equivalent: <button onClick={showJoinRoomDialog}>Join Room</button>
              OutlinedButton(
                onPressed: matchState.isLoading
                    ? null
                    : () {
                        // Show dialog to enter room ID
                        // MERN Equivalent: const roomId = prompt('Enter Room ID');
                        _showJoinRoomDialog(context, ref);
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

  /// Show dialog to join a room
  /// 
  /// MERN Equivalent: const roomId = prompt('Enter Room ID');
  /// In Flutter, we use showDialog to show a modal dialog
  void _showJoinRoomDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController roomIdController = TextEditingController();
    final authState = ref.read(authProvider);
    final matchNotifier = ref.read(matchProvider.notifier);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Join Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the Room ID to join:'),
              const SizedBox(height: 16),
              TextField(
                controller: roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Room ID',
                  hintText: 'ABC123',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final roomId = roomIdController.text.trim().toUpperCase();

                if (roomId.isEmpty || roomId.length != 6) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 6-character Room ID'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Close dialog first
                Navigator.of(dialogContext).pop();

                // Get current user info
                if (authState.userId == null || authState.email == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login first'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Join match in Firestore
                // MERN Equivalent: await joinMatch(roomId, userId, userEmail)
                await matchNotifier.joinMatch(
                  roomId,
                  authState.userId!,
                  authState.email!,
                );

                // Check if there was an error
                final matchState = ref.read(matchProvider);
                if (matchState.error != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${matchState.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Navigate to lobby screen
                // MERN Equivalent: navigate('/lobby')
                if (context.mounted) {
                  context.go('/lobby');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }
}

