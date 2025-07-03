import 'package:flutter/material.dart';  
import 'package:skinsensai/history/history.dart';   

class HistoryGallery extends StatefulWidget {  
  @override  
  _HistoryGalleryState createState() => _HistoryGalleryState();  
}  

class _HistoryGalleryState extends State<HistoryGallery> {  
  // Contoh data statis untuk riwayat  
  List<Map<String, dynamic>> histories = [  
    {  
      'userId': 'Kurap',  
      'description': 'Riwayat pemeriksaan untuk kurap.',  
    },  
    {  
      'userId': 'Bisul',  
      'description': 'Riwayat pemeriksaan untuk bisul.',  
    },  
  ];  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Colors.white,  
      body: Container(  
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
            SafeArea(  
              child: SingleChildScrollView(  
                child: Padding(  
                  padding: const EdgeInsets.all(25.0),  
                  child: Column(  
                    crossAxisAlignment: CrossAxisAlignment.center,  
                    mainAxisAlignment: MainAxisAlignment.center,  
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
                            'Riwayat',  
                            style: TextStyle(  
                              fontSize: 35,  
                              fontWeight: FontWeight.bold,  
                            ),  
                          ),  
                        ],  
                      ),  
                      const SizedBox(height: 20), // Space between title and cards  
                      // Jika histories kosong, tampilkan indikator loading  
                      if (histories.isEmpty)  
                        const Center(  
                          child: CircularProgressIndicator(),  
                        )  
                      else  
                        Column(  
                          children: histories.map((history) {  
                            return Card(  
                              elevation: 5,  
                              color: Colors.white,  
                              margin: const EdgeInsets.symmetric(vertical: 10),  
                              shape: RoundedRectangleBorder(  
                                borderRadius: BorderRadius.circular(10),  
                              ),  
                              child: ListTile(  
                                onTap: () {  
                                  // Arahkan ke detail berdasarkan riwayat yang terpilih  
                                  Navigator.push(  
                                    context,  
                                    MaterialPageRoute(  
                                      builder: (context) => HistoryDetails(  
                                        messages: [  
                                          {'text': history['description'], 'isUser': false, 'userId': history['userId']},  
                                        ],  
                                      ),  
                                    ),  
                                  );  
                                },  
                                title: Row(  
                                  children: [  
                                    ClipRRect(  
                                      borderRadius: BorderRadius.circular(20.0),  
                                      child: Container(  
                                        decoration: BoxDecoration(  
                                          color: Color.fromRGBO(179, 197, 247, 1),  
                                          borderRadius: const BorderRadius.all(Radius.circular(12)),  
                                        ),  
                                        padding: const EdgeInsets.all(5),  
                                        margin: const EdgeInsets.all(5),  
                                        child: Image.asset(  
                                          'assets/images/icon2.png', // Gambar placeholder  
                                          width: 50,  
                                          height: 50,  
                                          fit: BoxFit.cover,  
                                        ),  
                                      ),  
                                    ),  
                                    const SizedBox(width: 10),  
                                    Expanded(  
                                      child: Column(  
                                        crossAxisAlignment: CrossAxisAlignment.start,  
                                        children: [  
                                          Text(  
                                            'Riwayat: ${history['userId']}',  
                                            style: const TextStyle(  
                                              fontWeight: FontWeight.bold,  
                                              fontSize: 16.0,  
                                            ),  
                                          ),  
                                          const SizedBox(height: 4.0),  
                                          Text(  
                                            history['description'],  
                                            maxLines: 3,  
                                            style: const TextStyle(  
                                              color: Colors.grey,  
                                              fontSize: 14.0,  
                                              height: 1.1,  
                                            ),  
                                          ),  
                                        ],  
                                      ),  
                                    ),  
                                  ],  
                                ),  
                              ),  
                            );  
                          }).toList(),  
                        ),  
                    ],  
                  ),  
                ),  
              ),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}