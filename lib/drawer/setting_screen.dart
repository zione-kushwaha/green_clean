import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:green_theme/auth/welcome_screen.dart';
import 'package:green_theme/providers/themeProvider.dart';
import 'package:green_theme/route_animation.dart';
import 'package:provider/provider.dart';

class setting_screen extends StatefulWidget {
  const setting_screen({super.key});

  @override
  State<setting_screen> createState() => _setting_screenState();
}

class _setting_screenState extends State<setting_screen> {
 bool temp=false;
 late FirebaseAuth _auth;
  @override
  Widget build(BuildContext context) {
  ThemeProvider provider=Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title:const Text('Setting'),
        centerTitle: true,
       
        actions: [
        IconButton(onPressed: (){
          setState(() {
            provider.toggleTheme();
          });
        }, icon:  provider.currenttheme()?const Icon(Icons.dark_mode):const Icon(Icons.light_mode))
        ],
      ),
      body: Center(
        child: Container(
          height: 100,
          width: 200,
          child: SwitchListTile(value: temp, onChanged: (val)async{
            setState(() {
              temp=val;
            });
          _navigateToNextScreen(context, 'welcome');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('logout Successful')));
          await _auth.signOut();
            
          },
          title: const Text('Logout'),),
        ),
      )
    );
  }
   void _navigateToNextScreen(BuildContext context, String screen) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (screen == "welcome") {
        Navigator.of(context).pushReplacement(createRoute(const Welcome()));
      }
    });
  }
}