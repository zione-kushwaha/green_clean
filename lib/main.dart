import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:green_theme/auth/welcome_screen.dart';
import 'package:green_theme/providers/themeProvider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
   Gemini.init(apiKey: 'AIzaSyD0X6fPUT-tXaV_MxI4CdGMv-M9lj-1BSU');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child){
          return MaterialApp(
         theme: themeProvider.currentTheme,
          debugShowCheckedModeBanner: false,
         
          home: const Welcome(),
        );
        }
        ,
      ),
    );
  }
}

