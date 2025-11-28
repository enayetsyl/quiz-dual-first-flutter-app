import 'package:flutter/material.dart';
import 'config/routes.dart';

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
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      routerConfig: appRouter,
    );
  }
}

