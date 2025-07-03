import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skinsensai/login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signUpWithEmailAndPassword() async {
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
      // Coba untuk mendaftar pengguna baru
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showAwesomeSnackbar(
            "Pendaftaran berhasil. Silahkan Login", ContentType.success);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Menangani kesalahan jika email sudah terdaftar
      if (e.code == 'email-already-in-use') {
        _showAwesomeSnackbar(
            "Email terdaftar. Silakan gunakan email lain", ContentType.warning);
      } else {
        _showAwesomeSnackbar("Terjadi kesalahan", ContentType.failure);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Logout akun Google sebelumnya
      await _googleSignIn.signOut();

      // Sign in dengan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in ke Firebase dengan credential Google
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        User? user = userCredential.user;
        if (user != null) {
          final userDoc =
              await _firestore.collection('users').doc(user.uid).get();

          if (!userDoc.exists) {
            // Buat username dari email (sebelum karakter '@')
            String email = user.email ?? '';
            String username = email.split('@')[0];

            // Menyimpan data pengguna baru ke Firestore
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email,
              'name': user.displayName,
              'username': username,
              'createdAt': FieldValue.serverTimestamp(),
            });

            // Menampilkan alert berhasil daftar dan pindah ke halaman login
            _showAwesomeSnackbar("Akun berhasil didaftarkan, silakan login",
                ContentType.success);

            // Navigasi ke halaman login setelah menampilkan alert
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            // Menampilkan alert bahwa email sudah terdaftar
            _showAwesomeSnackbar(
                "Email sudah terdaftar, silakan login", ContentType.warning);

            // Navigasi ke halaman login
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showAwesomeSnackbar(
          "Terjadi kesalahan: ${e.message}", ContentType.failure);
    } catch (e) {
      await _googleSignIn.signOut();
      _showAwesomeSnackbar(
          "Terjadi kesalahan selama proses login: $e", ContentType.failure);
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
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 60.0, horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Signup Account',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text('Selamat datang di SkinSenseAI'),
                        ],
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.person_outline, size: 30),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Skin',
                              style: TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'SenseAI',
                              style: TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(85, 182, 198, 1),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan nama lengkap',
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan username',
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Masukkan email',
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
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _signUpWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(85, 182, 198, 1),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Buat Akun',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                            endIndent: 8,
                          ),
                        ),
                        const Text('Atau daftar dengan',
                            style: TextStyle(color: Colors.grey)),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                            indent: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset('assets/images/google_logo.png',
                          height: 30),
                      label:
                          const Text('', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        minimumSize: const Size(70, 60),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.only(left: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun?',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Silahkan Masuk Disini',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
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
