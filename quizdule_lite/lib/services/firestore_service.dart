import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

/// Firestore Service - Handles all Firestore CRUD operations
/// 
/// MERN Equivalent: Your Express API routes that interact with MongoDB
/// In MERN:
/// ```javascript
/// // Express routes (server.js)
/// app.post('/api/matches', async (req, res) => {
///   const match = await Match.create({
///     matchId: generateId(),
///     status: 'waiting',
///     player1: req.body.player1,
///   });
///   res.json(match);
/// });
/// 
/// app.get('/api/matches/:matchId', async (req, res) => {
///   const match = await Match.findById(req.params.matchId);
///   res.json(match);
/// });
/// 
/// app.patch('/api/matches/:matchId/join', async (req, res) => {
///   const match = await Match.findByIdAndUpdate(
///     req.params.matchId,
///     { player2: req.body.player2 },
///     { new: true }
///   );
///   res.json(match);
/// });
/// ```
/// 
/// In Flutter with Firestore:
/// - No Express server needed!
/// - Direct client-to-database communication
/// - Firestore handles all the backend logic
class FirestoreService {
  // Firestore instance
  // MERN Equivalent: Your MongoDB connection (mongoose)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new match/room
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// const match = await Match.create({
  ///   matchId: generateId(),
  ///   status: 'waiting',
  ///   player1: { id: userId, email: userEmail, score: 0 },
  ///   createdAt: new Date(),
  /// });
  /// ```
  /// 
  /// In Firestore, we generate an ID and create a document
  Future<MatchModel> createMatch({
    required String matchId,
    required String playerId,
    required String playerEmail,
  }) async {
    try {
      // Create match document
      // MERN Equivalent: await Match.create({ ... })
      final matchData = {
        'status': 'waiting',
        'player_1': {
          'id': playerId,
          'email': playerEmail,
          'score': 0,
          'has_answered': false,
        },
        'player_2': null, // Will be set when player 2 joins
        'created_at': FieldValue.serverTimestamp(),
        'current_question_index': 0,
      };

      // Set the document with the provided matchId
      // MERN Equivalent: Match.create({ _id: matchId, ... })
      await _firestore.collection('matches').doc(matchId).set(matchData);

      print('✅ Match created in Firestore: $matchId');

      // Return the created match
      // MERN Equivalent: return match (Mongoose returns the created document)
      final doc = await _firestore.collection('matches').doc(matchId).get();
      return MatchModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error creating match: $e');
      rethrow; // Re-throw so caller can handle the error
    }
  }

  /// Get a match by ID
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// const match = await Match.findById(matchId);
  /// if (!match) throw new Error('Match not found');
  /// return match;
  /// ```
  /// 
  /// In Firestore, we get a document by ID
  Future<MatchModel?> getMatch(String matchId) async {
    try {
      // Get document by ID
      // MERN Equivalent: await Match.findById(matchId)
      final doc = await _firestore.collection('matches').doc(matchId).get();

      // Check if document exists
      // MERN Equivalent: if (!match) return null;
      if (!doc.exists) {
        print('⚠️ Match not found: $matchId');
        return null;
      }

      // Convert Firestore document to MatchModel
      // MERN Equivalent: Mongoose automatically converts to your model
      return MatchModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting match: $e');
      rethrow;
    }
  }

  /// Join an existing match (add player 2)
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// const match = await Match.findById(matchId);
  /// if (!match) throw new Error('Match not found');
  /// if (match.player2) throw new Error('Match is full');
  /// 
  /// match.player2 = { id: playerId, email: playerEmail, score: 0 };
  /// match.status = 'playing';
  /// await match.save();
  /// return match;
  /// ```
  /// 
  /// In Firestore, we update the document
  Future<MatchModel> joinMatch({
    required String matchId,
    required String playerId,
    required String playerEmail,
  }) async {
    try {
      // First, check if match exists and is available
      // MERN Equivalent: const match = await Match.findById(matchId);
      final match = await getMatch(matchId);
      
      if (match == null) {
        throw Exception('Match not found');
      }

      // Check if match is already full
      // MERN Equivalent: if (match.player2) throw new Error('Match is full');
      if (match.player2 != null) {
        throw Exception('Match is already full');
      }

      // Check if player is trying to join their own match
      // MERN Equivalent: if (match.player1.id === playerId) throw new Error('Cannot join own match');
      if (match.player1?.id == playerId) {
        throw Exception('Cannot join your own match');
      }

      // Update match document with player 2
      // MERN Equivalent: await Match.findByIdAndUpdate(matchId, { player2: {...}, status: 'playing' })
      await _firestore.collection('matches').doc(matchId).update({
        'player_2': {
          'id': playerId,
          'email': playerEmail,
          'score': 0,
          'has_answered': false,
        },
        'status': 'playing',
      });

      print('✅ Player joined match: $matchId');

      // Return updated match
      // MERN Equivalent: return updated match
      final updatedDoc = await _firestore.collection('matches').doc(matchId).get();
      return MatchModel.fromFirestore(updatedDoc);
    } catch (e) {
      print('❌ Error joining match: $e');
      rethrow;
    }
  }

  /// Find available matches (matches waiting for a player)
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// const matches = await Match.find({
  ///   status: 'waiting',
  ///   player2: null,
  /// }).limit(10);
  /// ```
  /// 
  /// In Firestore, we query the collection
  Future<List<MatchModel>> findAvailableMatches({int limit = 10}) async {
    try {
      // Query Firestore collection
      // MERN Equivalent: await Match.find({ status: 'waiting', player2: null })
      final querySnapshot = await _firestore
          .collection('matches')
          .where('status', isEqualTo: 'waiting')
          .where('player_2', isEqualTo: null)
          .limit(limit)
          .get();

      // Convert query results to MatchModel list
      // MERN Equivalent: Mongoose returns array of documents
      return querySnapshot.docs
          .map((doc) => MatchModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error finding available matches: $e');
      rethrow;
    }
  }

  /// Update match document
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// await Match.findByIdAndUpdate(matchId, updateData, { new: true });
  /// ```
  /// 
  /// In Firestore, we update specific fields
  Future<void> updateMatch(String matchId, Map<String, dynamic> updateData) async {
    try {
      // Update document
      // MERN Equivalent: await Match.findByIdAndUpdate(matchId, updateData)
      await _firestore.collection('matches').doc(matchId).update(updateData);
      print('✅ Match updated: $matchId');
    } catch (e) {
      print('❌ Error updating match: $e');
      rethrow;
    }
  }

  /// Delete a match
  /// 
  /// MERN Equivalent:
  /// ```javascript
  /// await Match.findByIdAndDelete(matchId);
  /// ```
  /// 
  /// In Firestore, we delete the document
  Future<void> deleteMatch(String matchId) async {
    try {
      // Delete document
      // MERN Equivalent: await Match.findByIdAndDelete(matchId)
      await _firestore.collection('matches').doc(matchId).delete();
      print('✅ Match deleted: $matchId');
    } catch (e) {
      print('❌ Error deleting match: $e');
      rethrow;
    }
  }

  /// Listen to match document changes in real-time
  /// 
  /// MERN Equivalent: Socket.io listener
  /// ```javascript
  /// // Socket.io (Node.js + Client)
  /// socket.on('matchUpdate', (data) => {
  ///   // Handle update
  ///   setMatch(data);
  /// });
  /// 
  /// // On server, you'd emit:
  /// socket.emit('matchUpdate', matchData);
  /// ```
  /// 
  /// In Firestore, we use snapshots() which automatically listens to changes!
  /// No backend code needed - Firestore handles the real-time sync.
  /// 
  /// Key differences:
  /// - Socket.io: Requires server to emit events manually
  /// - Firestore: Automatically syncs when document changes (anywhere!)
  /// - Socket.io: Need to handle reconnection manually
  /// - Firestore: Automatically reconnects
  /// - Socket.io: Need to manage socket connections
  /// - Firestore: Just listen to the stream, dispose when done
  Stream<MatchModel?> watchMatch(String matchId) {
    // Return a stream that emits MatchModel whenever the document changes
    // MERN Equivalent: socket.on('matchUpdate', handler)
    return _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots() // This creates a stream that fires on EVERY document change!
        .map((snapshot) {
      // Convert Firestore snapshot to MatchModel
      // MERN Equivalent: Processing the data from socket event
      if (!snapshot.exists) {
        print('⚠️ Match document deleted: $matchId');
        return null;
      }
      
      try {
        return MatchModel.fromFirestore(snapshot);
      } catch (e) {
        print('❌ Error parsing match from stream: $e');
        return null;
      }
    });
  }
}

