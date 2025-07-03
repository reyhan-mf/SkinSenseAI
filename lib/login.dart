import 'package:flutter/material.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:google_sign_in/google_sign_in.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:skinsensai/home.dart';  
import 'package:skinsensai/lupa.dart';  
import 'package:skinsensai/signup.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:http/http.dart' as http;  
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // Import JWT library  

class LoginScreen extends StatefulWidget {  
  const LoginScreen({super.key});  

  @override  
  _LoginScreenState createState() => _LoginScreenState();  
}  

class _LoginScreenState extends State<LoginScreen> {  
  final TextEditingController _emailController = TextEditingController();  
  final TextEditingController _passwordController = TextEditingController();  
  final FirebaseAuth _auth = FirebaseAuth.instance;  
  bool _obscurePassword = true;  
  final GoogleSignIn _googleSignIn = GoogleSignIn();  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  

  @override  
  void initState() {  
    super.initState();  
    _checkLoginState();  
  }  

  Future<void> _saveLoginState() async {  
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    await prefs.setBool('isLoggedIn', true);  
  }  

  Future<void> _checkLoginState() async {  
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    bool? isLoggedIn = prefs.getBool('isLoggedIn');  

    if (isLoggedIn == true) {  
      Navigator.pushReplacement(  
        context,  
        MaterialPageRoute(builder: (context) => const HomePage()),  
      );  
    }  
  }  

  Future<void> _signInWithEmailAndPassword() async {  
    String email = _emailController.text.trim();  
    String password = _passwordController.text.trim();  

    if (email.isEmpty || password.isEmpty) {  
      _showAwesomeSnackbar("Email dan Password harap diisi.", ContentType.warning);  
      return;  
    }  

    try {  
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(  
        email: email,  
        password: password,  
      );  

      // Generate JWT token after successful login  
      String token = _generateJwtToken(userCredential.user!.uid);  
      print('Token JWT: $token');  // Better to save the token than just print it  
      await _storeJwtToken(token); // Store token if you plan to use it later  

      _showAwesomeSnackbar("Login berhasil", ContentType.success);  
      await _saveLoginState();  
      Navigator.pushReplacement(  
        context,  
        MaterialPageRoute(builder: (context) => const HomePage()),  
      );  
    } on FirebaseAuthException catch (e) {  
      _showAwesomeSnackbar("Email/Password salah, silakan coba lagi", ContentType.failure);  
      print(e.code); // You can log the error code for debugging  
    }  
  }  

  Future<void> _signInWithGoogle() async {  
    try {  
      await _googleSignIn.signOut();  
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();  
      if (googleUser != null) {  
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;  

        final credential = GoogleAuthProvider.credential(  
          accessToken: googleAuth.accessToken,  
          idToken: googleAuth.idToken,  
        );  

        UserCredential userCredential = await _auth.signInWithCredential(credential);  
        User? user = userCredential.user;  

        if (user != null) {  
          final userDoc = await _firestore.collection('users').doc(user.uid).get();  

          // Create new user document if it doesn't exist in Firestore  
          if (!userDoc.exists) {  
            await _firestore.collection('users').doc(user.uid).set({  
              'email': user.email,  
              'name': user.displayName,  
              'createdAt': FieldValue.serverTimestamp(),  
            });  
          }  

          // Generate JWT token after successful login  
          String token = _generateJwtToken(user.uid);  
          print('Token JWT: $token');  
          await _storeJwtToken(token); // Store token if you plan to use it later  

          _showAwesomeSnackbar("Login berhasil", ContentType.success);  
          await _saveLoginState();  
          Navigator.pushReplacement(  
            context,  
            MaterialPageRoute(builder: (context) => const HomePage()),  
          );  
        }  
      }  
    } on FirebaseAuthException catch (e) {  
      _showAwesomeSnackbar("Terjadi kesalahan: ${e.message}", ContentType.failure);  
    } catch (e) {  
      _googleSignIn.signOut();  
      _showAwesomeSnackbar("Terjadi kesalahan selama proses login: $e", ContentType.failure);  
      print("Terjadi kesalahan selama proses login: $e");  
    }  
  }  

  String _generateJwtToken(String userId) {  
    final jwt = JWT({  
      'sub': userId,  
      'iat': DateTime.now().millisecondsSinceEpoch,  
    });  

    String secret = '556'; // Use a secure key in production  
    return jwt.sign(SecretKey(secret));  
  }  

  Future<void> _storeJwtToken(String token) async {  
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    await prefs.setString('jwt_token', token); // storing token for later use  
    print('JWT Token Stored: $token');  
  }  

  void _showAwesomeSnackbar(String message, ContentType contentType) {  
    final snackBar = SnackBar(  
      content: AwesomeSnackbarContent(  
        title: contentType == ContentType.warning ? 'Peringatan' : contentType == ContentType.success ? 'Sukses' : 'Kesalahan',  
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
          // Background Container  
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
          // Content Container  
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
                            'Login Account',  
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
                  const SizedBox(height: 65),  
                  Row(  
                    mainAxisAlignment: MainAxisAlignment.center,  
                    children: [  
                      RichText(  
                        text: TextSpan(  
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
                    controller: _emailController,  
                    keyboardType: TextInputType.emailAddress,  
                    decoration: InputDecoration(  
                      labelText: 'Masukkan email',  
                      labelStyle: TextStyle(  
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
                      labelStyle: TextStyle(  
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
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,  
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
                  Align(  
                    alignment: Alignment.centerRight,  
                    child: TextButton(  
                      onPressed: () {  
                        Navigator.push(  
                          context,  
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),  
                        );  
                      },  
                      child: const Text(  
                        'Lupa Password?',  
                        style: TextStyle(color: Colors.black),  
                      ),  
                    ),  
                  ),  
                  const SizedBox(height: 24),  
                  ElevatedButton(  
                    onPressed: _signInWithEmailAndPassword,  
                    style: ElevatedButton.styleFrom(  
                      backgroundColor: const Color.fromRGBO(85, 182, 198, 1),  
                      minimumSize: const Size(double.infinity, 50),  
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),  
                    ),  
                    child: const Text(  
                      'Masuk',  
                      style: TextStyle(fontSize: 18, color: Colors.black),  
                    ),  
                  ),  
                  const SizedBox(height: 16),  
                  Center(  
                    child: Row(  
                      mainAxisAlignment: MainAxisAlignment.center,  
                      children: [  
                        Expanded(  
                          child: Divider(color: Colors.grey, thickness: 0.5, endIndent: 8),  
                        ),  
                        const Text('Atau masuk dengan', style: TextStyle(color: Colors.grey)),  
                        Expanded(  
                          child: Divider(color: Colors.grey, thickness: 0.5, indent: 8),  
                        ),  
                      ],  
                    ),  
                  ),  
                  const SizedBox(height: 16),  
                  Center(  
                    child: ElevatedButton.icon(  
                      onPressed: _signInWithGoogle,  
                      icon: Image.asset('assets/images/google_logo.png', height: 30),  
                      label: const Text('', style: TextStyle(color: Colors.black)),  
                      style: ElevatedButton.styleFrom(  
                        shadowColor: Colors.black,  
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),  
                        minimumSize: const Size(70, 60),  
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),  
                        padding: const EdgeInsets.only(left: 10),  
                      ),  
                    ),  
                  ),  
                  const SizedBox(height: 20),  
                  Center(  
                    child: Row(  
                      mainAxisAlignment: MainAxisAlignment.center,  
                      children: [  
                        const Text(  
                          'Belum punya akun?',  
                          style: TextStyle(color: Colors.grey),  
                        ),  
                        TextButton(  
                          onPressed: () {  
                            Navigator.push(  
                              context,  
                              MaterialPageRoute(builder: (context) => const SignupScreen()),  
                            );  
                          },  
                          child: const Text(  
                            'Buat Akun Disini',  
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