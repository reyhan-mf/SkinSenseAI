import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Text(
                          'Tentang',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Skin',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'SenseAI',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(85, 182, 198, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                    'SkinSense adalah aplikasi berbasis kecerdasan buatan (AI) yang dirancang untuk mendeteksi dini penyakit kulit dengan cepat dan akurat. Dengan memanfaatkan data dan teknologi terbaru, SkinSense mampu menganalisis gambar kulit pengguna dan memberikan hasil diagnosa awal yang dapat membantu mendeteksi potensi masalah kulit, seperti infeksi, kanker kulit, atau kondisi dermatologis lainnya.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ),
                              const SizedBox(height: 10),
                              Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                                endIndent: 8,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  'Disusun Oleh:\nReyhan Mochamad Fabian\nFahmi Nursafaat\nMuhammad Fajar Jati Permana',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                            ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
