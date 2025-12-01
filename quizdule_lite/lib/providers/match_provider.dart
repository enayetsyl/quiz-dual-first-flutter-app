import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/match_model.dart';

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
  // Firestore service instance
  // MERN Equivalent: Your API service that makes HTTP requests
  final FirestoreService _firestoreService = FirestoreService();

  @override
  MatchState build() {
    return const MatchState();
  }

  /// Generate a random match ID (6 characters, alphanumeric)
  /// 
  /// MERN Equivalent: Generating a unique room code
  /// ```javascript
  /// const generateRoomId = () => {
  ///   return Math.random().toString(36).substring(2, 8).toUpperCase();
  /// };
  /// ```
  String _generateMatchId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Create a new match
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// const createMatch = async (playerId, playerEmail) => {
  ///   const matchId = generateRoomId();
  ///   const response = await axios.post('/api/matches', {
  ///     matchId,
  ///     player1: { id: playerId, email: playerEmail },
  ///   });
  ///   dispatch({ type: 'CREATE_MATCH', payload: response.data });
  /// };
  /// ```
  /// 
  /// In Flutter, we call Firestore service directly (no Express server needed!)
  Future<void> createMatch(String playerId, String playerEmail) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Generate a unique match ID
      // MERN Equivalent: const matchId = generateRoomId();
      String matchId;
      
      // Keep generating until we find a unique ID
      // MERN Equivalent: Check if room exists before creating
      do {
        matchId = _generateMatchId();
        final existingMatch = await _firestoreService.getMatch(matchId);
        // If match doesn't exist, we found a unique ID
        if (existingMatch == null) {
          break;
        }
      } while (true);

      // Create match in Firestore
      // MERN Equivalent: await axios.post('/api/matches', { matchId, player1: {...} })
      final match = await _firestoreService.createMatch(
        matchId: matchId,
        playerId: playerId,
        playerEmail: playerEmail,
      );

      // Update state with created match
      // MERN Equivalent: dispatch({ type: 'CREATE_MATCH', payload: match })
      state = state.copyWith(
        matchId: match.matchId,
        status: match.status,
        player1Id: match.player1?.id,
        player2Id: match.player2?.id,
        isLoading: false,
        scores: {
          if (match.player1 != null) match.player1!.id: match.player1!.score,
          if (match.player2 != null) match.player2!.id: match.player2!.score,
        },
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
  /// MERN Equivalent:
  /// ```javascript
  /// const joinMatch = async (matchId, playerId, playerEmail) => {
  ///   const response = await axios.patch(`/api/matches/${matchId}/join`, {
  ///     player2: { id: playerId, email: playerEmail },
  ///   });
  ///   dispatch({ type: 'JOIN_MATCH', payload: response.data });
  /// };
  /// ```
  /// 
  /// In Flutter, we call Firestore service directly
  Future<void> joinMatch(String matchId, String playerId, String playerEmail) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Join match in Firestore
      // MERN Equivalent: await axios.patch(`/api/matches/${matchId}/join`, { player2: {...} })
      final match = await _firestoreService.joinMatch(
        matchId: matchId,
        playerId: playerId,
        playerEmail: playerEmail,
      );

      // Update state with joined match
      // MERN Equivalent: dispatch({ type: 'JOIN_MATCH', payload: match })
      state = state.copyWith(
        matchId: match.matchId,
        status: match.status,
        player1Id: match.player1?.id,
        player2Id: match.player2?.id,
        isLoading: false,
        scores: {
          if (match.player1 != null) match.player1!.id: match.player1!.score,
          if (match.player2 != null) match.player2!.id: match.player2!.score,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load match from Firestore
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// const loadMatch = async (matchId) => {
  ///   const response = await axios.get(`/api/matches/${matchId}`);
  ///   dispatch({ type: 'LOAD_MATCH', payload: response.data });
  /// };
  /// ```
  Future<void> loadMatch(String matchId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get match from Firestore
      // MERN Equivalent: await axios.get(`/api/matches/${matchId}`)
      final match = await _firestoreService.getMatch(matchId);

      if (match == null) {
        throw Exception('Match not found');
      }

      // Update state with loaded match
      // MERN Equivalent: dispatch({ type: 'LOAD_MATCH', payload: match })
      state = state.copyWith(
        matchId: match.matchId,
        status: match.status,
        player1Id: match.player1?.id,
        player2Id: match.player2?.id,
        currentQuestionIndex: match.currentQuestionIndex,
        isLoading: false,
        scores: {
          if (match.player1 != null) match.player1!.id: match.player1!.score,
          if (match.player2 != null) match.player2!.id: match.player2!.score,
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
