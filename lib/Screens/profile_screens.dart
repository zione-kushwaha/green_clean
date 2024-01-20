import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:green_theme/Screens/chat_screen.dart';
import 'package:green_theme/Screens/image_response.dart';
import 'package:green_theme/Screens/query_section.dart';
import 'package:green_theme/Screens/webview.dart';
import 'package:green_theme/detail/detail.dart';
import 'package:green_theme/detail/information.dart';
import 'package:green_theme/detail/weather.dart';
import 'package:green_theme/drawer/drawer.dart';
import 'package:green_theme/route_animation.dart';

class ProfileScreen extends StatelessWidget {
  String username;
  String email;
  ProfileScreen({super.key, required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome!!!'),
          centerTitle: true,
        ),
        drawer: Drawer_section(),
        body: TabBarView(children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 0.01 * height,
                ),
                CarouselSlider.builder(
                  itemCount: 6,
                  options: CarouselOptions(
                    autoPlayInterval: const Duration(seconds: 2),
                    autoPlayAnimationDuration: const Duration(seconds: 1),
                    height: 200.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return Card(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset('assets/images/$index.jpg',fit: BoxFit.cover,),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15,),
                GestureDetector(
                  onTap: () {
                    _navigateToNextScreen(context, 'chat');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(13),
                    height: height * 0.09,
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.pink.withOpacity(0.8),
                        Colors.pink.withOpacity(0.6),
                        Colors.pink.withOpacity(0.4)
                      ],),
                    ),
                    child: const Center(
                      child: Text(
                        "Chat  Section",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _navigateToNextScreen(context, 'query');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(13),
                    height: height * 0.09,
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.green.withOpacity(0.9),
                        Colors.green.withOpacity(0.7),
                        Colors.green.withOpacity(0.4)
                      ],),
                    ),
                    child: const Center(
                      child: Text(
                        "Query  Section",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _navigateToNextScreen(context, 'image');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(13),
                    height: height * 0.09,
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.red.withOpacity(0.9),
                        Colors.red.withOpacity(0.7),
                        Colors.red.withOpacity(0.4)
                      ],),
                    ),
                    child: const Center(
                      child: Text(
                        "Image response Section",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _navigateToNextScreen(context, 'web');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(13),
                    height: height * 0.09,
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.yellow.withOpacity(0.9),
                        Colors.yellow.withOpacity(0.8),
                        Colors.yellow.withOpacity(0.5),
                      ],),
                    ),
                    child: const Center(
                      child: Text(
                        "More Detail section",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        
         detail_screen(),
         BingSearch(),
          weatherdata(),
        ]),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(text: 'Home'),
            Tab(text: 'Details'),
            Tab(text: 'info',),
            Tab(text: 'weather',)
          ],
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context, String screen) {
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (screen == "chat") {
        Navigator.of(context).push(createRoute(const ChatScreen()));
      } else if (screen == "query") {
        Navigator.of(context).push(createRoute(const querySection()));
      } else if (screen == 'image') {
        Navigator.of(context).push(createRoute(const TextAndImageInputScreen()));
      } else if (screen == 'web') {
        Navigator.of(context).push(createRoute(const WebViewExample()));
      }
    });
  }
}
