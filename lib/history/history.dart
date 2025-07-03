import 'package:flutter/material.dart';

class HistoryDetails extends StatefulWidget {
  final List<Map<String, dynamic>> messages;

  HistoryDetails({required this.messages});

  @override
  _HistoryDetailsState createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(51, 105, 255, 1),
          ),
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
          // Latar Belakang Bentuk
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

          // Daftar Pesan
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.messages[index];
                      return ListTile(
                        title: Align(
                          alignment: message['isUser']
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: message['isUser']
                                  ? Color(
                                      0xFF3369FF) // Warna biru untuk pesan pengguna
                                  : Colors.grey[
                                      300], // Warna abu-abu untuk pesan bot
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              message['text'],
                              style: TextStyle(
                                color: message['isUser']
                                    ? Colors
                                        .white // Teks putih untuk pesan pengguna
                                    : Colors
                                        .black, // Teks hitam untuk pesan bot
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Text("chat telah berakhir..."),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
