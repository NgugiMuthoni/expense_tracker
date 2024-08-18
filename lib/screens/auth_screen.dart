import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../models/user_model.dart';
import 'dashboard_screen.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DBService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final hashedPassword = hashPassword(_passwordController.text);

                if (_isLogin) {
                  final user = await dbService.loginUser(
                    _usernameController.text,
                    hashedPassword,
                  );

                  if (user == null) {
                    setState(() {
                      _errorMessage = 'Invalid credentials';
                    });
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(user: user),
                      ),
                    );
                  }
                } else {
                  final user = User(
                    username: _usernameController.text,
                    password: hashedPassword,
                  );

                  final result = await dbService.registerUser(user);
                  if (result == null) {
                    setState(() {
                      _errorMessage = 'Username already exists';
                    });
                  } else {
                    setState(() {
                      _isLogin = true;
                      _errorMessage = '';
                    });
                  }
                }
              },
              child: Text(_isLogin ? 'Login' : 'Register'),
            ),
            SizedBox(height: 12),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _errorMessage = '';
                });
              },
              child: Text(_isLogin
                  ? "Don't have an account? Register here"
                  : "Already have an account? Login here"),
            ),
          ],
        ),
      ),
    );
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hashed password as a string
  }
}
