  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:skinsensai/scan/hasilPemeriksaan.dart';
  import 'package:skinsensai/scan/potong.dart';

  class PreviewScreen extends StatefulWidget {
    final File croppedImage;
    final File originalImage;

    const PreviewScreen({
      super.key,
      required this.croppedImage,
      required this.originalImage,
    });

    @override
    _PreviewScreenState createState() => _PreviewScreenState();
  }

  class _PreviewScreenState extends State<PreviewScreen>
      with SingleTickerProviderStateMixin {
    bool _isChecking = false;
    double _progress = 0.0;
    late AnimationController _animationController;
    late Animation<double> _animation;

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );
      _animation =
          Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
            ..addListener(() {
              setState(() {
                _progress = _animation.value;
              });
            });
    }

    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }

    Future<String> _getJwt() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jwtToken = prefs.getString('jwt_token') ?? '';
      print("Token = $jwtToken"); // Print JWT token
      return jwtToken;
    }

    Future<void> _checkNow() async {
      setState(() {
        _isChecking = true;
      });

      _animationController.forward().then((_) async {
        String jwtToken = await _getJwt(); // Dapatkan token JWT untuk permintaan

        // Siapkan permintaan API untuk meng-upload gambar
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.0.198:5000/upload'),
        );

        request.headers['Authorization'] = 'Bearer $jwtToken';

        // Tambahkan file gambar cropped ke dalam permintaan
        request.files.add(await http.MultipartFile.fromPath(
          'file', // Ini adalah nama field yang diterima server
          widget.croppedImage.path,
        ));

        // Kirim permintaan dan tunggu respons
        var response = await request.send();

        String responseMessage; // Menyimpan response dari server
        if (response.statusCode == 200) {
          // Tangani keberhasilan
          responseMessage = await response.stream.bytesToString();
          print("Response: $responseMessage"); // Print response dari server
        } else {
          // Tangani kesalahan
          responseMessage = "Error: ${response.reasonPhrase}";
          print(responseMessage);
        }

        setState(() {
          _isChecking = false;
        });

        // Navigasi ke HasilPemeriksaanScreen dengan mengirimkan response
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HasilPemeriksaanScreen(
                  responseMessage: responseMessage,
                  croppedImage: widget.croppedImage)),
        );
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _isChecking = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropImageScreen(
                    imageFile: widget.originalImage,
                    originalImage: widget.originalImage,
                  ),
                ),
              );
            },
          ),
          title: Text('Preview', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
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
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  widget.croppedImage,
                  width: 350,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isChecking = false;
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF51B4C4),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Foto Ulang'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _checkNow();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF51B4C4),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Color(0xFF51B4C4), width: 2),
                      ),
                    ),
                    child: Text('Periksa Sekarang'),
                  ),
                ],
              ),
            ),
            if (_isChecking)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Sedang Memeriksa...'),
                        SizedBox(height: 16.0),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: _progress,
                                strokeWidth: 10,
                                color: Color(0xFF51B4C4),
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF51B4C4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
