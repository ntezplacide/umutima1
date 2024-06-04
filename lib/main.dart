import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:umutima/pages/admin/welcome.dart';

void main() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDnpeu7QzpaAeYATHmXotX4YX1_gLcW8H8",
        authDomain: "umutima-9d146.firebaseapp.com",
        projectId: "umutima-9d146",
        storageBucket: "umutima-9d146.appspot.com",
        messagingSenderId: "76981796573",
        appId: "1:76981796573:web:eca00d12459d9e49146534",
        measurementId: "G-9KLHH362VF",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TangiraScreen(),
    );
  }
}

class TangiraScreen extends StatefulWidget {
  @override
  _TangiraScreenState createState() => _TangiraScreenState();
}

class _TangiraScreenState extends State<TangiraScreen> {
  bool _showLogo = true;

  @override
  void initState() {
    super.initState();
    // Delay the display of welcome message for 7 seconds after logo appears
    Timer(Duration(seconds: 7), () {
      setState(() {
        _showLogo = false;
      });
    });
  }

  void _navigateToLoginRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginRegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display logo
            Image.asset('assets/images/logo.png', width: 150, height: 150),
            SizedBox(height: 20),
            // Display welcome text and start button if logo is hidden
            if (!_showLogo) ...[
              Text(
                'Welcome to Tangira!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToLoginRegisterPage,
                child: Text('Start'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoginMode = true;
  bool _passwordVisible = false; // Track password visibility
  String _errorMessage = '';

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _submitForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();

    try {
      if (_isLoginMode) {
        // Perform login
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // If authentication is successful, navigate to SeniorDashboard
        if (userCredential.user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeniorDashboard(),
            ),
          );
        }
      } else {
        // Perform registration
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get the generated user ID
        final userId = userCredential.user!.uid;

        // Save user data to Firestore
        await _firestore.collection('umutimausers').doc(userId).set({
          'userId': userId,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'role': 'umutima', // Assigning role as 'umutima'
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Navigate to SeniorDashboard after successful registration
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeniorDashboard(),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Register'),
      ),
      backgroundColor: Color(0xFFBCB88A),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isLoginMode) ...[
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF006D5B)),
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF006D5B)),
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon:
                        Icon(Icons.account_circle, color: Color(0xFF006D5B)),
                  ),
                ),
                SizedBox(height: 20.0),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.email, color: Color(0xFF006D5B)),
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF006D5B)),
                ),
                obscureText:
                    !_passwordVisible, // Toggle visibility based on state
              ),
              SizedBox(height: 10.0),
              if (!_isLoginMode) ...[
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.black),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF006D5B)),
                  ),
                  obscureText:
                      !_passwordVisible, // Toggle visibility based on state
                ),
                SizedBox(height: 20.0),
              ],
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 10.0),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  _isLoginMode ? 'Login' : 'Register',
                  style: TextStyle(color: Color(0xFF000080)),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF8A8EBC)),
                ),
              ),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLoginMode
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Login',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
