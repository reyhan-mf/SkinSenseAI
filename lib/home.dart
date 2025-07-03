import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skinsensai/chatbot/awal_chat.dart';
import 'package:skinsensai/history/listhistory.dart';
import 'package:skinsensai/profile/profile.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:skinsensai/scan/kamera.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return WillPopScope(
      onWillPop: () async {
        // Menampilkan AwesomeDialog saat tombol back ditekan
        bool exitConfirmed = await _showExitDialog(context);
        return exitConfirmed;
      },
      child: Scaffold(
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
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Ayo deteksi dini',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Penyakit Kulitmu',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_outline,
                              size: 40, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfilePage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const Text(
                      'Sekarang!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildButton(
                      context,
                      imagePath: 'assets/images/bg1.png',
                      iconPath: 'assets/images/icon1.png',
                      text: 'Foto dan Deteksi Sekarang!',
                      onPressed: () {
                        // Aksi ketika tombol ditekan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CameraScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      context,
                      imagePath: 'assets/images/bg2.png',
                      iconPath: 'assets/images/icon2.png',
                      text: 'Riwayat Pencarian',
                      onPressed: () {
                        // Aksi ketika tombol ditekan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryGallery()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      context,
                      imagePath: 'assets/images/bg3.png',
                      iconPath: 'assets/images/icon3.png',
                      text: 'Mulai Chat dengan AI',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatbotAi()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    bool exit = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: 'Keluar',
      desc: 'Apakah anda yakin untuk keluar?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        exit = true;
        SystemNavigator.pop();
      },
    ).show();

    return exit;
  }

  Widget _buildButton(
    BuildContext context, {
    required String
        imagePath, // Menambahkan parameter untuk gambar latar belakang
    required String iconPath, // Menambahkan parameter untuk gambar ikon
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath), // Menggunakan gambar dari asset
          fit: BoxFit.cover, // Mengatur cara gambar ditampilkan
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  iconPath, // Menggunakan gambar dari asset sebagai ikon
                  width: 58, // Atur lebar gambar ikon
                  height: 58, // Atur tinggi gambar ikon
                ),
                const Icon(Icons.arrow_forward, size: 28, color: Colors.white),
              ],
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
