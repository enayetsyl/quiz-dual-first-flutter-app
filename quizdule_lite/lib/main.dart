import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes.dart';
import 'config/firebase_config.dart';

/// Main entry point of the app
/// 
/// MERN Equivalent: src/index.js
/// In React: ReactDOM.render(<App />, document.getElementById('root'));
/// In Flutter: runApp(MyApp());
/// 
/// ProviderScope = React's Context Provider wrapper
/// MERN Equivalent: <Provider store={store}> or <AuthProvider>
/// This wraps your entire app so all widgets can access Riverpod providers
/// 
/// Firebase Initialization:
/// MERN Equivalent: Starting your Express server and connecting to MongoDB
/// ```javascript
/// // In Express (server.js)
/// await mongoose.connect('mongodb://localhost:27017/quizduel');
/// app.listen(3000);
/// ```
/// 
/// In Flutter, we initialize Firebase before starting the app
void main() async {
  // Ensure Flutter bindings are initialized
  // This is required before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and connect to emulators
  // MERN Equivalent: await mongoose.connect('mongodb://localhost:27017/quizduel')
  // This connects to Firebase Auth Emulator (port 9099) and Firestore Emulator (port 8080)
  await initializeFirebase();

  runApp(
    // ProviderScope = The root provider that makes all Riverpod providers available
    // MERN Equivalent: <Provider store={store}> wrapping your <App />
    // Without this, you can't use ref.watch() or ref.read() anywhere
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget of the application
/// 
/// MERN Equivalent: App.js or App.tsx
/// This is like your main App component that wraps everything
/// 
/// In React Router:
/// ```jsx
/// <BrowserRouter>
///   <Routes>
///     <Route path="/" element={<AuthScreen />} />
///   </Routes>
/// </BrowserRouter>
/// ```
/// 
/// In Flutter with go_router:
/// MaterialApp.router uses the routerConfig to handle all routing
/// We use ConsumerWidget to access the router provider
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get router from provider
    // MERN Equivalent: The router is available through context
    final router = ref.watch(appRouterProvider);
    
    // MaterialApp.router = MaterialApp with go_router integration
    // MERN Equivalent: <BrowserRouter> wrapper around your app
    return MaterialApp.router(
      title: 'QuizDuel Lite',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      // routerConfig = The router configuration (like <Routes> in React Router)
      // MERN Equivalent: All your <Route> components inside <Routes>
      routerConfig: router,
    );
  }
}

