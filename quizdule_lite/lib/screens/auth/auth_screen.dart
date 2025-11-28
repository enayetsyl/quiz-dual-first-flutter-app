import 'package:flutter/material.dart';

/// Auth Screen - Login and Register UI
/// 
/// MERN Equivalent: This is like a React functional component
/// In React: const AuthScreen = () => { return <div>...</div>; }
/// In Flutter: class AuthScreen extends StatelessWidget { ... }
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // MERN Equivalent: <input type="email" placeholder="Email" />
              TextField(
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
              ),
              
              const SizedBox(height: 16),
              
              // Password TextField
              // MERN Equivalent: <input type="password" placeholder="Password" />
              TextField(
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
              ),
              
              const SizedBox(height: 32),
              
              // Login Button
              // MERN Equivalent: <button onClick={handleLogin}>Login</button>
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement login logic in Phase 6
                  // MERN Equivalent: handleLogin() function
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login clicked - Coming in Phase 6!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Register Button
              // MERN Equivalent: <button onClick={handleRegister}>Register</button>
              OutlinedButton(
                onPressed: () {
                  // TODO: Implement register logic in Phase 6
                  // MERN Equivalent: handleRegister() function
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Register clicked - Coming in Phase 6!')),
                  );
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
            ],
          ),
        ),
      ),
    );
  }
}

