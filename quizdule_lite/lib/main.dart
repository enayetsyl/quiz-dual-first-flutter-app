import 'package:flutter/material.dart';
import 'screens/auth/auth_screen.dart';

/// Main entry point of the app
/// 
/// MERN Equivalent: src/index.js
/// In React: ReactDOM.render(<App />, document.getElementById('root'));
/// In Flutter: runApp(MyApp());
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
/// 
/// MERN Equivalent: App.js or App.tsx
/// This is like your main App component that wraps everything
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp = The root app widget that provides Material Design theming
    // MERN Equivalent: <BrowserRouter> or <ThemeProvider> wrapper
    return MaterialApp(
      title: 'QuizDuel Lite',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      // home = The initial route/screen
      // MERN Equivalent: <Route path="/" element={<AuthScreen />} />
      home: const AuthScreen(),
    );
  }
}

