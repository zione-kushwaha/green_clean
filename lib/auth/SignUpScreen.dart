// ignore_for_file: use_build_context_synchronously

import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:green_theme/auth/SignScreen.dart';
import 'package:green_theme/auth/auth.config.dart';
import 'package:green_theme/route_animation.dart';
import 'package:green_theme/utils/regex.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode _passwordfocus = FocusNode();

  bool _isLoading = false;
 Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      
      // Add await here
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = _auth.currentUser;

      // Check if user exists and email is not verified
      if (user != null && !user.emailVerified) {
        // Send email verification
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully. Please check your email for verification.',
            ),
          ),
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', _username.text);

        setState(() {
          _navigateToNextScreen(context, 'sign_in');
          _isLoading = false;
        });
      } else {
        // Handle the case where the user is null or email is already verified
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User is null or email is already verified.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Firebase Auth Error: $e");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating account: ${e.message}'),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error: $error");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }
}


  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize the package
    passwordVisible=true;
    //initialize email-auth
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: _isLoading
            ? null
            : const BackButton(
                color: Colors.white, // Set text color based on theme brightness
              ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Visibility(
              visible: !_isLoading,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ), // Color of the loading indicator
                          backgroundColor:
                              Colors.black, // Background color of the indicator
                          strokeWidth: 4, // Thickness of the indicator
                        ),
                      )
                    : Column(children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              const Center(
                                child: Text(
                                  "Create Your Green_Clean Account",
                                  style: TextStyle(
                                    fontSize: 22, // Set the desired font size
                                    fontWeight: FontWeight
                                        .bold, // Set the desired font weight
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.035,
                              ),
                               TextFormField(
                                  controller: _username,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    // filled: true,
                                    // fillColor: Colors.black,
                                    labelText: 'User Name',
                                    hintText: 'Enter User Name',
                                    contentPadding: const EdgeInsets.all(16.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.white, // Color of the border
                                        width: 2.0, // Width of the border
                                      ),
                                    ),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'User Name is required';
                                    }
                                    if (value.length<=3) {
                                      return 'UserName Must be greater than 3 letters';
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: height * 0.015,
                              ),
                              TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    // filled: true,
                                    // fillColor: Colors.black,
                                    labelText: 'Email Address',
                                    hintText: 'Enter Email Address',
                                    contentPadding: const EdgeInsets.all(16.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color:
                                            Colors.white, // Color of the border
                                        width: 2.0, // Width of the border
                                      ),
                                    ),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!emailRegExp.hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: height * 0.015,
                              ),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordfocus,
                                obscureText: passwordVisible,
                                decoration: InputDecoration(
                                  // filled: true,
                                  // fillColor: Colors.black,
                                  labelText: 'Password',
                                  hintText: 'Enter Password',
                                  contentPadding: const EdgeInsets.all(16.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color:
                                          Colors.white, // Color of the border
                                      width: 2.0, // Width of the border
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(
                                        () {
                                          passwordVisible = !passwordVisible;
                                        },
                                      );
                                    },
                                  ),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  }
                                  if (!value.contains(RegExp(r'[A-Z]'))) {
                                    return 'Password must contain at least one capital letter';
                                  }
                                  if (!value.contains(RegExp(r'[a-z]'))) {
                                    return 'Password must contain at least one small letter';
                                  }
                                  if (!value.contains(RegExp(r'[0-9]'))) {
                                    return 'Password must contain at least one digit';
                                  }
                                  if (!value.contains(
                                      RegExp(r'[!@#\$%^&*()_+{}|:<>?~]'))) {
                                    return 'Password must contain at least one special character';
                                  }
                                  return null; // Password is valid
                                },
                              ),
                            
                              SizedBox(height: height * 0.015),
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: width *
                                        0.067, // Set the width and height to control the size of the circle
                                    height: height * 0.03,
                                    decoration: BoxDecoration(
                                      shape: BoxShape
                                          .circle, // Makes the container a circle
                                      border: Border.all(
                                          color: Colors.green,
                                          width: 2.0), // Green border
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size:
                                            12.0, // Adjust the size of the checkmark icon
                                      ),
                                    ),
                                  ), // Tick sign
                                  const SizedBox(
                                      width: 8.0), // Add some horizontal space
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text:
                                                'By creating account, you agree to the ',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Navigate to the Terms of Service screen
                                                // You can use Navigator to navigate to the screen.
                                              },
                                          ),
                                          const TextSpan(
                                            text: ' and ',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          TextSpan(
                                            text: 'Privacy Policy.',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Navigate to the Privacy Policy screen
                                                // You can use Navigator to navigate to the screen.
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * 0.015,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _passwordfocus.unfocus();

                                    setState(() {
                                      _isLoading = true; // Show loading icon
                                    });
                                    // Add create account button functionality here
                                    _submitForm();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: height * 0.064,
                                    width: double.infinity,
                                    child: const Center(
                                      child: Text(
                                        'Create an Account',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * 0.005,
                        ),
                        const Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(
                                width: 8.0), // Add space between the dividers
                            Text("or", style: TextStyle(color: Colors.white)),
                            SizedBox(
                                width: 8.0), // Add space between the dividers
                            Expanded(
                              child: Divider(
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.0128,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Add login button functionality here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.white, width: 0.8),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: SizedBox(
                              height: height * 0.065,
                              width: double.infinity,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/logos/gmail.svg', // Replace with the path to your Gmail SVG icon
                                      width: width *
                                          0.055, // Adjust the width as needed
                                      height: height *
                                          0.025, // Adjust the height as needed
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      'Sign Up with Gmail',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.0128,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Add login button functionality here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.white, width: 0.8),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: SizedBox(
                              height: height * 0.065,
                              width: double.infinity,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/logos/facebook.svg', // Replace with the path to your Gmail SVG icon
                                      width: width *
                                          0.066, // Adjust the width as needed
                                      height: height *
                                          0.03, // Adjust the height as needed
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      'Sign Up with Facebook',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.0128,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Add login button functionality here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.white, width: 0.8),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: SizedBox(
                              height: height * 0.065,
                              width: double.infinity,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/logos/apple.svg', // Replace with the path to your Gmail SVG icon
                                      width: width *
                                          0.066, // Adjust the width as needed
                                      height: height *
                                          0.03, // Adjust the height as needed
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      'Sign Up with Apple',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Already have account? ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 14, 156, 19),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate to the Terms of Service screen
                                    // You can use Navigator to navigate to the screen.
                                    _navigateToNextScreen(context, 'sign_in');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ]),
              ),
            ),
          ),
          if (_isLoading)
           const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context, String screen) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (screen == "signup_otp") {
       
      } else if (screen == "sign_in") {
        Navigator.of(context).pushReplacement(createRoute(const SignInScreen()));
      }
    });
  }
}
