import 'package:flutter/material.dart';
import 'package:skinsensai/login.dart';

class SkinSenseHomePage extends StatelessWidget {
  const SkinSenseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: [
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
              ],
            ),
          ),

          // Konten utama
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 250,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SkinSenseAI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'SkinSense adalah aplikasi berbasis kecerdasan buatan (AI) yang dirancang untuk mendeteksi dini penyakit kulit dengan cepat dan akurat. Dengan memanfaatkan data dan teknologi terbaru, SkinSense mampu menganalisis gambar kulit pengguna dan memberikan hasil diagnosa awal yang dapat membantu mendeteksi potensi masalah kulit, seperti infeksi, kanker kulit, atau kondisi dermatologis lainnya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(85, 182, 198, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 85,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Let’s Start',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
