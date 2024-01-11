// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final String usage;
  const OTPScreen({super.key, required this.usage});
  @override
  OTPScreenState createState() => OTPScreenState();
}

class OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  String getUsage() {
    return widget.usage;
  }

  void handleBackspace(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      // Check if the current field is empty and not the first field
      if (controllers[index].text.isEmpty && index > 0) {
        // Move the focus to the previous field
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      } else if (controllers[index].text.isNotEmpty) {
        // Clear the digit in the current field
        controllers[index].clear();
      }
    }
  }

  Future<void> _resendOTP() async {
    for (var controller in controllers) {
      controller.clear(); // Sets the text to an empty string
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String otpResendType = (getUsage() == 'sign_up') ? 'registration' : 'login';
    final url = Uri.parse('');
    final data = {"email": email, "otp_resend_type": otpResendType};
    http.post(url, body: data).then((response) async {
      setState(() {
        _isLoading = false;
      });
      Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']!),
        ));
      } else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['error']!),
        ));
      }
    });
  }

  Future<void> _verifyOTP(String otp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    // Send a POST request with the data
    String urlString =
        (getUsage() == 'sign_up') ? 'auth/register/verify' : 'auth/login';
    final url = Uri.parse('');
    final data = {
      'email': email,
      'otp': otp,
    };

    http.post(url, body: data).then((response) async {
      setState(() {
        _isLoading = false;
      });
      Map<String, dynamic> data = json.decode(response.body);
      // Handle the response from the server as needed
      // Check if the request was successful and handle accordingly
      // ignore: duplicate_ignore
      if ((response.statusCode == 200) && (getUsage() == 'sign_up')) {
        // for (var controller in controllers) {
        //   controller.clear(); // Sets the text to an empty string
        // }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
        ));

        //Profile screen

        // var storage = const FlutterSecureStorage();
        // storage.write(key: 'access', value: data['access']);
        // storage.write(key: 'refresh', value: data['refresh']);

        // To save the isLoggedIn status:
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('user_id', data['user_id']);
        await prefs.setBool('isSignedIn', true);

        await prefs.setBool('isSignedUp', true);

        // ignore: use_build_context_synchronously
        _navigateToNextScreen(
          context,
          'sign_up',
        );
      } else if (((response.statusCode == 202) ||
              (response.statusCode == 200)) &&
          (getUsage() == 'sign_in')) {
        print(data.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
        ));
        // var storage = const FlutterSecureStorage();
        // storage.write(key: 'access', value: data['access']);
        // storage.write(key: 'refresh', value: data['refresh']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('user_id', data['user_id']);
        await prefs.setBool('isSignedUp', true);
        await prefs.setBool('isSignedIn', true);

        if (response.statusCode == 202) {
          // ignore: use_build_context_synchronously
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (context) => const UserProfileForm()),
          //   (route) => false,
          // );
        }

        if (response.statusCode == 200) {
          print(data['name'] + data['country_code'] + data['mobile_number']);
          if (kDebugMode) {
            print(data['name']);
          }
          prefs.setString('role', data['role'].toString());
          prefs.setString('name', data['name'].toString());
          prefs.setString('countryCode', data['country_code']);
          prefs.setString('mobileNumber', data['mobile_number']);
          if (data['role'] == 'Passenger') {
            print('Passenger ID:${data['passenger_id']}');
            await prefs.setInt('passenger_id', data['passenger_id']);
            print('passenger Id set');
          } else if (data['role'] == 'Driver') {
            await prefs.setInt('passenger_id', data['passenger_id']);
            await prefs.setInt('driver_id', data['driver']);
            await prefs.setString('driver_type', data['type']);
          }

          _navigateToNextScreen(
            context,
            'home',
          );
        }
      } else {
        // print(data.toString());
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['error']),
        ));
      }
    });
  }

  // You can make your API request here, for example, using the http package.

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Stack(
          children: [
            Visibility(
              visible: !_isLoading,
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.1),
                    Text(
                      '${(getUsage() == 'sign_up') ? 'Account' : (getUsage() == 'sign_in') ? 'Sign In' : ''} Verification',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.025), // Add spacing
                    const Text(
                      'Enter OTP sent to your email address',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: height * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          width: width * 0.11,
                          height: height * 0.065,
                          margin: const EdgeInsets.all(
                              4), // Add margin for spacing between fields
                          decoration: BoxDecoration(
                            color: Colors.white, // Set the background color
                            borderRadius:
                                BorderRadius.circular(8), // Add rounded corners
                          ),

                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (event) => handleBackspace(event, index),
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                counterText: '', // Hide character counter
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Apply bold font weight
                                  fontSize: 18,
                                  color: Colors.black
                                  // Adjust font size as needed
                                  ),
                              onChanged: (value) async {
                                if (value.isNotEmpty) {
                                  if (index < 5) {
                                    // Move the focus to the next field
                                    FocusScope.of(context)
                                        .requestFocus(focusNodes[index + 1]);
                                  } else {
                                    // All digits have been entered
                                    // You can trigger the verification here
                                    String otp = controllers
                                        .map((controller) => controller.text)
                                        .join();
                                    await Future.delayed(const Duration(seconds: 1));
                                    setState(() {
                                      _isLoading = true; // Show loading icon
                                    });
                                    _verifyOTP(otp);
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Didn\'t recieve OTP? ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Resend OTP',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 14, 156, 19),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _isLoading = true; // Show loading icon
                                });
                                // Make API call with email address for otp resend
                                _resendOTP();
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
             const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context, String screen) async {
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (screen == "sign_up") {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   createRoute(const UserProfileForm()),
        //   (route) => false,
        // );
      } else if (screen == "home") {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   createRoute(
        //     const Home(),
        //   ),
        //   (route) => false,
        // );
      }
    });
  }
}
