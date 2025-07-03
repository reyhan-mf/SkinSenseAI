import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:skinsensai/profile/profile.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _updateProfile() async {
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validasi input
    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showAwesomeSnackbar("Semua kolom harus diisi.", ContentType.warning);
      return;
    }

    // Validasi username tidak boleh mengandung spasi
    if (username.contains(' ')) {
      _showAwesomeSnackbar(
          "Username tidak boleh mengandung spasi.", ContentType.warning);
      return;
    }

    // Validasi email harus mengandung '@'
    if (!email.contains('@')) {
      _showAwesomeSnackbar(
          "Email tidak valid. Pastikan mengandung '@'.", ContentType.warning);
      return;
    }

    // Validasi password harus minimal 8 karakter
    if (password.length < 8) {
      _showAwesomeSnackbar(
          "Password harus memiliki minimal 8 karakter.", ContentType.warning);
      return;
    }

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String currentEmail = currentUser.email ?? '';

        // Cek apakah email yang dimasukkan sesuai dengan email di Firebase
        if (_emailController.text != currentEmail) {
          _showAwesomeSnackbar(
              "Email tidak cocok dengan yang terdaftar!", ContentType.failure);
          return;
        }

        // Lakukan update data ke Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'name': name,
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Reauthenticate the user.
        // AuthCredential credential = EmailAuthProvider.credential(
        //   email: _emailController.text,
        //   password: currentPassword,
        // );
        // await user?.reauthenticateWithCredential(credential);

        // If reauthentication is successful, change the password.
        await currentUser.updatePassword(_passwordController.text);

        _showAwesomeSnackbar(
            "Profil berhasil diperbarui!", ContentType.success);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
          // Hapus semua route sebelumnya
        );
      }
    } catch (e) {
      _showAwesomeSnackbar("Gagal memperbarui profil", ContentType.failure);
    }
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _name = userDoc['name'];
        _username = userDoc['username'];
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 41),
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
                        'Data Diri',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _name ?? 'Loading...',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text('@${_username ?? 'Loading...'}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey)),
                  const SizedBox(height: 30),
                  // TextField untuk Nama Lengkap
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan Nama Lengkap',
                      labelStyle: TextStyle(
                        color: Colors.black, // Warna hint saat tidak fokus
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color:
                                Colors.black), // Warna border saat tidak fokus
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Colors.black), // Warna border saat fokus
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // TextField untuk Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan Email',
                      labelStyle: TextStyle(
                        color: Colors.black, // Warna hint saat tidak fokus
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color:
                                Colors.black), // Warna border saat tidak fokus
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Colors.black), // Warna border saat fokus
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // TextField untuk Username
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan Username',
                      labelStyle: TextStyle(
                        color: Colors.black, // Warna hint saat tidak fokus
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color:
                                Colors.black), // Warna border saat tidak fokus
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Colors.black), // Warna border saat fokus
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Masukkan password',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Tombol Update Profil
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Color.fromRGBO(83, 181, 196, 1),
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
