import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/lobby/lobby_screen.dart';
import '../screens/game/game_screen.dart';
import '../screens/gameover/gameover_screen.dart';

/// Router configuration using go_router
/// 
/// MERN Equivalent: React Router configuration
/// In React Router:
/// ```jsx
/// <Routes>
///   <Route path="/auth" element={<AuthScreen />} />
///   <Route path="/dashboard" element={<Dashboard />} />
/// </Routes>
/// ```
/// 
/// In go_router, we define routes in a list and use GoRouter widget
final GoRouter appRouter = GoRouter(
  // initialLocation = The default route when app starts
  // MERN Equivalent: <Route path="/" element={<AuthScreen />} />
  initialLocation: '/auth',
  
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
    
    // Dashboard Route
    // MERN Equivalent: <Route path="/dashboard" element={<Dashboard />} />
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const DashboardScreen();
      },
    ),
    
    // Lobby Route
    // MERN Equivalent: <Route path="/lobby" element={<Lobby />} />
    GoRoute(
      path: '/lobby',
      name: 'lobby',
      builder: (BuildContext context, GoRouterState state) {
        return const LobbyScreen();
      },
    ),
    
    // Game Route
    // MERN Equivalent: <Route path="/game" element={<Game />} />
    GoRoute(
      path: '/game',
      name: 'game',
      builder: (BuildContext context, GoRouterState state) {
        return const GameScreen();
      },
    ),
    
    // Game Over Route
    // MERN Equivalent: <Route path="/gameover" element={<GameOver />} />
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
);

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

