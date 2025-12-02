import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';

/// Game Over Screen - Shows final results
///
/// MERN Equivalent: React page that reads from Auth + Match Context:
/// ```javascript
/// const { authState } = useContext(AuthContext);
/// const { matchState } = useContext(MatchContext);
/// const yourScore = matchState.scores[authState.userId];
/// const opponentScore = ...;
/// ```
class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final matchState = ref.watch(matchProvider);

    final userId = authState.userId;
    final scores = matchState.scores ?? {};

    int yourScore = 0;
    int opponentScore = 0;

    if (userId != null && scores.isNotEmpty) {
      yourScore = scores[userId] ?? 0;

      final opponentEntry = scores.entries.firstWhere(
        (entry) => entry.key != userId,
        orElse: () => const MapEntry('', 0),
      );
      opponentScore = opponentEntry.value;
    }

    String resultText;
    Color resultColor;

    if (yourScore > opponentScore) {
      resultText = 'You Won! 🎉';
      resultColor = Colors.green;
    } else if (yourScore < opponentScore) {
      resultText = 'You Lost 😢';
      resultColor = Colors.redAccent;
    } else {
      resultText = 'It\'s a Tie 🤝';
      resultColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
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
              // Result Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Game Over!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Final Scores
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          '$yourScore',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Opponent',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          '$opponentScore',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                resultText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Play Again Button
              ElevatedButton(
                onPressed: () {
                  // Navigate back to dashboard
                  // MERN Equivalent: navigate('/dashboard')
                  context.go('/dashboard');
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
                  'Play Again',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Back to Dashboard Button
              TextButton(
                onPressed: () {
                  // Navigate to dashboard
                  // MERN Equivalent: navigate('/dashboard')
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
}

