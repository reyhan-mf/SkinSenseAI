import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotAi extends StatefulWidget {
  const ChatbotAi({super.key});

  @override
  State<ChatbotAi> createState() => _ChatbotAiState();
}

class _ChatbotAiState extends State<ChatbotAi>
    with SingleTickerProviderStateMixin {
  final _chatInputController = TextEditingController();
  final List<Message> _messages = [];
  final _firestore = FirebaseFirestore.instance;
  bool _initialMessageSent = false;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Buang ScrollController
    super.dispose();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _saveMessageToFirestore(String message, bool isUser) {
    _firestore.collection('chat_messages').add({
      'message': message,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> fetchBotResponse(String message) async {
    final url = Uri.parse('http://localhost:5000/chat');
    final response = await http.post(
      url,
      body: jsonEncode({'message': message}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      throw Exception('Failed to fetch bot response');
    }
  }

  void _sendMessage(String message) {
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(text: message, isUser: true));
      if (!_initialMessageSent) {
        _initialMessageSent = true;
      }
    });
    _chatInputController.clear();
    _simulateBotResponse(message);
  }

  void _simulateBotResponse(String message) async {
    setState(() {
      _isLoading = true;
      _messages.add(Message(text: '', isUser: false)); // Placeholder
    });

    await Future.delayed(Duration(seconds: 1)); // Simulate typing delay

    try {
      final botResponse = await fetchBotResponse(message);
      setState(() {
        // Remove placeholder message
        _messages.removeWhere((m) => m.text == '');
        _messages.add(Message(text: botResponse, isUser: false));
        _isLoading = false;
      });
      _saveMessageToFirestore(botResponse, false);
    } catch (e) {
      setState(() {
        // Remove placeholder message
        _messages.removeWhere((m) => m.text == '');
        _messages.add(Message(
            text: 'Terjadi kesalahan, silakan coba lagi', isUser: false));
        _isLoading = false;
      });
    }

    _scrollToBottom(); // Scroll ke bawah setelah menerima respon
  }

  void _scrollToBottom() {
    // Panjang maksimum scroll untuk scroll ke bagian paling bawah
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
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
        // Jika pengguna mengkonfirmasi keluar
        for (final message in _messages) {
          _saveMessageToFirestore(message.text, message.isUser);
        }
        exit = true; // Set exit menjadi true
      },
    ).show();

    return exit; // Mengembalikan nilai exit
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Mengetahui apakah keyboard aktif
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await _showExitDialog(context);
        return exitConfirmed;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "SkinSenseAI",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(51, 105, 255, 1)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: -screenHeight * 0.2,
              right: -screenWidth * 0.2,
              child: Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.4,
                decoration: BoxDecoration(
                  color: const Color(0x5353B4C4).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -screenHeight * 0.25,
              left: -screenWidth * 0.25,
              child: Container(
                width: screenWidth * 1.1,
                height: screenHeight * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0x5353B4C4).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Jika welcome message belum dikirim
                  if (!_initialMessageSent)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 120),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Selamat datang di SkinSenseAI!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Saya siap membantu Anda dengan informasi seputar berbagai penyakit kulit, gejala, penanganan awal, dan tips perawatan. Silakan ajukan pertanyaan Anda, dan saya akan memberikan jawaban yang informatif dan jelas.",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
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
                        SizedBox(height: 30),
                      ],
                    ),

                  // Daftar pesan
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController, // Menambahkan controller
                      child: Column(
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return ListTile(
                                title: Align(
                                  alignment: message.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: message.isUser
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF3369FF),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            message.text,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        28, 158, 158, 158),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(20),
                                                      topRight:
                                                          Radius.circular(20),
                                                      bottomLeft:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: _isLoading &&
                                                          message.text.isEmpty
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            BouncingDot(
                                                                animation:
                                                                    _animation),
                                                            SizedBox(width: 5),
                                                            BouncingDot(
                                                                animation:
                                                                    _animation),
                                                            SizedBox(width: 5),
                                                            BouncingDot(
                                                                animation:
                                                                    _animation),
                                                          ],
                                                        )
                                                      : Text(
                                                          message.text,
                                                          style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Input area
                   // Input area
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.only(
                        bottom: isKeyboardVisible
                            ? 0
                            : 20), // Padding ketika keyboard tidak aktif
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.2),
                            offset: Offset(0, -8),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatInputController,
                                decoration: InputDecoration(
                                  hintText: "Tanyakan Pada AI...",
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                onSubmitted: (value) {
                                  _sendMessage(value);
                                  _scrollToBottom(); // Scroll ke bawah saat mengirim pesan
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_chatInputController.text.isNotEmpty) {
                                  _sendMessage(_chatInputController.text);
                                  _scrollToBottom(); // Scroll ke bawah saat mengirim pesan
                                }
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class BouncingDot extends StatelessWidget {
  final Animation<double> animation;

  const BouncingDot({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(animation),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
