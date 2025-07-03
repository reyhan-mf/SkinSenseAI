import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skinsensai/home.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final String skinDiseaseName;
  final String imageUrl;

  const DiseaseDetailScreen({
    super.key,
    required this.skinDiseaseName,
    required this.imageUrl,
  });

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  Map<String, dynamic>? _diseaseDetails;
  final List<String> _chatHistory = [];
  final TextEditingController _messageController = TextEditingController();

  Future<void> _saveToFirebase() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Handle the case where the user is not logged in
      print("User not logged in");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chatHistory')
          .add({
        'skinDisease': widget.skinDiseaseName,
        'imageUrl': widget.imageUrl,
        'chatLog': _chatHistory,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Chat history saved to Firebase");
      // Optionally navigate back to the previous screen after saving
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      print("Error saving chat history to Firebase: $e");
      // Handle the error appropriately (e.g., show an error message)
    }
  }

  Future<void> _fetchDiseaseDetails() async {
    final apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer AIzaSyCEmJQ1XrKQOablkG4Uee2wb0jiapIzYSU' // Replace with your actual API key
    };
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Explain the details, symptoms, and treatment for ${widget.skinDiseaseName} menggunakan bahasa indonesia."
            }
          ]
        }
      ]
    });

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _diseaseDetails = data['candidates'][0]
              ['content']; // Adjust based on API response structure
        });
      } else {
        print('API request failed with status: ${response.statusCode}');
        // Handle API error appropriately (e.g., show an error message)
      }
    } catch (e) {
      print('Error fetching disease details: $e');
      // Handle exceptions (e.g., network errors)
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text;
    setState(() {
      _chatHistory.add("User: $message");
    });
    _messageController.clear();

    final apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer AIzaSyCEmJQ1XrKQOablkG4Uee2wb0jiapIzYSU' // Replace with your actual API key
    };
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "User asked: $message.  Respond as a helpful medical chatbot menggunakan bahasa indonesia."
            }
          ]
        }
      ]
    });

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final geminiResponse = data['candidates'][0]['content'];
        setState(() {
          _chatHistory.add("Gemini: $geminiResponse");
        });
      } else {
        print('API request failed with status: ${response.statusCode}');
        // Handle API error appropriately
      }
    } catch (e) {
      print('Error sending message: $e');
      // Handle exceptions
    }
  }

  Future<void> _showConfirmationDialog() async => AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        title: 'Keluar',
        desc: 'Apakah anda yakin untuk keluar?',
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          _saveToFirebase();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false, // Hapus semua route sebelumnya
          );
        },
      ).show();

  @override
  void initState() {
    super.initState();
    _fetchDiseaseDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _showConfirmationDialog();
        return true; // Allow the user to navigate back after the dialog
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Disease Details")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detected Skin Disease:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(widget.skinDiseaseName, style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text("Details, Symptoms, and Treatment:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (_diseaseDetails != null)
                Text(_diseaseDetails! as String,
                    style: TextStyle(fontSize: 16)),
              if (_diseaseDetails == null)
                CircularProgressIndicator(), // Show loading indicator
              SizedBox(height: 16),
              Image.network(widget.imageUrl),
              SizedBox(height: 16),
              // Chatbot interaction
              Expanded(
                child: ListView.builder(
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    return Text(_chatHistory[index]);
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration:
                          InputDecoration(hintText: 'Ask a question...'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
