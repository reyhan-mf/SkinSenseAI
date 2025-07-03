import 'package:flutter/material.dart';  
import 'started.dart';  

class SplashScreen extends StatefulWidget {  
  const SplashScreen({super.key});  

  @override  
  _SplashScreenState createState() => _SplashScreenState();  
}  

class _SplashScreenState extends State<SplashScreen> {  
  @override  
  void initState() {  
    super.initState();  
    _navigateToHome();  
  }  

  _navigateToHome() async {  
    await Future.delayed(const Duration(seconds: 3), () {});  
    Navigator.pushReplacement(  
      context,  
      MaterialPageRoute(builder: (context) => const SkinSenseHomePage()),  
    );  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Colors.white,  
      body: Stack(  
        children: [  
          // Bulatan di atas  
          Positioned(  
            top: -140,  
            right: -120,  
            child: Container(  
              width: 300,  
              height: 300,  
              decoration: const BoxDecoration(  
                color: Color.fromRGBO(81, 181, 196, 0.3),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),  
          Positioned(  
            top: -160,  
            right: 40,  
            child: Container(  
              width: 350,  
              height: 350,  
              decoration: const BoxDecoration(  
                color: Color.fromRGBO(83, 181, 196, 0.2),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),  

          // Logo di tengah  
          Center(  
            child: Image.asset(  
              'assets/images/logo.png',  
              height: 250,  
            ),  
          ),  

          // Bulatan di bawah  
          Positioned(  
            bottom: -140,  
            right: -120,  
            child: Container(  
              width: 300,  
              height: 300,  
              decoration: const BoxDecoration(  
                color: Color.fromRGBO(81, 181, 196, 0.3),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),   
          Positioned(  
            bottom: -160,  
            right: 40,  
            child: Container(  
              width: 350,  
              height: 350,  
              decoration: const BoxDecoration(  
                color: Color.fromRGBO(83, 181, 196, 0.2),  
                shape: BoxShape.circle,  
              ),  
            ),  
          ),  
        ],  
      ),  
    );  
  }  
}