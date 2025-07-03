import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:skinsensai/test_crop.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyC7urm9fqLiCiXS9bhn4cK9ZZR9utaM9A8",
            authDomain: "skinsense-6f085.firebaseapp.com",
            projectId: "skinsense-6f085",
            storageBucket: "skinsense-6f085.appspot.com",
            messagingSenderId: "292241377490",
            appId: "1:292241377490:web:cf9a37a3cbd875e155c50b"));
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC7urm9fqLiCiXS9bhn4cK9ZZR9utaM9A8",
        authDomain: "skinsense-6f085.firebaseapp.com",
        projectId: "skinsense-6f085",
        storageBucket: "skinsense-6f085.appspot.com",
        messagingSenderId: "292241377490",
        appId: "1:292241377490:web:cf9a37a3cbd875e155c50b",
      ),
    );
  }
  runApp(const SkinSenseApp());
}

class SkinSenseApp extends StatelessWidget {
  const SkinSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkinSenseAI',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
