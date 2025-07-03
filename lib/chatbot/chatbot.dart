import 'package:flutter/material.dart';  
import 'package:flutter/services.dart';  
import 'package:http/http.dart' as http;  
import 'dart:convert';  
import 'package:shared_preferences/shared_preferences.dart';  

class chatbot extends StatefulWidget {  
  const chatbot({super.key});  

  @override  
  State<chatbot> createState() => _chatbotState();  
}  

final _chatInputController = TextEditingController();  

class Message {  
  final String text;  
  final bool isUser;  

  Message({required this.text, required this.isUser});  
}  

class _chatbotState extends State<chatbot> with SingleTickerProviderStateMixin {  
  final List<Message> _messages = [  
    Message(text: "Haloo, Apa Kabar apakah ada yang ingin ditanyakan?", isUser: false),  
  ];  

  final _scrollController = ScrollController();  
  bool _isLoading = false; // Track loading state  
  late AnimationController _controller;  
  late Animation<double> _animation;  

  @override  
  void initState() {  
    super.initState();  
    _controller = AnimationController(  
      duration: const Duration(milliseconds: 600),  
      vsync: this,  
    )..repeat(reverse: true);  
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);  
  }  

  @override  
  void dispose() {  
    _controller.dispose();  
    super.dispose();  
  }  

  Future<String> _getJwt() async {  
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    return prefs.getString('jwt_token') ?? ''; // Get JWT from storage  
  }  

  Future<void> _sendMessage(String message) async {  
    if (message.isEmpty) return;  

    setState(() {  
      _messages.add(Message(text: message, isUser: true));  
    });  
    _chatInputController.clear();  
    _scrollToBottom();  

    String jwtToken = await _getJwt(); // Get the JWT token  
    await _sendChatRequest(message, jwtToken); // Send chat request to API  
  }  

  Future<void> _sendChatRequest(String message, String jwtToken) async {  
    setState(() {  
      _isLoading = true;  
      _messages.add(Message(text: "", isUser: false)); // Placeholder for loading  
    });  

    // Prepare the API request  
    final response = await http.post(  
      Uri.parse('http://192.168.0.198:5000/chat'), // Replace with your actual API URL  
      headers: {  
        'Authorization': 'Bearer $jwtToken',  
        'Content-Type': 'application/json',  
      },  
      body: jsonEncode({'query': message}),  
    );  

    // Handle the API response  
    if (response.statusCode == 200) {  
      final responseData = json.decode(response.body);  
      String answer = responseData['answer'] ?? "No answer found.";  
      setState(() {  
        _messages.removeWhere((msg) => msg.text == ""); // Remove loading placeholder  
        _messages.add(Message(text: answer, isUser: false)); // Bot reply  
        _isLoading = false;  
      });  
    } else {  
      setState(() {  
        _messages.removeWhere((msg) => msg.text == ""); // Remove loading placeholder  
        _messages.add(Message(text: "Error: ${response.reasonPhrase}", isUser: false));  
        _isLoading = false;  
      });  
    }  
    _scrollToBottom();  
  }  

  void _scrollToBottom() {  
    if (_scrollController.hasClients) {  
      _scrollController.animateTo(  
        _scrollController.position.maxScrollExtent + 300,  
        duration: Duration(milliseconds: 200),  
        curve: Curves.easeOut,  
      );  
    }  
  }  

  String _formatMessage(String message) {  
    // Menghapus "##" dan memformat teks yang di-bold  
    message = message.replaceAllMapped(  
    RegExp(r'##(.*?)\s'), // Mencocokkan teks yang diawali dengan "##" dan diikuti oleh spasi  
    (matches) => ''  
  );   
    // Mengganti "-" dengan bullet  
     message = message.replaceAllMapped(RegExp(r'-(.*)'), (matches) => '• ${matches[1]}');  
    return message;  
  }  

  @override  
  Widget build(BuildContext context) {  
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(  
      statusBarColor: Colors.transparent,  
      statusBarIconBrightness: Brightness.dark,  
    ));  
    double screenHeight = MediaQuery.of(context).size.height;  
    double screenWidth = MediaQuery.of(context).size.width;  

    return Scaffold(  
      backgroundColor: Colors.white,  
      extendBodyBehindAppBar: true,  
      appBar: AppBar(  
        centerTitle: true,  
        backgroundColor: Colors.transparent,  
        title: Text(  
          "SkinSenseAI",  
          textAlign: TextAlign.center,  
          style: TextStyle(  
              fontSize: 30,  
              fontWeight: FontWeight.w700,  
              color: const Color.fromRGBO(51, 105, 255, 1)),  
        ),  
        elevation: 0,  
        bottom: PreferredSize(  
          preferredSize: const Size.fromHeight(1.0),  
          child: Container(  
            decoration: const BoxDecoration(  
              border: Border(  
                bottom: BorderSide(  
                  color: Colors.grey,  
                  width: 1.0,  
                ),  
              ),  
            ),  
          ),  
        ),  
      ),  
      body: Stack(  
        children: [  
          // Background Shapes  
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
          // SafeArea for chat messages and input area  
          SafeArea(  
            child: Column(  
              children: [  
                Expanded(  
                  child: ListView.builder(  
                    controller: _scrollController,  
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
                                    _formatMessage(message.text),  
                                    style: TextStyle(  
                                      color: Colors.white,  
                                      fontSize: 13,  
                                      fontWeight: FontWeight.w500,  
                                    ),  
                                  ),  
                                )  
                              : Row(  
                                  crossAxisAlignment: CrossAxisAlignment.start,  
                                  children: [  
                                    CircleAvatar(  
                                      backgroundColor: Colors.transparent,  
                                      backgroundImage:  
                                          AssetImage('assets/images/Pp.png'),  
                                      radius: 15,  
                                    ),  
                                    SizedBox(width: 8),  
                                    Expanded(  
                                      child: Container(  
                                        padding: EdgeInsets.all(10),  
                                        decoration: BoxDecoration(  
                                          color: Colors.transparent,  
                                        ),  
                                        child: message.text.isEmpty &&  
                                                _isLoading  
                                            ? Row(  
                                                mainAxisAlignment:  
                                                    MainAxisAlignment.start,  
                                                children: [  
                                                  BouncingDot(  
                                                      animation: _animation),  
                                                  SizedBox(width: 5),  
                                                  BouncingDot(  
                                                      animation: _animation),  
                                                  SizedBox(width: 5),  
                                                  BouncingDot(  
                                                      animation: _animation),  
                                                ],  
                                              )  
                                            : Text(  
                                                _formatMessage(message.text),  
                                                style: TextStyle(  
                                                  color: const Color.fromARGB(  
                                                      255, 0, 0, 0),  
                                                  fontSize: 14,  
                                                  fontWeight: FontWeight.w500,  
                                                ),  
                                              ),  
                                      ),  
                                    ),  
                                  ],  
                                ),  
                        ),  
                      );  
                    },  
                  ),  
                ),  
                // Input area  
                Container(  
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
                            onSubmitted: (value) {  
                              _sendMessage(value);  
                            },  
                          ),  
                        ),  
                        GestureDetector(  
                          onTap: () {  
                            if (_chatInputController.text.isNotEmpty) {  
                              _sendMessage(_chatInputController.text);  
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
              ],  
            ),  
          ),  
        ],  
      ),  
    );  
  }  
}  

// Bouncing dot loading indicator  
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