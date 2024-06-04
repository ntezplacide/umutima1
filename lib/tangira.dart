import 'package:flutter/material.dart';

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

  bool _isLoginMode = true;
  bool _passwordVisible = false; // Track password visibility
  String _errorMessage = '';

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _submitForm() async {
    // Implement form submission logic here
    print('Form submitted');
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
          child: formLoginAndSignUp(),
        ),
      ),
    );
  }

  Column formLoginAndSignUp() {
    return Column(
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
        );
  }
}
