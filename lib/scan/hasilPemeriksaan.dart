import 'dart:convert'; // Import for JSON decoding
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart'; // Make sure you have appropriate import for AwesomeDialog
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skinsensai/chatbot/chatbot.dart';
import 'package:skinsensai/home.dart';

class HasilPemeriksaanScreen extends StatefulWidget {
  final String responseMessage; // Variabel untuk menyimpan response
  final File croppedImage; // Variabel untuk menyimpan gambar cropped

  const HasilPemeriksaanScreen(
      {Key? key, required this.responseMessage, required this.croppedImage})
      : super(key: key); // Modifikasi constructor

  @override
  State<HasilPemeriksaanScreen> createState() => _HasilPemeriksaanScreenState();
}

class _HasilPemeriksaanScreenState extends State<HasilPemeriksaanScreen> {
  void _showAwesomeSnackbar(String message, ContentType contentType) {
    final snackBar = SnackBar(
      content: AwesomeSnackbarContent(
        title: contentType == ContentType.warning
            ? 'Peringatan'
            : contentType == ContentType.success
                ? 'Sukses'
                : 'Kesalahan',
        message: message,
        contentType: contentType,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.fixed,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

 Future<void> _showExitDialog(BuildContext context) async {
  await AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.rightSlide,
    title: 'Keluar',
    desc: 'Apakah anda ingin mengakhiri sesi?',
    btnCancelOnPress: () {},
    btnOkOnPress: () {
      // Navigate to the homepage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,  // Clears all previous routes
      );
    },
  ).show();
}


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Mendapatkan kelas, confidence dan deskripsi
    String className =
        jsonDecode(widget.responseMessage)['predictions'][0]['class'];
    double confidence = jsonDecode(widget.responseMessage)['predictions'][0]
        ['confidence']; // Mendapatkan confidence
    String description = jsonDecode(
        widget.responseMessage)['deskripsi']; // Mendapatkan deskripsi

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 10),
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(children: [
              _buildBackgroundCircles(),
            ]),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 55),
                // Menampilkan confidence di atas
                Text(
                  'Confidence: ${(confidence * 100).toStringAsFixed(2)}%', // Mengonversi ke format persentase
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.file(
                    widget.croppedImage,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  className,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13, // Mengubah ukuran teks menjadi 13
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify, // Justifikasi teks
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: -160,
          right: -100,
          child: Container(
            width: 400,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0x5353B4C4).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: -180,
          left: -140,
          child: Container(
            width: 550,
            height: 350,
            decoration: BoxDecoration(
              color: const Color(0x5353B4C4).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Container _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
            offset: const Offset(0, -8),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Ingin tanyakan lebih lanjut?",
              style: TextStyle(
                color: Color(0xFF067CDD),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const chatbot()),
                );
                print('Button send ditekan');
              },
              child: Image.asset(
                'assets/images/Button_send.png',
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
