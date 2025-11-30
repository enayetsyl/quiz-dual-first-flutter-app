import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication Service
/// 
/// MERN Equivalent: Your Express authentication routes
/// In MERN, you'd have:
/// ```javascript
/// // Express routes (server.js)
/// app.post('/register', async (req, res) => {
///   const { email, password } = req.body;
///   const hashedPassword = await bcrypt.hash(password, 10);
///   const user = await User.create({ email, password: hashedPassword });
///   const token = jwt.sign({ id: user._id }, SECRET);
///   res.json({ token, user });
/// });
/// 
/// app.post('/login', async (req, res) => {
///   const { email, password } = req.body;
///   const user = await User.findOne({ email });
///   const isValid = await bcrypt.compare(password, user.password);
///   if (!isValid) throw new Error('Invalid credentials');
///   const token = jwt.sign({ id: user._id }, SECRET);
///   res.json({ token, user });
/// });
/// ```
/// 
/// In Flutter with Firebase Auth:
/// - Firebase handles password hashing automatically
/// - Firebase handles token generation automatically
/// - Firebase handles token storage automatically
/// - We just call the methods and Firebase does the rest!
class AuthService {
  // Firebase Auth instance
  // MERN Equivalent: Your Express app with authentication middleware
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Firestore instance
  // MERN Equivalent: Your MongoDB connection (mongoose)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  /// 
  /// MERN Equivalent: Getting user from JWT token
  /// ```javascript
  /// const token = req.headers.authorization.split(' ')[1];
  /// const decoded = jwt.verify(token, SECRET);
  /// const user = await User.findById(decoded.id);
  /// ```
  /// 
  /// In Firebase, the current user is automatically available!
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  /// 
  /// MERN Equivalent: Socket.io connection or polling for auth state
  /// ```javascript
  /// // In React, you might poll or use socket.io
  /// useEffect(() => {
  ///   const checkAuth = async () => {
  ///     const token = localStorage.getItem('token');
  ///     if (token) {
  ///       const user = await fetch('/api/me', { headers: { Authorization: `Bearer ${token}` } });
  ///       setUser(user);
  ///     }
  ///   };
  ///   checkAuth();
  /// }, []);
  /// ```
  /// 
  /// In Firebase, this is a stream that automatically emits when auth state changes!
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user
  /// 
  /// MERN Equivalent: POST /register endpoint
  /// ```javascript
  /// app.post('/register', async (req, res) => {
  ///   const { email, password } = req.body;
  ///   // 1. Hash password
  ///   const hashedPassword = await bcrypt.hash(password, 10);
  ///   // 2. Create user in MongoDB
  ///   const user = await User.create({ email, password: hashedPassword });
  ///   // 3. Generate JWT token
  ///   const token = jwt.sign({ id: user._id }, SECRET);
  ///   // 4. Return token and user
  ///   res.json({ token, user: { id: user._id, email: user.email } });
  /// });
  /// ```
  /// 
  /// In Firebase, this is ONE method call that does ALL of the above!
  Future<UserCredential> register(String email, String password) async {
    try {
      // Create user with email and password
      // Firebase automatically:
      // - Hashes the password (no bcrypt needed!)
      // - Creates the user account
      // - Generates a token
      // - Stores the token securely
      // MERN Equivalent: All the code above in ONE line!
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      // MERN Equivalent: Creating additional user profile in MongoDB
      // ```javascript
      // await UserProfile.create({
      //   userId: user._id,
      //   email: user.email,
      //   createdAt: new Date(),
      // });
      // ```
      await createUserDocument(userCredential.user!);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      // MERN Equivalent: Catching errors from bcrypt or MongoDB
      throw _handleAuthException(e);
    } catch (e) {
      // Handle any other errors
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login an existing user
  /// 
  /// MERN Equivalent: POST /login endpoint
  /// ```javascript
  /// app.post('/login', async (req, res) => {
  ///   const { email, password } = req.body;
  ///   // 1. Find user in MongoDB
  ///   const user = await User.findOne({ email });
  ///   if (!user) throw new Error('User not found');
  ///   // 2. Verify password
  ///   const isValid = await bcrypt.compare(password, user.password);
  ///   if (!isValid) throw new Error('Invalid password');
  ///   // 3. Generate JWT token
  ///   const token = jwt.sign({ id: user._id }, SECRET);
  ///   // 4. Return token and user
  ///   res.json({ token, user: { id: user._id, email: user.email } });
  /// });
  /// ```
  /// 
  /// In Firebase, this is ONE method call!
  Future<UserCredential> login(String email, String password) async {
    try {
      // Sign in with email and password
      // Firebase automatically:
      // - Finds the user
      // - Verifies the password (no bcrypt.compare needed!)
      // - Generates a token
      // - Stores the token securely
      // MERN Equivalent: All the code above in ONE line!
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      throw _handleAuthException(e);
    } catch (e) {
      // Handle any other errors
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Logout current user
  /// 
  /// MERN Equivalent: Clearing token from localStorage
  /// ```javascript
  /// // In React
  /// localStorage.removeItem('token');
  /// axios.defaults.headers.common['Authorization'] = '';
  /// setUser(null);
  /// ```
  /// 
  /// In Firebase, this clears the token and auth state automatically!
  Future<void> logout() async {
    await _auth.signOut();
    // MERN Equivalent: After signOut(), the token is automatically cleared
    // No need to manually remove from localStorage or clear headers!
  }

  /// Create user document in Firestore
  /// 
  /// MERN Equivalent: Creating a user profile document in MongoDB
  /// ```javascript
  /// // After registration
  /// await UserProfile.create({
  ///   userId: user._id,
  ///   email: user.email,
  ///   createdAt: new Date(),
  ///   stats: {
  ///     wins: 0,
  ///     losses: 0,
  ///     totalMatches: 0,
  ///   },
  /// });
  /// ```
  /// 
  /// In Firestore, we create a document in the 'users' collection
  Future<void> createUserDocument(User user) async {
    try {
      // Check if user document already exists
      // MERN Equivalent: await UserProfile.findOne({ userId: user._id })
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      // Only create if it doesn't exist
      // MERN Equivalent: if (!userProfile) { await UserProfile.create(...) }
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          // MERN Equivalent: Default values in Mongoose schema
          'stats': {
            'wins': 0,
            'losses': 0,
            'totalMatches': 0,
          },
        });
        print('✅ User document created in Firestore: ${user.uid}');
      } else {
        print('ℹ️ User document already exists: ${user.uid}');
      }
    } catch (e) {
      // Log error but don't throw - user is already created in Auth
      // MERN Equivalent: Logging error but not failing the registration
      print('⚠️ Error creating user document: $e');
      // In production, you might want to retry this or use a Cloud Function
    }
  }

  /// Handle Firebase Auth exceptions and convert to user-friendly messages
  /// 
  /// MERN Equivalent: Custom error handling in Express
  /// ```javascript
  /// try {
  ///   // auth logic
  /// } catch (error) {
  ///   if (error.code === 'USER_NOT_FOUND') {
  ///     res.status(404).json({ message: 'User not found' });
  ///   } else if (error.code === 'INVALID_PASSWORD') {
  ///     res.status(401).json({ message: 'Invalid password' });
  ///   }
  /// }
  /// ```
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message ?? 'Unknown error'}';
    }
  }
}

