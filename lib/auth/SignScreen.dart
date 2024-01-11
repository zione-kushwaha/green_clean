import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:green_theme/Screens/chatScreen.dart';
import 'package:green_theme/auth/SignUpScreen.dart';
import 'package:green_theme/auth/otp_screen.dart';
import 'package:green_theme/route_animation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/regex.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FocusNode _passwordfocus = FocusNode();
  bool _isLoading = false;

  Future<void> _signInForm() async {
    if (_formKey.currentState!.validate()) {
      // await Future.delayed(const Duration(seconds: 10));

      // Replace this with your actual API request
      // Send the POST request and handle the response

      // If the form is valid, perform the POST request
      final email = _emailController.text;
      final password = _passwordController.text;
      // final password2 = _password2Controller.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);

      // Send a POST request with the data
      // final url = Uri.parse(ApiUtil.joinUrl('auth/login'));
      final url=Uri.parse('uri');
      if (kDebugMode) {
        print(url);
      }
      final data = {
        'email': prefs.getString('email'),
        'password': password,
      };
      
      http.post(url , body: data).then((response) {
        print('Response Body: ${response.body}');
        setState(() {
          _isLoading = false;
        });
        Map<String, dynamic> data = json.decode(response.body);
        // Handle the response from the server as needed
        // Check if the request was successful and handle accordingly
        if (response.statusCode == 200) {
          // _emailController.clear();
          // _passwordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message']),
          ));

          //otp verification screen
          _navigateToNextScreen(context, 'signin_otp');
        } else if (response.statusCode == 403) {
          // _emailController.clear();
          // _passwordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message']),
          ));

          //otp verification screen
          _navigateToNextScreen(context, 'signup_otp');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['error']),
          ));
        }
      });
    }
  }

  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
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
      body: Stack(children: [
        SingleChildScrollView(
          child: Visibility(
            visible: !_isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const Center(
                        child: Text(
                          "Login to your Green_Clean Account",
                          style: TextStyle(
                            fontSize: 22, // Set the desired font size
                            fontWeight:
                                FontWeight.bold, // Set the desired font weight
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.064,
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
                                color: Colors.white, // Color of the border
                                width: 2.0, // Width of the border
                              ),
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        height: height * 0.032,
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
                              color: Colors.white, // Color of the border
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          if (!value
                              .contains(RegExp(r'[!@#\$%^&*()_+{}|:<>?~]'))) {
                            return 'Password must contain at least one special character';
                          }
                          return null; // Password is valid
                        },
                      ),
                      SizedBox(height: height * 0.038),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _passwordfocus.unfocus();
                            setState(() {
                              _isLoading = true; // Show loading icon
                            });
                            // Add create account button functionality here
                            _signInForm();
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
                                'Sign In',
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
                  height: height * 0.019,
                ),
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: 8.0), // Add space between the dividers
                    Text("or", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 8.0), // Add space between the dividers
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
                        side: const BorderSide(color: Colors.white, width: 0.8),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: SizedBox(
                      height: height * 0.064,
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/logos/gmail.svg', // Replace with the path to your Gmail SVG icon
                              width:
                                  width * 0.0555, // Adjust the width as needed
                              height:
                                  height * 0.025, // Adjust the height as needed
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Sign in with Gmail',
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
                        side: const BorderSide(color: Colors.white, width: 0.8),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: SizedBox(
                      height: height * 0.064,
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/logos/facebook.svg', // Replace with the path to your Gmail SVG icon
                              width:
                                  width * 0.066, // Adjust the width as needed
                              height:
                                  height * 0.03, // Adjust the height as needed
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Sign in with Facebook',
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
                        side: const BorderSide(color: Colors.white, width: 0.8),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: SizedBox(
                      height: height * 0.064,
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/logos/apple.svg', // Replace with the path to your Gmail SVG icon
                              width:
                                  width * 0.066, // Adjust the width as needed
                              height:
                                  height * 0.03, // Adjust the height as needed
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Sign in with Apple',
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
                        text: 'Don\'t have account? ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 14, 156, 19),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _navigateToNextScreen(context, "sign_up");
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
          Center(
            child: CircularProgressIndicator(),
          ),
      ]),
    );
  }

  void _navigateToNextScreen(BuildContext context, String screen) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (screen == "signin_otp") {
        Navigator.of(context).push(createRoute(const OTPScreen(
          usage: 'sign_in',
        )));
      } else if (screen == "sign_up") {
        Navigator.of(context).push(createRoute(const chat_screens()));
      }
    });
  }
}
