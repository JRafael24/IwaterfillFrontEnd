import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iwaterfill/services/userdetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userdetailfform extends StatefulWidget {
  final String email;
  const Userdetailfform({Key? key, required this.email}) : super(key: key);

  @override
  State<Userdetailfform> createState() => _SignupState(email: email);
}



class _SignupState extends State<Userdetailfform> {
  final formKey = GlobalKey<FormState>();
  final String email;
  String phoneNumber = '';
  String address = '';

  _SignupState({required this.email});

  Future<int> getId(email) async{
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/auth/$email')
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<bool> createAccount(Userdetail userdetail, email) async {
      int id = await getId(email);
      print(id);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/profile/addinfo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId' : id,
          'phoneNumber': userdetail.phoneNumber,
          'address': userdetail.address,
        }),
      );
      print(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );
        return true;
        // Replace with actual navigation logic after successful registration
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
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
                        'assets/city.png',
                        width: 400,
                        height: 200,
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
                        maxLength: 11,  // Adjusted to limit the input to 11 characters
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.black),
                          labelText: 'Phone Number',
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
                            return 'Please enter your phone number';
                          } else if (value.length != 11) {
                            return 'Phone number must be exactly 11 digits';
                          } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Phone number must contain only digits';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          phoneNumber = value!;
                        },
                      ),

                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        maxLength: 60,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.black),
                          labelText: 'Address',
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
                            return 'Please enter your address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          address = value!;
                        },
                      ),
                      SizedBox(height: 15.0),
                      SizedBox(
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              Userdetail userdetail = Userdetail(
                                phoneNumber: phoneNumber,
                                address: address,
                              );
                              createAccount(userdetail, email).then((result){
                                if(result){
                                  Navigator.pushReplacementNamed(context, '/dashboard');
                                }else{
                                 print(result);
                                }
                              }).catchError((err){
                                print(err.toString());
                                //snackbar the error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Login failed. Please check your credentials.'),
                                  ),
                                );

                              });
                            }
                          },
                          child: Text(
                            'Confirm',
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
