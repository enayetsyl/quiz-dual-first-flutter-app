import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Match State Model
/// 
/// MERN Equivalent: This is like your match/game state in Redux or Context
/// In React:
/// ```javascript
/// const MatchContext = createContext({
///   matchId: null,
///   status: 'idle', // 'idle', 'waiting', 'playing', 'finished'
///   player1: null,
///   player2: null,
///   currentQuestion: null,
/// });
/// ```
class MatchState {
  final String? matchId;
  final String status; // 'idle', 'waiting', 'playing', 'finished'
  final String? player1Id;
  final String? player2Id;
  final int? currentQuestionIndex;
  final Map<String, int>? scores; // { player1Id: 0, player2Id: 0 }
  final bool isLoading;
  final String? error;

  const MatchState({
    this.matchId,
    this.status = 'idle',
    this.player1Id,
    this.player2Id,
    this.currentQuestionIndex,
    this.scores,
    this.isLoading = false,
    this.error,
  });

  // CopyWith method - creates a new state with updated fields
  // MERN Equivalent: return { ...state, status: 'waiting' }
  MatchState copyWith({
    String? matchId,
    String? status,
    String? player1Id,
    String? player2Id,
    int? currentQuestionIndex,
    Map<String, int>? scores,
    bool? isLoading,
    String? error,
  }) {
    return MatchState(
      matchId: matchId ?? this.matchId,
      status: status ?? this.status,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      scores: scores ?? this.scores,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Match Notifier - Manages Match/Game State
/// 
/// MERN Equivalent: useReducer with matchReducer
/// In React:
/// ```javascript
/// const matchReducer = (state, action) => {
///   switch (action.type) {
///     case 'CREATE_MATCH':
///       return { ...state, matchId: action.payload, status: 'waiting' };
///     case 'PLAYER_JOINED':
///       return { ...state, player2: action.payload, status: 'playing' };
///     default:
///       return state;
///   }
/// };
/// ```
class MatchNotifier extends Notifier<MatchState> {
  @override
  MatchState build() {
    return const MatchState();
  }

  /// Create a new match
  /// 
  /// MERN Equivalent: dispatch({ type: 'CREATE_MATCH', payload: matchId })
  /// This will be implemented in Phase 7 with Firestore
  Future<void> createMatch(String playerId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement Firestore match creation in Phase 7
      // For now, simulate creating a match
      await Future.delayed(const Duration(seconds: 1));

      // Generate a demo match ID
      final matchId = 'match_${DateTime.now().millisecondsSinceEpoch}';

      // MERN Equivalent: dispatch({ type: 'CREATE_MATCH', payload: matchId })
      state = state.copyWith(
        matchId: matchId,
        status: 'waiting',
        player1Id: playerId,
        isLoading: false,
        scores: {playerId: 0},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Join an existing match
  /// 
  /// MERN Equivalent: dispatch({ type: 'JOIN_MATCH', payload: { matchId, playerId } })
  /// This will be implemented in Phase 7 with Firestore
  Future<void> joinMatch(String matchId, String playerId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement Firestore match join in Phase 7
      await Future.delayed(const Duration(seconds: 1));

      // MERN Equivalent: dispatch({ type: 'JOIN_MATCH', payload: { matchId, playerId } })
      state = state.copyWith(
        matchId: matchId,
        status: 'playing',
        player2Id: playerId,
        isLoading: false,
        scores: {
          state.player1Id ?? 'player1': 0,
          playerId: 0,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Start the game
  /// 
  /// MERN Equivalent: dispatch({ type: 'START_GAME' })
  void startGame() {
    state = state.copyWith(
      status: 'playing',
      currentQuestionIndex: 0,
    );
  }

  /// Submit an answer
  /// 
  /// MERN Equivalent: dispatch({ type: 'SUBMIT_ANSWER', payload: { playerId, answer } })
  /// This will be implemented in Phase 9 with game logic
  Future<void> submitAnswer(String playerId, String answer) async {
    // TODO: Implement answer submission logic in Phase 9
    // For now, just update the state
    final currentScores = Map<String, int>.from(state.scores ?? {});
    // Simulate correct answer (will be real logic in Phase 9)
    currentScores[playerId] = (currentScores[playerId] ?? 0) + 1;

    state = state.copyWith(scores: currentScores);
  }

  /// Reset match state
  /// 
  /// MERN Equivalent: dispatch({ type: 'RESET_MATCH' })
  void resetMatch() {
    state = const MatchState();
  }
}

/// Match Provider - The provider that exposes MatchNotifier
/// 
/// MERN Equivalent: MatchContext.Provider
/// In React:
/// ```javascript
/// export const MatchProvider = ({ children }) => {
///   const [state, dispatch] = useReducer(matchReducer, initialState);
///   return (
///     <MatchContext.Provider value={{ state, dispatch }}>
///       {children}
///     </MatchContext.Provider>
///   );
/// };
/// ```
final matchProvider = NotifierProvider<MatchNotifier, MatchState>(() {
  return MatchNotifier();
});

/// Convenience providers for specific parts of match state
/// 
/// MERN Equivalent: Selectors
/// In React: const matchId = useSelector(state => state.match.matchId);
final matchIdProvider = Provider<String?>((ref) {
  return ref.watch(matchProvider).matchId;
});

final matchStatusProvider = Provider<String>((ref) {
  return ref.watch(matchProvider).status;
});

final matchScoresProvider = Provider<Map<String, int>?>((ref) {
  return ref.watch(matchProvider).scores;
});
