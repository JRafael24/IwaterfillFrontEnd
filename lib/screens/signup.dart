import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iwaterfill/screens/userdetailfform.dart';
import 'package:iwaterfill/services/user.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  IconData _obscurePasswordIcon = Icons.visibility_off;
  IconData _obscureConfirmPasswordIcon = Icons.visibility_off;


  Future<void> createAccount(User user) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/auth/register/user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': user.username,
          'email': user.email,
          'password': user.password,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        // Registration successful, navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Handle other status codes or errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/wafill.png',
                        width: 300,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 25.0,
                  color: Colors.blue[900],
                  thickness: 2.0,
                ),
                SizedBox(height: 20.0),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        maxLength: 60,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.black),
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.length < 3) {
                            return 'Name should be at least 3 letters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value!;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 60,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.black),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          final emailRegExp = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!;
                        },
                      ),

                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        enableInteractiveSelection: false,
                        obscureText: _obscurePassword,
                        maxLength: 20,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.black),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePasswordIcon, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                                _obscurePasswordIcon = _obscurePassword ? Icons.visibility_off : Icons.visibility;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be 8 or more characters';
                          }
                          if (value.length > 20) {
                            return 'Password must be 20 characters long only';
                          }
                          // Add more specific password validation if needed
                          return null;
                        },
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        obscureText: _obscureConfirmPassword,
                        maxLength: 20,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.black),
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPasswordIcon, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                                _obscureConfirmPasswordIcon = _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          confirmPassword = value;
                        },
                      ),
                      SizedBox(height: 15.0),
                      SizedBox(
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              if (password == confirmPassword) {
                                User user = User(username: name, email: email, password: password,);
                                createAccount(user);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Userdetailfform(email: user.email)
                                  )
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Passwords do not match')),
                                );
                              }
                            }
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              letterSpacing: 1.0,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              color: Colors.blue[900],
                              height: 100,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'or',
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Divider(
                              color: Colors.blue[900],
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 5.0),
                          InkWell(
                            child: Text(
                              'Login Here',
                              style: TextStyle(
                                color: Colors.blue[900],
                                decoration: TextDecoration.underline,
                                fontSize: 15.0,
                              ),
                            ),
                            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
