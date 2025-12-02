import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';

/// Simple question model (local, hardcoded)
///
/// MERN Equivalent: A plain JS object in a `questions.js` file.
class _Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  const _Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

/// Hardcoded questions list for Phase 9
///
/// MERN Equivalent: `const QUESTIONS = [...]` imported by your React `Game` page.
const List<_Question> _questions = [
  _Question(
    text: 'What is the capital of France?',
    options: ['Paris', 'London', 'Berlin', 'Madrid'],
    correctIndex: 0,
  ),
  _Question(
    text: 'Which language is used to write Flutter apps?',
    options: ['JavaScript', 'Dart', 'Kotlin', 'Swift'],
    correctIndex: 1,
  ),
  _Question(
    text: 'Which database is used in this project?',
    options: ['MongoDB', 'MySQL', 'Firestore', 'PostgreSQL'],
    correctIndex: 2,
  ),
];

/// Game Screen - The actual quiz game
///
/// MERN Equivalent: React page component with Context + timers:
/// - Reads `authState` + `matchState` (like useContext)
/// - Uses setInterval for a per-question countdown
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  static const int _questionDurationSeconds = 10;

  Timer? _timer;
  int _secondsLeft = _questionDurationSeconds;
  bool _hasAnsweredThisRound = false;
  int? _lastQuestionIndex;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer({
    required int questionIndex,
    required String? userId,
  }) {
    _timer?.cancel();
    _secondsLeft = _questionDurationSeconds;
    _hasAnsweredThisRound = false;
    _lastQuestionIndex = questionIndex;

    if (userId == null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 0) {
        timer.cancel();

        // Auto-submit "wrong" answer if user hasn't answered yet.
        if (!_hasAnsweredThisRound) {
          ref.read(matchProvider.notifier).submitAnswer(
                playerId: userId,
                isCorrect: false,
              );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read auth + match state
    final authState = ref.watch(authProvider);
    final matchState = ref.watch(matchProvider);

    final userId = authState.userId;
    final scores = matchState.scores ?? {};

    // Derive current question index from match state (fallback to 0)
    final currentIndex = (matchState.currentQuestionIndex ?? 0)
        .clamp(0, _questions.length - 1);
    final currentQuestion = _questions[currentIndex];

    // (Re)start timer when question index changes
    if (_lastQuestionIndex != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer(questionIndex: currentIndex, userId: userId);
      });
    }

    // Navigate to game over when match finishes
    if (matchState.status == 'finished') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/gameover');
        }
      });
    }

    // Compute scores for "You" and "Opponent"
    int yourScore = 0;
    int opponentScore = 0;

    if (userId != null && scores.isNotEmpty) {
      yourScore = scores[userId] ?? 0;

      // Find opponent: any other key in the scores map
      final opponentEntry = scores.entries.firstWhere(
        (entry) => entry.key != userId,
        orElse: () => const MapEntry('', 0),
      );
      opponentScore = opponentEntry.value;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Duel'),
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
              // Score Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$yourScore',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Opponent',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$opponentScore',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Question Card (driven by matchState + hardcoded list)
              Container(
                padding: const EdgeInsets.all(24),
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
                        Text(
                          'Question ${currentIndex + 1} of ${_questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_secondsLeft s',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Answer Options (now wired to submitAnswer via MatchNotifier)
                    ...List.generate(currentQuestion.options.length, (index) {
                      final answer = currentQuestion.options[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              if (_hasAnsweredThisRound) return;

                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You must be logged in to answer.'),
                                  ),
                                );
                                return;
                              }

                              final isCorrect =
                                  index == currentQuestion.correctIndex;

                              setState(() {
                                _hasAnsweredThisRound = true;
                              });

                              // MERN Equivalent:
                              // await axios.patch('/api/matches/:id/answer', { playerId, isCorrect })
                              ref.read(matchProvider.notifier).submitAnswer(
                                    playerId: userId,
                                    isCorrect: isCorrect,
                                  );
                            },
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Colors.deepPurple,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              answer,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const SizedBox(height: 8),

              const Text(
                'You have 10 seconds per question. If you don\'t answer in time,\nwe auto-submit a wrong answer for you.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
