import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/match_provider.dart';
import '../../providers/auth_provider.dart';

/// Lobby Screen - Waiting room before game starts
/// 
/// MERN Equivalent: This is like a React page component with Context
/// In React: 
/// ```javascript
/// const Lobby = () => {
///   const { matchState } = useContext(MatchContext);
///   return <div>Lobby - Room: {matchState.matchId}</div>;
/// };
/// ```
/// In Flutter: We use ConsumerWidget to access providers
class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get match state and notifier
    // MERN Equivalent: const { matchState, loadMatch } = useContext(MatchContext);
    final matchState = ref.watch(matchProvider);
    final matchNotifier = ref.read(matchProvider.notifier);
    final authState = ref.watch(authProvider);

    // Load match data if we have a matchId but no data
    // MERN Equivalent: useEffect(() => { if (matchId) loadMatch(matchId); }, [matchId])
    if (matchState.matchId != null && matchState.status == 'idle') {
      // Load match from Firestore
      WidgetsBinding.instance.addPostFrameCallback((_) {
        matchNotifier.loadMatch(matchState.matchId!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
              // Show error if any
              if (matchState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          matchState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Show loading state
              if (matchState.isLoading) ...[
                const CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Loading room...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],

              // Show match data
              if (!matchState.isLoading && matchState.matchId != null) ...[
                // Status text
                Text(
                  matchState.status == 'waiting'
                      ? 'Waiting for Opponent...'
                      : matchState.status == 'playing'
                          ? 'Match Ready!'
                          : 'Match Status: ${matchState.status}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Room ID Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Room ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        matchState.matchId!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share this code with your friend!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Players List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Players',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Player 1
                      if (matchState.player1Id != null) ...[
                        _buildPlayerTile(
                          matchState.player1Id!,
                          matchState.player1Id == authState.userId,
                          matchState.scores?[matchState.player1Id!] ?? 0,
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Player 2
                      if (matchState.player2Id != null) ...[
                        _buildPlayerTile(
                          matchState.player2Id!,
                          matchState.player2Id == authState.userId,
                          matchState.scores?[matchState.player2Id!] ?? 0,
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.person_outline, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Waiting for player 2...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Show loading indicator if waiting
                if (matchState.status == 'waiting') ...[
                  const CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Waiting for opponent to join...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Show start game button if both players joined
                if (matchState.status == 'playing' &&
                    matchState.player1Id != null &&
                    matchState.player2Id != null) ...[
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to game screen
                      // MERN Equivalent: navigate('/game')
                      context.go('/game');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                      'Start Game',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],

              // Show message if no match
              if (!matchState.isLoading && matchState.matchId == null) ...[
                const Text(
                  'No active match',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
              
              const SizedBox(height: 20),

              // Back Button
              TextButton(
                onPressed: () {
                  // Reset match state
                  // MERN Equivalent: dispatch({ type: 'RESET_MATCH' })
                  ref.read(matchProvider.notifier).resetMatch();
                  
                  // Navigate back
                  // MERN Equivalent: navigate(-1) or navigate('/dashboard')
                  context.go('/dashboard');
                },
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a player tile widget
  /// 
  /// MERN Equivalent: <div className="player-tile">{playerId}</div>
  Widget _buildPlayerTile(String playerId, bool isCurrentUser, int score) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.deepPurple.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentUser ? Colors.deepPurple : Colors.grey.shade300,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: isCurrentUser ? Colors.deepPurple : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCurrentUser ? 'You (${playerId.substring(0, 8)}...)' : 'Player (${playerId.substring(0, 8)}...)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser ? Colors.deepPurple : Colors.black87,
              ),
            ),
          ),
          Text(
            'Score: $score',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

