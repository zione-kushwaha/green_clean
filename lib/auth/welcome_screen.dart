import 'package:flutter/material.dart';
import 'package:green_theme/auth/SignScreen.dart';
import 'package:green_theme/auth/SignUpScreen.dart';
import 'package:green_theme/route_animation.dart';


class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(
          color: Colors.white, // Set text color based on theme brightness
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: height * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset('assets/images/welcome.png'),
            ),
            SizedBox(height: height * 0.026),
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.014),
            const Text('Plant Green, Breadth Clean'),
            SizedBox(height: height * 0.014),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add create account button functionality here
                      _navigateToNextScreen(context, "sign_up");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: SizedBox(
                      height: height * 0.065,
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
                SizedBox(height: height * 0.014),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add login button functionality here
                      _navigateToNextScreen(context, "sign_in");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 0.5),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: SizedBox(
                      height: height * 0.065,
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context, String screen) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (screen == "sign_up") {
        Navigator.of(context).push(createRoute(const SignUpScreen()));
      } else if (screen == "sign_in") {
        Navigator.of(context).push(createRoute(const SignInScreen()));
      }
    });
  }
}
