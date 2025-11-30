import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Auth State Model
/// 
/// MERN Equivalent: This is like your Redux state shape or Context value
/// In React with Context:
/// ```javascript
/// const AuthContext = createContext({
///   user: null,
///   isLoading: false,
///   isAuthenticated: false,
/// });
/// ```
/// 
/// In Flutter with Riverpod, we define a class to hold our state
class AuthState {
  final String? userId;
  final String? email;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  // Constructor with default values
  // MERN Equivalent: const initialState = { user: null, isLoading: false, ... }
  const AuthState({
    this.userId,
    this.email,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  // CopyWith method - creates a new state with updated fields
  // MERN Equivalent: In Redux: return { ...state, isLoading: true }
  // In React: setState({ ...prevState, isLoading: true })
  AuthState copyWith({
    String? userId,
    String? email,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

/// Auth Notifier - Manages Auth State
/// 
/// MERN Equivalent: This is like useReducer with authReducer
/// In React with useReducer:
/// ```javascript
/// const authReducer = (state, action) => {
///   switch (action.type) {
///     case 'LOGIN_START':
///       return { ...state, isLoading: true };
///     case 'LOGIN_SUCCESS':
///       return { ...state, user: action.payload, isAuthenticated: true };
///     default:
///       return state;
///   }
/// };
/// ```
/// 
/// In Flutter with Riverpod 3.x, we use Notifier class
class AuthNotifier extends Notifier<AuthState> {
  // Auth service instance
  // MERN Equivalent: Your API service or axios instance
  late final AuthService _authService;
  
  // Stream subscription for auth state changes
  // MERN Equivalent: Socket.io subscription or polling interval
  StreamSubscription<User?>? _authStateSubscription;

  // Initial state
  // MERN Equivalent: const initialState = { user: null, isLoading: false, ... }
  @override
  AuthState build() {
    // Initialize auth service
    _authService = AuthService();
    
    // Set initial loading state while we check Firebase auth
    // MERN Equivalent: Checking if token exists in localStorage on app start
    // ```javascript
    // useEffect(() => {
    //   const token = localStorage.getItem('token');
    //   if (token) {
    //     setIsLoading(true);
    //     verifyToken(token).then(user => setUser(user));
    //   }
    // }, []);
    // ```
    final currentUser = _authService.currentUser;
    
    // Listen to auth state changes
    // MERN Equivalent: Socket.io connection or useEffect with polling
    // ```javascript
    // useEffect(() => {
    //   socket.on('authStateChanged', (user) => {
    //     setUser(user);
    //   });
    //   return () => socket.off('authStateChanged');
    // }, []);
    // ```
    _authStateSubscription = _authService.authStateChanges.listen(
      (user) {
        // This fires whenever auth state changes (login, logout, token refresh)
        // MERN Equivalent: Socket.io event or token verification result
        if (user != null) {
          state = state.copyWith(
            userId: user.uid,
            email: user.email,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          );
        } else {
          // User logged out
          state = const AuthState();
        }
      },
    );
    
    // Clean up stream subscription when provider is disposed
    // MERN Equivalent: useEffect cleanup function
    // ```javascript
    // useEffect(() => {
    //   const subscription = socket.on('authStateChanged', handler);
    //   return () => subscription.off('authStateChanged');
    // }, []);
    // ```
    // In Riverpod 3.x, we use ref.onDispose() instead of override dispose()
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });
    
    // Return initial state based on current Firebase user
    // MERN Equivalent: If token exists, set user; otherwise, null
    if (currentUser != null) {
      return AuthState(
        userId: currentUser.uid,
        email: currentUser.email,
        isAuthenticated: true,
        isLoading: false,
      );
    }
    
    return const AuthState();
  }

  /// Login method
  /// 
  /// MERN Equivalent: dispatch({ type: 'LOGIN_START' })
  /// ```javascript
  /// const handleLogin = async (email, password) => {
  ///   dispatch({ type: 'LOGIN_START' });
  ///   try {
  ///     const response = await axios.post('/api/login', { email, password });
  ///     localStorage.setItem('token', response.data.token);
  ///     dispatch({ type: 'LOGIN_SUCCESS', payload: response.data.user });
  ///   } catch (error) {
  ///     dispatch({ type: 'LOGIN_ERROR', payload: error.message });
  ///   }
  /// };
  /// ```
  /// 
  /// In Flutter with Firebase, the authStateChanges stream automatically
  /// updates the state when login succeeds - no need to manually set state!
  Future<void> login(String email, String password) async {
    // Set loading state
    // MERN Equivalent: dispatch({ type: 'LOGIN_START' })
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call Firebase Auth login
      // MERN Equivalent: await axios.post('/api/login', { email, password })
      // Firebase automatically:
      // - Verifies credentials
      // - Generates token
      // - Stores token securely
      // - Updates authStateChanges stream (which updates our state!)
      await _authService.login(email, password);
      
      // Note: We don't need to manually update state here!
      // The authStateChanges stream listener (in build()) will automatically
      // update the state when Firebase auth succeeds
      // MERN Equivalent: The token is stored, and your useEffect hook
      // automatically fetches user data and updates state
    } catch (e) {
      // Handle error
      // MERN Equivalent: dispatch({ type: 'LOGIN_ERROR', payload: error })
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  /// Register method
  /// 
  /// MERN Equivalent: dispatch({ type: 'REGISTER_START' })
  /// ```javascript
  /// const handleRegister = async (email, password) => {
  ///   dispatch({ type: 'REGISTER_START' });
  ///   try {
  ///     const response = await axios.post('/api/register', { email, password });
  ///     localStorage.setItem('token', response.data.token);
  ///     dispatch({ type: 'REGISTER_SUCCESS', payload: response.data.user });
  ///   } catch (error) {
  ///     dispatch({ type: 'REGISTER_ERROR', payload: error.message });
  ///   }
  /// };
  /// ```
  /// 
  /// In Flutter with Firebase, the authStateChanges stream automatically
  /// updates the state when registration succeeds!
  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call Firebase Auth register
      // MERN Equivalent: await axios.post('/api/register', { email, password })
      // Firebase automatically:
      // - Hashes password
      // - Creates user account
      // - Generates token
      // - Stores token securely
      // - Creates user document in Firestore (via createUserDocument)
      // - Updates authStateChanges stream (which updates our state!)
      await _authService.register(email, password);
      
      // Note: We don't need to manually update state here!
      // The authStateChanges stream listener (in build()) will automatically
      // update the state when Firebase auth succeeds
      // MERN Equivalent: The token is stored, and your useEffect hook
      // automatically fetches user data and updates state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  /// Logout method
  /// 
  /// MERN Equivalent: dispatch({ type: 'LOGOUT' })
  /// ```javascript
  /// const handleLogout = () => {
  ///   localStorage.removeItem('token');
  ///   axios.defaults.headers.common['Authorization'] = '';
  ///   dispatch({ type: 'LOGOUT' });
  /// };
  /// ```
  /// 
  /// In Flutter with Firebase, the authStateChanges stream automatically
  /// updates the state when logout succeeds!
  Future<void> logout() async {
    try {
      // Call Firebase Auth logout
      // MERN Equivalent: localStorage.removeItem('token')
      // Firebase automatically:
      // - Clears the token
      // - Updates authStateChanges stream (which updates our state!)
      await _authService.logout();
      
      // Note: We don't need to manually reset state here!
      // The authStateChanges stream listener (in build()) will automatically
      // update the state to logged out when Firebase auth clears
      // MERN Equivalent: Your useEffect hook detects token is gone and sets user to null
    } catch (e) {
      // Handle error (shouldn't happen, but just in case)
      state = state.copyWith(error: 'Logout failed: ${e.toString()}');
    }
  }
}

/// Auth Provider - The provider that exposes AuthNotifier
/// 
/// MERN Equivalent: This is like creating your Context Provider
/// In React:
/// ```javascript
/// export const AuthProvider = ({ children }) => {
///   const [state, dispatch] = useReducer(authReducer, initialState);
///   return (
///     <AuthContext.Provider value={{ state, dispatch }}>
///       {children}
///     </AuthContext.Provider>
///   );
/// };
/// ```
/// 
/// In Flutter with Riverpod 3.x:
/// - NotifierProvider automatically creates and manages the notifier
/// - No need to manually wrap widgets (ProviderScope does that globally)
/// - Access with ref.watch(authProvider) anywhere in the app
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Convenience providers for specific parts of auth state
/// 
/// MERN Equivalent: Creating selectors in Redux
/// In React: const isAuthenticated = useSelector(state => state.auth.isAuthenticated);
/// 
/// In Flutter: These are computed providers that watch authProvider and extract specific values
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).email;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
