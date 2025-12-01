import 'package:cloud_firestore/cloud_firestore.dart';

/// Match Model - Represents a quiz match/room
/// 
/// MERN Equivalent: This is like a Mongoose schema/model
/// In MERN:
/// ```javascript
/// const matchSchema = new mongoose.Schema({
///   matchId: { type: String, required: true, unique: true },
///   status: { type: String, enum: ['waiting', 'playing', 'finished'], default: 'waiting' },
///   player1: {
///     id: String,
///     email: String,
///     score: { type: Number, default: 0 },
///     hasAnswered: { type: Boolean, default: false },
///   },
///   player2: {
///     id: String,
///     email: String,
///     score: { type: Number, default: 0 },
///     hasAnswered: { type: Boolean, default: false },
///   },
///   createdAt: { type: Date, default: Date.now },
///   currentQuestionIndex: { type: Number, default: 0 },
/// });
/// ```
/// 
/// In Firestore, we don't need to define a schema upfront!
/// We just create a class that can convert to/from Firestore documents.
class MatchModel {
  final String matchId;
  final String status; // 'waiting', 'playing', 'finished'
  final PlayerInfo? player1;
  final PlayerInfo? player2;
  final DateTime createdAt;
  final int currentQuestionIndex;

  MatchModel({
    required this.matchId,
    this.status = 'waiting',
    this.player1,
    this.player2,
    DateTime? createdAt,
    this.currentQuestionIndex = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create MatchModel from Firestore document
  /// 
  /// MERN Equivalent: Match.findById(id) returns a Mongoose document
  /// In Firestore, we get a DocumentSnapshot and convert it to our model
  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MatchModel(
      matchId: doc.id, // Firestore document ID
      status: data['status'] ?? 'waiting',
      player1: data['player_1'] != null
          ? PlayerInfo.fromMap(data['player_1'] as Map<String, dynamic>)
          : null,
      player2: data['player_2'] != null
          ? PlayerInfo.fromMap(data['player_2'] as Map<String, dynamic>)
          : null,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentQuestionIndex: data['current_question_index'] ?? 0,
    );
  }

  /// Convert MatchModel to Firestore document map
  /// 
  /// MERN Equivalent: When you save with Mongoose, it converts the object to JSON
  /// In Firestore, we convert our model to a Map that Firestore understands
  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'player_1': player1?.toMap(),
      'player_2': player2?.toMap(),
      'created_at': Timestamp.fromDate(createdAt),
      'current_question_index': currentQuestionIndex,
    };
  }

  /// Check if match is ready to start (both players joined)
  /// 
  /// MERN Equivalent: match.player1 && match.player2
  bool get isReady => player1 != null && player2 != null;

  /// Check if a specific player is in this match
  /// 
  /// MERN Equivalent: match.player1.id === userId || match.player2.id === userId
  bool hasPlayer(String userId) {
    return player1?.id == userId || player2?.id == userId;
  }
}

/// Player Info - Nested data structure for players
/// 
/// MERN Equivalent: Nested object in Mongoose schema
/// ```javascript
/// player1: {
///   id: String,
///   email: String,
///   score: Number,
///   hasAnswered: Boolean,
/// }
/// ```
class PlayerInfo {
  final String id;
  final String email;
  final int score;
  final bool hasAnswered;

  PlayerInfo({
    required this.id,
    required this.email,
    this.score = 0,
    this.hasAnswered = false,
  });

  /// Create PlayerInfo from Firestore map
  /// 
  /// MERN Equivalent: Accessing nested object properties
  factory PlayerInfo.fromMap(Map<String, dynamic> map) {
    return PlayerInfo(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      score: map['score'] ?? 0,
      hasAnswered: map['has_answered'] ?? false,
    );
  }

  /// Convert PlayerInfo to Firestore map
  /// 
  /// MERN Equivalent: Creating nested object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'score': score,
      'has_answered': hasAnswered,
    };
  }

  /// Create a copy with updated fields
  /// 
  /// MERN Equivalent: { ...player1, score: 5 }
  PlayerInfo copyWith({
    String? id,
    String? email,
    int? score,
    bool? hasAnswered,
  }) {
    return PlayerInfo(
      id: id ?? this.id,
      email: email ?? this.email,
      score: score ?? this.score,
      hasAnswered: hasAnswered ?? this.hasAnswered,
    );
  }
}

