import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skinsensai/login.dart';
import 'package:skinsensai/profile/about.dart';
import 'package:skinsensai/profile/update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name;
  String? _email;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _name = userDoc['name'];
        _email = userDoc['email'];
        _username = userDoc['username'];
      });
    }
  }

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Profile',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF53B4C4),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/images/profile.png'),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name ?? 'Loading...',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                '@${_username ?? 'Loading...'}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Email Card - Disable hover color changes
                    Card(
                      elevation: 5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.email_outlined,
                            size: 30, color: Color.fromRGBO(83, 180, 196, 0.7)),
                        title: const Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _email ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // "Akun Saya", "Tentang Aplikasi", "Keluar" Cards with shadow and border
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.grey.withOpacity(0.5), // Shadow abu-abu
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 5), // Posisi shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Card untuk "Akun Saya"
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(Icons.person_2_outlined,
                                  size: 30,
                                  color: Color.fromRGBO(83, 180, 196, 0.7)),
                              title: const Text(
                                'Akun Saya',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Buat perubahan pada akun Anda',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UpdateProfilePage()),
                                );
                              },
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 0.1,
                          ), // Divider untuk memisahkan setiap card

                          // Card untuk "Tentang Aplikasi"
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(Icons.info_outline,
                                  color: Color.fromRGBO(83, 180, 196, 0.7)),
                              title: const Text(
                                'Tentang Aplikasi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Detail informasi aplikasi ini dibuat',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AboutPage()),
                                );
                              },
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 0.1,
                          ),

                          // Card untuk "Keluar"
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(Icons.logout,
                                  color: Color.fromRGBO(83, 180, 196, 0.7)),
                              title: const Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Amankan akun Anda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              onTap: () {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.rightSlide,
                                  title: 'Keluar',
                                  desc: 'Apakah anda yakin untuk keluar?',
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () async {
                                    // Hapus status login dari SharedPreferences
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.remove('isLoggedIn');

                                    // Sign out dari Firebase Authentication
                                    await _auth.signOut();

                                    // Arahkan ke layar LoginScreen dan hapus semua route sebelumnya
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()),
                                      (Route<dynamic> route) =>
                                          false, // Hapus semua route sebelumnya
                                    );
                                  },
                                ).show();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          const Text('Help & Support'),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets
                                      .zero, // Hilangkan padding default
                                  minimumSize: Size(0,
                                      0), // Atur minimumSize menjadi nol agar tidak ada ukuran tambahan
                                  shadowColor: Colors.black,
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        50), // Sesuaikan bentuk button
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/telegram.png',
                                  height: 30,
                                  width: 30,
                                ),
                                onPressed: () async {
                                  final Uri url =
                                      Uri.parse('https://web.telegram.org/a/');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets
                                      .zero, // Hilangkan padding default
                                  minimumSize: Size(0,
                                      0), // Atur minimumSize menjadi nol agar tidak ada ukuran tambahan
                                  shadowColor: Colors.black,
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        50), // Sesuaikan bentuk button
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/wa.png',
                                  height: 30,
                                  width: 30,
                                ),
                                onPressed: () async {
                                  final Uri url =
                                      Uri.parse('https://web.whatsapp.com/');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets
                                      .zero, // Hilangkan padding default
                                  minimumSize: Size(0,
                                      0), // Atur minimumSize menjadi nol agar tidak ada ukuran tambahan
                                  shadowColor: Colors.black,
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        50), // Sesuaikan bentuk button
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/ig.png',
                                  height: 30,
                                  width: 30,
                                ),
                                onPressed: () async {
                                  final Uri url =
                                      Uri.parse('https://www.instagram.com/');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets
                                      .zero, // Hilangkan padding default
                                  minimumSize: Size(0,
                                      0), // Atur minimumSize menjadi nol agar tidak ada ukuran tambahan
                                  shadowColor: Colors.black,
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        50), // Sesuaikan bentuk button
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/fb.png',
                                  height: 30,
                                  width: 30,
                                ),
                                onPressed: () async {
                                  final Uri url =
                                      Uri.parse('https://www.facebook.com/');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
