import 'package:flutter/material.dart';
import 'package:green_theme/drawer/profile_page.dart';
import 'package:green_theme/drawer/setting_screen.dart';
import 'package:green_theme/route_animation.dart';

class Drawer_section extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Jivan kushwaha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'jivankushwaha@google.com',
                    style: TextStyle(
                      color: Colors.white,
                      
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Handle Home option
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                // Handle Profile option
                _navigateToNextScreen(context, 'profile_page');
                Navigator.pop(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                // Handle Home option
                Navigator.pop(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rating'),
              onTap: () {
                // Handle Home option
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                _navigateToNextScreen(context, "setting");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    
  }
  void _navigateToNextScreen(BuildContext context, String screen) {
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (screen == "setting") {
        Navigator.of(context).push(createRoute(const setting_screen()));
      } else if(screen=='profile_page'){
         Navigator.of(context).push(createRoute(const profile_page()));
      }
    });
  }
}
