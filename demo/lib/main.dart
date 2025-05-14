import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'firebase_options.dart';
import 'components/navigation_bar.dart';
import 'package:demo/pages/login.dart';
import 'package:demo/pages/register.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart'; 
import 'package:go_router/go_router.dart';               
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';    

import 'app_state.dart';                 
import 'models/user_model.dart';
import 'providers/user_provider.dart';

/// The entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    //options: const FirebaseOptions(
    //  apiKey: "AIzaSyCg7qduu8ujfo0yfITSaLXtnwWyQyq1Wfw",
    //  appId: "1:317555003935:android:36e35d6e3d27e984afbb2a",
    //  messagingSenderId: "317555003935",
    //  projectId: "wildlifeer-29cec",
    //),
  );
  debugPaintSizeEnabled = false; 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const NavigationBarApp(),
    ),
  );
}

/// The root widget of the application that sets up routing and theming.
class NavigationBarApp extends StatelessWidget {
  /// Creates a [NavigationBarApp] widget.
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavigationExample(),
      }
    );
  }
}
