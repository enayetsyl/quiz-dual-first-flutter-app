import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

/// Auth Screen - Login and Register UI
/// 
/// MERN Equivalent: This is like a React functional component with Context
/// In React with Context:
/// ```javascript
/// const AuthScreen = () => {
///   const { state, dispatch } = useContext(AuthContext);
///   return <div>...</div>;
/// };
/// ```
/// 
/// In Flutter with Riverpod:
/// - ConsumerWidget = StatelessWidget that can access providers
/// - ref.watch() = Like useContext() - watches for changes and rebuilds
/// - ref.read() = Like dispatch() - reads provider without watching
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  // Text controllers for form inputs
  // MERN Equivalent: const [email, setEmail] = useState('');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    // MERN Equivalent: useEffect cleanup function
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch() = Like useContext() - watches authProvider and rebuilds when it changes
    // MERN Equivalent: const { state, dispatch } = useContext(AuthContext);
    final authState = ref.watch(authProvider);
    
    // ref.read() = Like dispatch() - reads provider without watching (for actions)
    // MERN Equivalent: dispatch({ type: 'LOGIN', payload: { email, password } })
    final authNotifier = ref.read(authProvider.notifier);

    // Scaffold = The main container/layout widget
    // MERN Equivalent: <div className="app-container"> or a page wrapper
    return Scaffold(
      // AppBar = Header/navigation bar at the top
      // MERN Equivalent: <header> or <nav> component
      appBar: AppBar(
        title: const Text('QuizDuel Lite'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      
      // Body = Main content area
      // MERN Equivalent: <main> or the main content div
      body: Container(
        // Container = <div> with styling
        // MERN Equivalent: <div style={{padding: '20px', backgroundColor: '#f5f5f5'}}>
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
        
        // Center = Centers its child widget
        // MERN Equivalent: <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center'}}>
        child: Center(
          // Column = Vertical flexbox (flex-direction: column)
          // MERN Equivalent: <div style={{display: 'flex', flexDirection: 'column', gap: '20px'}}>
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Title
              // MERN Equivalent: <h1>QuizDuel Lite</h1>
              const Text(
                'QuizDuel Lite',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              // MERN Equivalent: <p>1v1 Quiz Battle</p>
              const Text(
                '1v1 Quiz Battle',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Email TextField
              // MERN Equivalent: <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !authState.isLoading, // Disable when loading
              ),
              
              const SizedBox(height: 16),
              
              // Password TextField
              // MERN Equivalent: <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true, // Hides the password (like type="password")
                keyboardType: TextInputType.visiblePassword,
                enabled: !authState.isLoading, // Disable when loading
              ),
              
              const SizedBox(height: 32),
              
              // Error message display
              // MERN Equivalent: {error && <div className="error">{error}</div>}
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    authState.error!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              if (authState.error != null) const SizedBox(height: 16),
              
              // Login Button
              // MERN Equivalent: <button onClick={handleLogin} disabled={isLoading}>Login</button>
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null // Disable button when loading
                    : () async {
                        // MERN Equivalent: dispatch({ type: 'LOGIN', payload: { email, password } })
                        await authNotifier.login(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );
                        
                        // Check state after async operation completes
                        // MERN Equivalent: if (isAuthenticated) navigate('/dashboard')
                        // Note: ref.read() gets current state without watching
                        final currentState = ref.read(authProvider);
                        if (currentState.isAuthenticated && context.mounted) {
                          context.go('/dashboard');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey, // Show disabled state
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 12),
              
              // Register Button
              // MERN Equivalent: <button onClick={handleRegister} disabled={isLoading}>Register</button>
              OutlinedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        // MERN Equivalent: dispatch({ type: 'REGISTER', payload: { email, password } })
                        await authNotifier.register(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );
                        
                        // Check state after async operation completes
                        final currentState = ref.read(authProvider);
                        if (currentState.isAuthenticated && context.mounted) {
                          context.go('/dashboard');
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.deepPurple, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // State Management Demo Section (Phase 4)
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'State Management Demo (Phase 4)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Display current auth state
              // MERN Equivalent: <div>Is Authenticated: {isAuthenticated}</div>
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auth State:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Authenticated: ${authState.isAuthenticated}'),
                    Text('Loading: ${authState.isLoading}'),
                    if (authState.email != null)
                      Text('Email: ${authState.email}'),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Navigation Test Section (for Phase 3)
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Navigation Test (Phase 3)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Quick Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Test Dashboard
                  TextButton(
                    onPressed: () {
                      // MERN Equivalent: navigate('/dashboard')
                      context.go('/dashboard');
                    },
                    child: const Text('Dashboard'),
                  ),
                  // Test Lobby
                  TextButton(
                    onPressed: () {
                      // MERN Equivalent: navigate('/lobby')
                      context.go('/lobby');
                    },
                    child: const Text('Lobby'),
                  ),
                  // Test Game
                  TextButton(
                    onPressed: () {
                      // MERN Equivalent: navigate('/game')
                      context.go('/game');
                    },
                    child: const Text('Game'),
                  ),
                  // Test Game Over
                  TextButton(
                    onPressed: () {
                      // MERN Equivalent: navigate('/gameover')
                      context.go('/gameover');
                    },
                    child: const Text('GameOver'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

