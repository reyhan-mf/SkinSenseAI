import 'package:flutter/material.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  

class ForgotPasswordScreen extends StatefulWidget {  
  @override  
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();  
}  

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {  
  final TextEditingController _emailController = TextEditingController();  
  final FirebaseAuth _auth = FirebaseAuth.instance;  

  void _sendPasswordResetEmail() async {  
    String email = _emailController.text.trim();  

    if (email.isEmpty) {  
      _showAwesomeSnackbar("Email harap diisi.", ContentType.warning);  
      return;  
    }  

    try {  
      await _auth.sendPasswordResetEmail(email: email);  
      _showAwesomeSnackbar(  
          "Instruksi reset password telah dikirim ke email Anda.", ContentType.success);  
      Navigator.pop(context); // Kembali ke halaman LoginScreen  
    } on FirebaseAuthException catch (e) {  
      _showAwesomeSnackbar("Terjadi kesalahan: ${e.message}", ContentType.failure);  
    } catch (e) {  
      _showAwesomeSnackbar("Terjadi kesalahan: $e", ContentType.failure);  
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
      behavior: SnackBarBehavior.floating,  
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
                            'Lupa Password',  
                            style: TextStyle(  
                                fontSize: 24, fontWeight: FontWeight.bold),  
                          ),  
                          Text('Masukkan email Anda'),  
                        ],  
                      ),  
                      SizedBox(width: 10),  
                      Icon(Icons.lock_outline, size: 30),  
                    ],  
                  ),  
                  const SizedBox(height: 65),  
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
                        borderSide: const BorderSide(  
                            color: Colors.black),  
                      ),  
                      focusedBorder: OutlineInputBorder(  
                        borderRadius: BorderRadius.circular(8),  
                        borderSide: const BorderSide(  
                            color: Colors.black),  
                      ),  
                    ),  
                  ),  
                  const SizedBox(height: 24),  
                  ElevatedButton(  
                    onPressed: _sendPasswordResetEmail,  
                    style: ElevatedButton.styleFrom(  
                      backgroundColor: const Color.fromRGBO(85, 182, 198, 1),  
                      minimumSize: const Size(double.infinity, 50),  
                      shape: RoundedRectangleBorder(  
                          borderRadius: BorderRadius.circular(8)),  
                    ),  
                    child: const Text(  
                      'Kirim Instruksi Reset Password',  
                      style: TextStyle(  
                          fontSize: 18,  
                          color: Colors.black),  
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