import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/lobby/lobby_screen.dart';
import '../screens/game/game_screen.dart';
import '../screens/gameover/gameover_screen.dart';
import '../providers/auth_provider.dart';

/// Router configuration using go_router
/// 
/// MERN Equivalent: React Router configuration with Protected Routes
/// In React Router:
/// ```jsx
/// <Routes>
///   <Route path="/auth" element={<AuthScreen />} />
///   <Route path="/dashboard" element={
///     <ProtectedRoute>
///       <Dashboard />
///     </ProtectedRoute>
///   } />
/// </Routes>
/// 
/// // ProtectedRoute component
/// const ProtectedRoute = ({ children }) => {
///   const { isAuthenticated } = useContext(AuthContext);
///   if (!isAuthenticated) {
///     return <Navigate to="/auth" />;
///   }
///   return children;
/// };
/// ```
/// 
/// In go_router, we use redirect callbacks to protect routes.
/// To access Riverpod providers in redirect, we use ProviderScope.containerOf(context)
/// which gives us access to the provider container.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state so router refreshes when auth changes
  // MERN Equivalent: useEffect(() => { ... }, [isAuthenticated])
  ref.watch(authProvider);

  return GoRouter(
    // initialLocation = The default route when app starts
    // MERN Equivalent: <Route path="/" element={<AuthScreen />} />
    initialLocation: '/auth',
    
    // redirect = Global redirect that runs before any route
    // MERN Equivalent: A wrapper component that checks auth before rendering routes
    redirect: (BuildContext context, GoRouterState state) {
      // Get auth state from provider
      // MERN Equivalent: const { isAuthenticated } = useContext(AuthContext);
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authProvider);
      
      final isAuthenticated = authState.isAuthenticated;
      final isGoingToAuth = state.matchedLocation == '/auth';
      
      // If user is authenticated and trying to go to auth page, redirect to dashboard
      // MERN Equivalent: if (isAuthenticated && path === '/auth') return <Navigate to="/dashboard" />
      if (isAuthenticated && isGoingToAuth) {
        return '/dashboard';
      }
      
      // If user is not authenticated and trying to access protected route, redirect to auth
      // MERN Equivalent: if (!isAuthenticated && path !== '/auth') return <Navigate to="/auth" />
      if (!isAuthenticated && !isGoingToAuth) {
        return '/auth';
      }
      
      // No redirect needed
      return null;
    },
    
    // routes = List of all routes in the app
    // MERN Equivalent: All <Route> components inside <Routes>
    routes: [
      // Auth Route
      // MERN Equivalent: <Route path="/auth" element={<AuthScreen />} />
      GoRoute(
        path: '/auth',
        name: 'auth', // Named route (optional, useful for navigation)
        builder: (BuildContext context, GoRouterState state) {
          return const AuthScreen();
        },
      ),
      
      // Dashboard Route (Protected)
      // MERN Equivalent: <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
      
      // Lobby Route (Protected)
      // MERN Equivalent: <Route path="/lobby" element={<ProtectedRoute><Lobby /></ProtectedRoute>} />
      GoRoute(
        path: '/lobby',
        name: 'lobby',
        builder: (BuildContext context, GoRouterState state) {
          return const LobbyScreen();
        },
      ),
      
      // Game Route (Protected)
      // MERN Equivalent: <Route path="/game" element={<ProtectedRoute><Game /></ProtectedRoute>} />
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (BuildContext context, GoRouterState state) {
          return const GameScreen();
        },
      ),
      
      // Game Over Route (Protected)
      // MERN Equivalent: <Route path="/gameover" element={<ProtectedRoute><GameOver /></ProtectedRoute>} />
      GoRoute(
        path: '/gameover',
        name: 'gameover',
        builder: (BuildContext context, GoRouterState state) {
          return const GameOverScreen();
        },
      ),
    ],
    
    // errorBuilder = What to show when route is not found
    // MERN Equivalent: <Route path="*" element={<NotFound />} />
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('404 - Page Not Found'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
    
    // Note: Router will automatically refresh when authProvider changes
    // because we're watching it in the provider above
    // MERN Equivalent: useEffect(() => { router.refresh() }, [isAuthenticated])
  );
});


/// Navigation Helper Functions
/// 
/// These are convenience functions, but you can also use:
/// - context.go('/path') - Navigate and replace current route
/// - context.push('/path') - Push new route on stack (like React Router's navigate)
/// - context.pop() - Go back (like browser back button)
/// 
/// MERN Equivalent:
/// ```javascript
/// // React Router
/// const navigate = useNavigate();
/// navigate('/dashboard');        // context.go('/dashboard')
/// navigate('/dashboard', {replace: true}); // context.go('/dashboard')
/// navigate(-1);                  // context.pop()
/// ```
