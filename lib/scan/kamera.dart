import 'dart:io';  
import 'package:camera/camera.dart';  
import 'package:flutter/material.dart';  
import 'package:image_picker/image_picker.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:skinsensai/home.dart';  
import 'package:skinsensai/scan/potong.dart';  
import 'package:skinsensai/scan/preview.dart';  

class CameraScreen extends StatefulWidget {  
  const CameraScreen({super.key});  

  @override  
  _CameraScreenState createState() => _CameraScreenState();  
}  

class _CameraScreenState extends State<CameraScreen> {  
  late BuildContext _context;  
  CameraController? _cameraController;  
  bool _isFlashOn = false;  
  XFile? _capturedImage;  
  File? _croppedImage;  
  File? _originalImage; // Tambahkan variabel ini  
  final ImagePicker _picker = ImagePicker();  
  Offset? _focusPoint; // For indicating the focus point  
  List<CameraDescription>? cameras; // List of available cameras  
  int selectedCameraIndex = 0; // Current camera index  

  @override  
  void initState() {  
    super.initState();  
    _initializeCameras();  
  }  

  Future<void> _initializeCameras() async {  
    cameras = await availableCameras();  
    _cameraController = CameraController(cameras![selectedCameraIndex], ResolutionPreset.high, enableAudio: false);  
    await _cameraController?.initialize();  

    if (mounted) {  
      setState(() {});  
    }  
  }  

  Future<void> _captureImage() async {  
    if (_cameraController != null) {  
      _capturedImage = await _cameraController?.takePicture();  
      if (_capturedImage != null) {  
        _originalImage = File(_capturedImage!.path); // Simpan gambar asli  
        // Navigate to CropImageScreen  
        _croppedImage = await Navigator.push(  
          _context,  
          MaterialPageRoute(  
            builder: (context) => CropImageScreen(imageFile: File(_capturedImage!.path), originalImage: _originalImage!),  
          ),  
        );  

        if (_croppedImage != null) {  
          // Navigate to PreviewScreen  
          await Navigator.push(  
            _context,  
            MaterialPageRoute(  
              builder: (context) => PreviewScreen(croppedImage: _croppedImage!, originalImage: File(_capturedImage!.path)),  
            ),  
          );  
        }  
      }  
    }  
  }  

  @override  
  void dispose() {  
    _cameraController?.dispose();  
    super.dispose();  
  }  

  @override  
  Widget build(BuildContext context) {  
    _context = context; // Simpan context sebagai anggota kelas  
    return Scaffold(  
      body: Stack(  
        children: [  
          _cameraController == null || !_cameraController!.value.isInitialized  
              ? Center(child: CircularProgressIndicator())  
              : Positioned.fill(  
                  child: AspectRatio(  
                    aspectRatio: _cameraController!.value.aspectRatio,  
                    child: CameraPreview(_cameraController!),  
                  ),  
                ),  
          GestureDetector(  
            onTapUp: (details) {  
              // Get the tap position  
              final x = details.localPosition.dx;  
              final y = details.localPosition.dy;  
              setFocus(x, y);  
              setState(() {  
                _focusPoint = Offset(x, y);  
              });  

              // Remove the focus indicator after a delay  
              Future.delayed(const Duration(seconds: 1), () {  
                setState(() {  
                  _focusPoint = null; // Clear focus point after delay  
                });  
              });  
            },  
            child: Container(  
              color: Colors.transparent, // Allow taps to pass through  
            ),  
          ),  
          // Focus indicator  
          if (_focusPoint != null)  
            Positioned(  
              left: _focusPoint!.dx - 30, // Circle radius adjustment  
              top: _focusPoint!.dy - 30, // Circle radius adjustment  
              child: Container(  
                width: 60,  
                height: 60,  
                decoration: BoxDecoration(  
                  shape: BoxShape.circle,  
                  border: Border.all(color: Colors.blue, width: 2),  
                ),  
              ),  
            ),  

            
       Positioned(  
            top: 50,  
            left: 0,  
            right: 0,  
            child: Padding(  
              padding: const EdgeInsets.symmetric(horizontal: 16.0),  
              child: Row(  
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                children: [  
                  IconButton(  
                    icon: Icon(Icons.close, color: Colors.white),  
                    onPressed: () {  
                      // Close the camera screen or navigate back  
                      Navigator.pushReplacement(  
                context,  
                MaterialPageRoute(  
                  builder: (context) => HomePage(),  
                ),  
              );  
                    },  
                  ),  
                  IconButton(  
                    icon: Icon(  
                      _cameraController != null && cameras != null && selectedCameraIndex == 0  
                          ? Icons.camera_front  
                          : Icons.camera_rear,   
                      color: Colors.white,  
                    ),  
                    onPressed: () {  
                      // Switch camera (front/back)  
                      _switchCamera();  
                    },  
                  ),  
                ],  
              ),  
            ),  
          ),  

          // Overlay at the bottom  
          Positioned(  
            bottom: 0,  
            left: 0,  
            right: 0,  
            child: Container(  
              padding: EdgeInsets.all(10),  
              decoration: BoxDecoration(  
                color: Colors.white,  
                borderRadius: BorderRadius.only(  
                  topLeft: Radius.circular(20),  
                  topRight: Radius.circular(20),  
                ),  
                boxShadow: [  
                  BoxShadow(  
                    color: Colors.black.withOpacity(0.1),  
                    spreadRadius: 2,  
                    blurRadius: 5,  
                    offset: Offset(0, 3), // changes position of shadow  
                  ),  
                ],  
              ),  
              child: Row(  
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,  
                children: [  
                  IconButton(  
                    icon: Icon(Icons.image, color: Color.fromRGBO(81, 180, 196, 1)),  
                    onPressed: _pickImage,  
                  ),  
                  IconButton(  
                    icon: Icon(Icons.camera, color: Color.fromRGBO(81, 180, 196, 1)),  
                    onPressed: _captureImage,  
                  ),  
                  IconButton(  
                    icon: Icon(  
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,  
                      color: Color.fromRGBO(81, 180, 196, 1),  
                    ),  
                    onPressed: () {  
                      setState(() {  
                        _isFlashOn = !_isFlashOn;  
                        _cameraController?.setFlashMode(  
                          _isFlashOn ? FlashMode.torch : FlashMode.off,  
                        );  
                      });  
                    },  
                  ),  
                ],  
              ),  
            ),  
          ),  
        ],  
      ),  
      backgroundColor: Colors.black, // Change background to black for camera aesthetics  
    );  
  }  

  Future<void> _pickImage() async {  
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);  
    if (pickedFile != null) {  
      _originalImage = File(pickedFile.path); // Simpan gambar asli  

      // Navigate to CropImageScreen  
      _croppedImage = await Navigator.push(  
        _context,  
        MaterialPageRoute(  
          builder: (context) => CropImageScreen(imageFile: File(pickedFile.path), originalImage: _originalImage!),  
        ),  
      );  

      if (_croppedImage != null) {  
        // Navigate to PreviewScreen  
        await Navigator.push(  
          _context,  
          MaterialPageRoute(  
            builder: (context) => PreviewScreen(croppedImage: _croppedImage!, originalImage: _originalImage!),  
          ),  
        );  
      } else {  
        _showAwesomeSnackbar('Gambar Kosong!', ContentType.warning);  
      }  
    }  
  }  

  Future<void> _switchCamera() async {  
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras!.length;  
    _cameraController?.dispose();  
    _cameraController = CameraController(cameras![selectedCameraIndex], ResolutionPreset.high);  
    await _cameraController?.initialize();  
    if (mounted) {  
      setState(() {});  
    }  
  }  
  

  Future<void> setFocus(double x, double y) async {  
    if (_cameraController != null) {  
      // Convert the coordinates to normalized values  
      double normalizedX = x / MediaQuery.of(_context).size.width;  
      double normalizedY = y / MediaQuery.of(_context).size.height;  

      // Set the focus point  
      await _cameraController?.setFocusPoint(Offset(normalizedX, normalizedY));  
      await _cameraController?.setFocusMode(FocusMode.auto);  
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

    ScaffoldMessenger.of(_context)  
      ..hideCurrentSnackBar()  
      ..showSnackBar(snackBar);  
  }  
}