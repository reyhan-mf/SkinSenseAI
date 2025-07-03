import 'package:flutter/material.dart';  
import 'package:flutter/services.dart';  
import 'package:skinsensai/chatbot/chatbot.dart';  

class ChatbotAi extends StatefulWidget {  
  const ChatbotAi({super.key});  

  @override  
  State<ChatbotAi> createState() => _ChatbotAiState();  
}  

class _ChatbotAiState extends State<ChatbotAi> {  
  @override  
  Widget build(BuildContext context) {  
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(  
      statusBarColor: Colors.transparent,  
      statusBarIconBrightness: Brightness.dark,  
    ));  
    return Scaffold(  
      backgroundColor: Colors.white,  
      extendBodyBehindAppBar: true,  
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
            ),  
          ),  
          SingleChildScrollView(  
            child: Column(  
              mainAxisAlignment: MainAxisAlignment.start,  
              children: [  
                SizedBox(height: 55), // Space for the status bar  
                Row(  
                  children: [  
                    IconButton(  
                      padding: EdgeInsets.only(left: 22, right: 10),  
                      icon: const Icon(  
                        Icons.arrow_back,  
                        size: 30,  
                      ),  
                      onPressed: () {  
                        Navigator.pop(context);  
                      },  
                    ),  
                    Expanded(  
                      child: Text(  
                        "SkinSenseAI",  
                        textAlign: TextAlign.left, // Align text to the left  
                        style: TextStyle(  
                          fontSize: 30,  
                          fontWeight: FontWeight.w700,  
                          color: const Color.fromRGBO(51, 105, 255, 1),  
                        ),  
                      ),  
                    ),  
                  ],  
                ),  
                SizedBox(height:200),  
                Text(  
                  "Selamat datang di SkinSenseAI!",  
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),  
                  textAlign: TextAlign.center,  
                ),  
                SizedBox(height: 30),  
                Container(  
                  padding: EdgeInsets.symmetric(horizontal: 40),  
                  child: Text(  
                    "Saya siap membantu Anda dengan informasi seputar berbagai penyakit kulit, gejala, penanganan awal, dan tips perawatan. Silakan ajukan pertanyaan Anda, dan saya akan memberikan jawaban yang informatif dan jelas.",  
                    style: TextStyle(fontSize: 14),  
                    textAlign: TextAlign.center,  
                  ),  
                ),  
                SizedBox(height: 30),  
                Padding(  
                  padding: EdgeInsets.symmetric(horizontal: 60),  
                  child: Text(  
                    "Disclaimer: Informasi yang diberikan oleh chatbot ini bersifat edukatif dan bukan pengganti saran medis profesional. Untuk diagnosis dan perawatan yang akurat, konsultasikan dengan dokter atau ahli dermatologi.",  
                    style: TextStyle(  
                      fontSize: 14,  
                      color: Colors.grey,  
                      fontStyle: FontStyle.italic,  
                    ),  
                    textAlign: TextAlign.center,  
                  ),  
                ),  
              ],  
            ),  
          ),  
        ],  
      ),  
      bottomNavigationBar: Container(  
        height: 90,  
        decoration: BoxDecoration(  
          color: Colors.white,  
          borderRadius: BorderRadius.only(  
            topLeft: Radius.circular(40),  
            topRight: Radius.circular(40),  
          ),  
          boxShadow: [  
            BoxShadow(  
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),  
              offset: Offset(0, -8),  
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
              Text(  
                "Mulailah chat dengan SkinSenseAI",  
                style: TextStyle(  
                  color: const Color(0xFF067CDD),  
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
      ),  
    );  
  }  
}